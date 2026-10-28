# ENS API notification-feed isolation — defensive research record

Date: 2026-10-28 UTC. No vulnerability identified.

## Scope and source

- Authorized research area: ENS Web & App (Manager/Explorer supporting API); program: https://immunefi.com/bug-bounty/ens/information/ (checked 2026-10-28; page last updated 2026-10-21).
- Official repository: `ensdomains/apps-monorepo`, pinned upstream tree `89185526058a34ac56e522cc7e83aae59779e86d`.
- Official source file: `workers/api-worker/src/app/routes/notifications/index.ts`, blob `2149f132b3517ff457f32bdd1df771dc23d9f881`.
- Research branch contains **only this non-sensitive summary**; local test harness and raw evidence are not published.

## Single hypothesis

Can cursor-based pagination of a personal notification feed disclose another authenticated user's private notifications?

## Local-only verification

- Executed the official GET notification-feed handler after isolated TypeScript transpilation, with synthetic A/B accounts and an in-memory query-model database.
- Five defensive assertions passed: first page ownership, subsequent page ownership, foreign cursor isolation, reverse-user isolation, and owner scoping of both the personal-event predicate and broadcast-seen join.
- Local evidence: `notification_feed_isolation_20261028.mjs` (SHA-256 `c5f4535f3631f313ecb24c03a397cb9f8a8d273f1f17f63205c1149570781583`); result JSON (SHA-256 `842a0573b83ce65ba230015f96e78d7fb018d606707233a95d438aebc3a170d6`). Files retained outside the public repository.
- The local harness does **not** execute the actual JWT middleware or Postgres/Drizzle runtime, and broadcast rows were empty. It is not a deployed-API integration test or proof of overall security.

## Result and guardrails

**No reproducible cross-account leak demonstrated.** No live endpoints, mainnet/testnet RPC, real users, secrets, purchases, or third-party services touched. No GitHub Actions execution for this hypothesis: the existing lab repository is public and the raw defensive harness is intentionally kept out of public Git history. No external PR or Immunefi report. Do not repeat this hypothesis without materially new evidence.
