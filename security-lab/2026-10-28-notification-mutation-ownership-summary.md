# ENS Web & App — notification mutation ownership (negative result)

Date: 2026-10-28. Scope: ENS Manager supporting API, Immunefi Web & App. No production access or network transactions.

## Distinct hypothesis

Cross-account modification of personal notification read/archive state via the authenticated batch mutation endpoints. This is **not** the previously investigated notification-feed pagination/read hypothesis.

## Pinned upstream source

- Repository: `ensdomains/apps-monorepo`
- Commit: `75917a1f731e0de5636fbfa6fd9f0aef281829de`
- File: `workers/api-worker/src/app/routes/notifications/index.ts`
- File blob: `2149f132b3517ff457f32bdd1df771dc23d9f881`
- Program scope checked: https://immunefi.com/bug-bounty/ens/scope/ (last updated 2026-10-27)

## Verification

Six synthetic isolated checks passed. The **original extracted async handlers** were evaluated with in-memory database rows and minimal Drizzle predicate adapters: cross-user read and archive attempts, mixed-user batches, source-type mismatch, and empty batch. The tested personal-notification update paths retained their owner predicate; no cross-user state change occurred. The local evidence JSON and SHA-256 manifest are kept separately, not published in this repository.

Limitations: no complete Hono/JWT/PostgreSQL integration, no live deployment-version confirmation, and no production traffic. No finding, bounty eligibility, or payout is asserted.

## Laboratory and CI

Reviewed 21 existing GitHub Actions runs: latest failure was Crowdin; the latest relevant channel-ownership workflow succeeded. No new GitHub Actions execution was launched because the laboratory is public and test code is kept private.

**Outcome:** negative; do not repeat this hypothesis without a relevant upstream change. No Immunefi submission, external PR, secrets, funds, or changes to other projects.
