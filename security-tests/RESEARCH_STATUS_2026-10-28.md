# ENS Security Lab — checkpoint 2026-10-28

## Purpose
Authorized, offline security research against an exact public ENSv2 revision.
No network calls to deployed contracts, no third-party wallets, and no proof of a vulnerability.

## Official source under test
- Repository: `ensdomains/contracts-v2`
- Immutable commit: `4f47cbcc11462fb413196e6b5c0f8090247a6c08`
- All Foundry tests run in GitHub Actions' isolated EVM.
- The pinned source appears in the mainnet deployment documentation, **but formal bug-bounty release eligibility is not yet established**.

## Verified HCA authorization outcomes
- [Run #40627722565](https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40627722565): **60 tests passed, 0 failed.**
  - 20 official destination HCA tests
  - 34 official source funding HCA tests
  - 6 additional permission-boundary regressions
- Six new tests verify that a signed positive control is accepted while the validator rejects:
  - refund exchange rate over its signed ceiling
  - refund gas overhead over its signed ceiling
  - different refund token
  - approval to an unrelated ERC-20 spender
  - arbitrary ERC-20 transfer
  - previous-owner proof against a simulated owner change
- The owner-change test deliberately alters the owner slot on a **mock** account. The deployed factory-backed HCA uses certified owner binding, so this synthetic check alone does not establish an exploitable ownership-change path.
- Earlier HCA cross-account, expiry and session-nonce revocation checks also passed: [run #40625977355](https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40625977355).

## Registry and migration permissions
- [Run #40626938835](https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40626938835): **5 tests passed, 0 failed**.
- A real local ENSv1-to-v2 migration followed by safe ownership transfer enforces the tested delegate and owner permission boundaries.
- This does not prove behavior on live contracts or cover `unsafeTransfer` semantics.

## Separate web/backend static triage
The source code for the ENS Manager/Explorer backend was added to the Web & App program scope on 2026-10-27.
Preliminary read-only review of official `ensdomains/apps-monorepo` source:
- SIWE login verifies nonce/redemption token, domain, URI, message and signature before delivering a JWT.
- Favorites, personal notifications, and notification-channel operations checked bind queries to the authenticated `user_id`.
- SendGrid event webhook checks a configured ECDSA verification key and signature.
- Telegram webhook checks the configured secret header.
**No cross-user action or authentication bypass has been demonstrated.**

## Program / disclosure guardrails
- ENS Immunefi: https://immunefi.com/bug-bounty/ens/information/
- Mainnet contract reports require the latest eligible final release. ENSv2's published deployment tag `v2-mainnet-deployment-1` does not itself prove compliance with the stated `vX.Y.Z` rule.
- A report requires a concrete in-scope impact and a reproducible PoC; these negative regression tests are not bounty submissions.
- Never publish a suspected unpatched vulnerability in GitHub, Actions logs, public discussions, or a pull request. Keep any candidate confidential for the approved Immunefi channel.

## Next decision
Do **not** repeat the six passing HCA bounds checks.
Prefer a single impact-driven hypothesis with a full locally simulated authorization and unauthorized state-change demonstration, or redirect effort to a currently eligible Web & App asset if contract version eligibility remains unresolved.
