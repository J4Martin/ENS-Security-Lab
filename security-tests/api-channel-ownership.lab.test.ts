/**
 * Synthetic, local-only authorization regression for ENS API channel routes.
 * No external services, live accounts, real credentials, or RPC calls.
 * This checks query ownership predicates, not production database behavior.
 */
import { PgDialect } from 'drizzle-orm/pg-core'
import { sign } from 'hono/jwt'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => {
  const findFirst = vi.fn()
  const remove = vi.fn(() => {
    throw new Error('Unexpected channel mutation')
  })
  const change = vi.fn(() => {
    throw new Error('Unexpected channel mutation')
  })
  const db = {
    query: { userChannels: { findFirst } },
    delete: remove,
    update: change,
  }
  return { findFirst, remove, change, db, getDatabase: vi.fn(() => db) }
})

vi.mock('#core/database/index.js', async (importOriginal) => {
  const actual = await importOriginal<typeof import('#core/database/index.js')>()
  return { ...actual, getDatabase: mocks.getDatabase }
})

import channelRoutes from './$id.js'

const dialect = new PgDialect()
const JWT_SECRET = 'synthetic-local-only'
const USER_A = '11111111-1111-4111-8111-111111111111'
const USER_B = '22222222-2222-4222-8222-222222222222'
const CHANNEL_B = '33333333-3333-4333-8333-333333333333'
const env = { JWT_SECRET } as CloudflareBindings

const headers = async () => {
  const jwt = await sign(
    {
      user_id: USER_A,
      address: '0x0000000000000000000000000000000000000001',
      exp: Math.floor(Date.now() / 1000) + 60,
    },
    JWT_SECRET,
    'HS256',
  )
  return { Authorization: `Bearer ${jwt}` }
}

describe('API channel ownership boundaries (synthetic)', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mocks.findFirst.mockImplementation(async (query: { where: unknown }) => {
      const predicate = dialect.sqlToQuery(query.where as never)
      // A simulated row belonging to B must not be visible to caller A.
      const scopedToCaller =
        predicate.params.includes(USER_A) &&
        predicate.params.includes(CHANNEL_B)
      return scopedToCaller
        ? undefined
        : {
            id: CHANNEL_B,
            user_id: USER_B,
            channel: 'email',
            target: 'synthetic@example.invalid',
            data: null,
            status: 'verified',
            status_reason: null,
            verified_at: null,
            last_sent_at: null,
            last_bounce_at: null,
          }
    })
  })

  it.each([
    ['GET', ''],
    ['DELETE', ''],
    ['POST', '/test'],
  ] as const)('keeps a foreign channel private for %s', async (method, suffix) => {
    const response = await channelRoutes.request(
      `/${CHANNEL_B}${suffix}`,
      { method, headers: await headers() },
      env,
    )
    expect(response.status).toBe(404)
    expect(mocks.findFirst).toHaveBeenCalledOnce()
    const query = mocks.findFirst.mock.calls[0]?.[0] as { where: unknown }
    const predicate = dialect.sqlToQuery(query.where as never)
    expect(predicate.params).toContain(USER_A)
    expect(predicate.params).toContain(CHANNEL_B)
    expect(mocks.remove).not.toHaveBeenCalled()
    expect(mocks.change).not.toHaveBeenCalled()
  })

  it('requires authentication before looking up a channel', async () => {
    const response = await channelRoutes.request(
      `/${CHANNEL_B}`,
      { method: 'GET' },
      env,
    )
    expect(response.status).toBe(401)
    expect(mocks.findFirst).not.toHaveBeenCalled()
  })
})
