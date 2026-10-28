import { type Address, type PublicClient } from 'viem'
import { sepolia } from 'viem/chains'
import { describe, expect, it, vi } from 'vitest'

import { V2_CONTRACTS } from '../contracts/addresses'
import { makeClassified } from './_fixtures'
import {
  checkRetainedManagerResolvers,
  computeRetainedManagerResolverAddress,
  needsRetainedManagerResolver,
  RETAINED_MANAGER_RECORD_ROLES,
} from './retainedManagerResolver'

// Independent, offline regression checks for V1 -> V2 retained-manager rights.
// All addresses and RPC responses are synthetic. No external chain or wallet.
const WALLET: Address = '0x00000000000000000000000000000000000000b1'
const NEXT_WALLET: Address = '0x00000000000000000000000000000000000000b2'
const HCA: Address = '0x00000000000000000000000000000000000000a1'
const NEXT_HCA: Address = '0x00000000000000000000000000000000000000a2'
const MANAGER: Address = '0x00000000000000000000000000000000000000c1'
const OTHER: Address = '0x00000000000000000000000000000000000000c2'

const name = (managerAddress: Address | null = MANAGER) =>
  makeClassified({
    name: 'alice.eth',
    label: 'alice',
    action: 'migrate',
    tokenType: 'unwrapped',
    resolverStrategy: 'to-owned-permres',
    managerAddress,
  })

type SimulatedState = {
  readonly implementation?: Address
  readonly managerRoles?: bigint
  readonly hcaHasRootRoles?: boolean
  readonly walletHasRootRoles?: boolean
  readonly hasCode?: boolean
}

const fakeChain = (state: SimulatedState = {}) => {
  const getCode = vi.fn(async () =>
    state.hasCode === false ? '0x' : '0x60016000',
  )
  const readContract = vi.fn(async (request: {
    readonly address: Address
    readonly functionName: string
    readonly args?: readonly unknown[]
  }) => {
    switch (request.functionName) {
      case 'verifyContract':
        return state.implementation ?? V2_CONTRACTS.PermissionedResolverImpl
      case 'hasRootRoles': {
        const account = request.args?.[1]
        if (account === HCA) return state.hcaHasRootRoles ?? true
        if (account === WALLET) return state.walletHasRootRoles ?? true
        throw new Error('Unexpected root-role account')
      }
      case 'roles':
        expect(request.args).toEqual([0n, MANAGER])
        return state.managerRoles ?? RETAINED_MANAGER_RECORD_ROLES
      default:
        throw new Error(`Unexpected chain read: ${request.functionName}`)
    }
  })
  return {
    publicClient: { getCode, readContract } as unknown as PublicClient,
    getCode,
    readContract,
  }
}

const check = (publicClient: PublicClient) =>
  checkRetainedManagerResolvers({
    publicClient,
    chainId: sepolia.id,
    hca: HCA,
    wallet: WALLET,
    classified: [name()],
  })

describe('Security lab: migration retained-manager role boundaries', () => {
  it('uses different deterministic resolver addresses after a change of HCA owner', () => {
    const oldAddress = computeRetainedManagerResolverAddress({
      chainId: sepolia.id,
      hca: HCA,
      name: 'alice.eth',
    })
    const newAddress = computeRetainedManagerResolverAddress({
      chainId: sepolia.id,
      hca: NEXT_HCA,
      name: 'alice.eth',
    })
    expect(oldAddress.toLowerCase()).not.toBe(newAddress.toLowerCase())
    expect(NEXT_WALLET).not.toBe(WALLET)
  })

  it('verifies the exact retained manager on the expected resolver before reuse', async () => {
    const { publicClient, readContract } = fakeChain()
    await expect(check(publicClient)).resolves.toEqual(new Set(['alice.eth']))
    const expectedResolver = computeRetainedManagerResolverAddress({
      chainId: sepolia.id,
      hca: HCA,
      name: 'alice.eth',
    })
    expect(readContract).toHaveBeenCalledWith(
      expect.objectContaining({
        address: expectedResolver,
        functionName: 'roles',
        args: [0n, MANAGER],
      }),
    )
  })

  it('does not inspect or restore any manager if the owner did not opt in', async () => {
    const { publicClient, getCode, readContract } = fakeChain()
    expect(needsRetainedManagerResolver(name(null))).toBe(false)
    await expect(
      checkRetainedManagerResolvers({
        publicClient,
        chainId: sepolia.id,
        hca: HCA,
        wallet: WALLET,
        classified: [name(null)],
      }),
    ).resolves.toEqual(new Set())
    expect(getCode).not.toHaveBeenCalled()
    expect(readContract).not.toHaveBeenCalled()
  })

  it.each([
    ['missing manager authorization', 0n],
    ['unexpected admin permissions', RETAINED_MANAGER_RECORD_ROLES | (1n << 128n)],
  ])('rejects a previously deployed resolver with %s', async (_, managerRoles) => {
    const { publicClient } = fakeChain({ managerRoles })
    await expect(check(publicClient)).rejects.toMatchObject({
      invariant: 'resolver-writer-roles',
      ensName: 'alice.eth',
    })
  })

  it.each([
    ['HCA root rights revoked', { hcaHasRootRoles: false }],
    ['wallet root rights revoked', { walletHasRootRoles: false }],
  ])('refuses retained-manager reuse when %s', async (_, state) => {
    const { publicClient } = fakeChain(state)
    await expect(check(publicClient)).rejects.toMatchObject({
      invariant: 'resolver-writer-roles',
      ensName: 'alice.eth',
    })
  })

  it('rejects a resolver with an unapproved implementation', async () => {
    const { publicClient } = fakeChain({ implementation: OTHER })
    await expect(check(publicClient)).rejects.toMatchObject({
      invariant: 'resolver-implementation',
    })
  })
})
