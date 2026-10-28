import { afterEach, describe, expect, it, vi } from 'vitest'
import { makeMockEnv } from '#test-utils/env.js'
import { logger } from '#utils/logger.js'
import telegramRoutes from './telegram.js'

const bindings = makeMockEnv({
  BASE_URL: 'https://sepolia.app-api.ens.domains',
  MANAGER_APP_URL: 'https://sepolia.app.ens.domains',
  JWT_SECRET: 'telegram-http-test-secret',
  DATABASE_URL:
    'postgres://postgres:postgres@db.localtest.me:5432/api_worker_test',
  TELEGRAM_OIDC_CLIENT_ID: '123456',
  TELEGRAM_OIDC_CLIENT_SECRET: 'test-client-secret',
  TELEGRAM_BOT_TOKEN: '123456:test-bot-secret',
})

afterEach(() => vi.restoreAllMocks())

describe('Telegram HTTP contract', () => {
  it('requires wallet auth for initiation, status and cancellation and removes legacy login', async () => {
    for (const [path, method] of [
      ['/oauth', 'POST'],
      ['/oauth', 'GET'],
      [`/oauth/${crypto.randomUUID()}`, 'DELETE'],
    ]) {
      expect(
        (await telegramRoutes.request(`/telegram${path}`, { method }, bindings))
          .status,
      ).toBe(401)
    }
    expect(
      (await telegramRoutes.request('/telegram', { method: 'POST' }, bindings))
        .status,
    ).toBe(404)
  })

  it('renders public callback failures with private, nonce-restricted responses', async () => {
    vi.spyOn(logger, 'warn').mockImplementation(() => undefined)
    const response = await telegramRoutes.request(
      '/telegram/callback?state=invalid&code=private-code&redirect_uri=https://untrusted.example',
      {},
      bindings,
    )
    const page = await response.text()
    const nonce = /<style nonce="([^"]+)">/.exec(page)?.[1]
    expect(response.status).toBe(200)
    expect(nonce).toBeTruthy()
    expect(response.headers.get('Content-Security-Policy')).toBe(
      `default-src 'none'; style-src 'nonce-${nonce}'; script-src 'nonce-${nonce}'; font-src https://fonts.ens.dev; frame-ancestors 'none'; base-uri 'none'; form-action 'none'`,
    )
    expect(response.headers.get('Cache-Control')).toBe('no-store')
    expect(response.headers.get('Referrer-Policy')).toBe('no-referrer')
    expect(page).toContain('<h1>Telegram not connected</h1>')
    expect(page).not.toContain('private-code')
    expect(page).not.toContain('untrusted.example')
    // The callback intentionally includes one fixed script for closing the tab.
    // Its nonce must match the Content Security Policy. Do not admit more scripts.
    expect(page.match(/<script\b/g)).toHaveLength(1)
    expect(page).toContain(`<script nonce="${nonce}">`)
    expect(page).toContain(
      "document.getElementById('close-window').addEventListener('click', () => window.close());",
    )
  })
})
