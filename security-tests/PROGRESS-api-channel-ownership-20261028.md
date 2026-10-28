# ENS API channel ownership — local research record

Date: 2026-10-28 (Europe/Madrid)

## Scope and source

- Authorized research target: ENS Manager / Explorer supporting API Worker, as included in the ENS Immunefi Web & App scope on 2026-10-27.
- Official source: `ensdomains/apps-monorepo`, pinned commit `89185526058a34ac56e522cc7e83aae59779e86d`.
- Lab branch: `lab/api-channel-ownership-20261028` in `J4Martin/ENS-Security-Lab`.
- No mainnet/testnet RPC, production endpoint, real user data, third-party account, secrets, or spending.

## Single hypothesis checked

A signed-in account might read or modify another account's notification channel by using a channel identifier not owned by the caller.

## Verification

- Test file: `security-tests/api-channel-ownership.lab.test.ts`.
- Isolated GitHub Actions run: https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40629134938
- Outcome: **4 tests passed**, 1 test file passed, GitHub Actions successful.
- Checked authenticated GET, DELETE, and POST /test channel routes for owner-scoped lookup predicates, and rejected unauthenticated access.
- All identities, channel IDs, and email addresses were synthetic. Database behavior was simulated using actual Drizzle query predicates and the official Hono route code.

## Interpretation

No cross-account channel-access weakness was demonstrated by this hypothesis. The owner-scoped predicates were present in the tested code. These checks are **not** a real-Postgres integration test and do not establish the absence of every authorization bug or race condition. No reward eligibility or production exploitability is claimed.

## Research hygiene

- Previous HCA / Registry / Telegram runs were inspected; this API channel ownership hypothesis was not a repeat of those suites.
- The initial CI attempt failed during toolchain setup (no pnpm version in the split checkout), not because of a security test. It was corrected and rerun successfully.
- No public vulnerability proof, disclosure, external PR, or Immunefi submission was created.
- Do not repeat this same route-predicate suite in the next research iteration without new evidence.
