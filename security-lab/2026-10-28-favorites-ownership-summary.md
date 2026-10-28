# ENS API — Favorites ownership boundaries (2026-10-28)

Status: **closed — no reproducible vulnerability**.

This is a non-sensitive progress marker only. No PoC, private test harness, account data, exploit details, or secrets are published here.

- Target: ENS Web & App / Manager supporting API, favorites routes.
- Upstream reference: `ensdomains/apps-monorepo@86c897eed0c447a740140e8c5c3e9737790a3291`.
- Source file: `workers/api-worker/src/app/routes/favorites/index.ts`; blob `dc74610c6a51bc6b701b2f151e20f4a3ca199074`.
- Single hypothesis: cross-user access or modification of favorites where accounts may save the same name.
- Method: isolated execution of upstream route handlers with synthetic users and mocked database behavior; no external network or blockchain.
- Result: **7/7 local assertions passed**, including read isolation, per-user deletion and write separation. No issue demonstrated.
- Limits: no full JWT/Hono/PostgreSQL integration; no verification of the live deployed version. No GitHub Actions run for this iteration, to avoid publishing private test material in a public repository.
- Evidence: private local run log and checksums retained outside GitHub; this record contains no test code.
- Scope checked against [ENS Immunefi Web & App](https://immunefi.com/bug-bounty/ens/scope/) (last updated 2026-10-27).

No submission to Immunefi or external pull request. No user notification required. Do not repeat this hypothesis without materially new evidence.
