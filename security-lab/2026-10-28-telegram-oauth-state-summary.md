# ENS API: Telegram OAuth state isolation (2026-10-28)

Status: **closed for tested boundary — no vulnerability reproduced**.

- **Single hypothesis:** a Telegram OAuth callback state could be claimed more than once or allow cross-user cancellation/linkage in ENS Manager's notification-channel setup.
- **Official scope:** ENS Web & App, Manager/Explorer supporting backend services; Immunefi scope last updated **27 October 2026**.
- **Upstream source:** `ensdomains/apps-monorepo`, commit `8bbb2366e51b2ef7b4dcf469d352d5c7ca756a4e`; `workers/api-worker/src/services/telegram/attempts.ts` (Git blob `8f6172206f6e103bc630fc52e0dc6c19de6e395a`). Also reviewed `login.ts`, `oidc.ts`, and the Telegram route.
- **Local evidence:** source-extracted original TypeScript `claimTelegramAttempt` and `cancelTelegramAttempt` functions transpiled and executed against an isolated in-memory Drizzle-predicate adapter, with two synthetic users and synthetic OAuth states. **8/8 defensive checks passed** (matching pending state, replay, unknown/expired/cancelled state, cross-user cancellation, owner cancellation in pending/processing states).
- **Completion path review:** `completeTelegramAttempt` obtains `user_id` from the claimed attempt and uses that identifier in the atomic channel insert; the channel conflict target includes user ID. This was inspected in source, **not executed** in the local harness.
- **SHA-256 evidence:** extracted source `531433cdcee7b3f04c29019dbd3ef8d0142e670dfa542c2cc949403d3a1a389d`; local test `bc198ebea0c8b0af219bf3b1797a44585993413e15d024231e737a1e3f37eb53`; result JSON `4ab0b257fb219c8d60b82e0d2f0376fec874d5f5fa657d5796ac611d1d226abd`.
- **Private files:** `/mnt/data/ens_security_lab_private/telegram_oauth_state_20261028/` (not committed).
- **Limits:** not a full Hono/Telegram OIDC/JWT/PostgreSQL integration test; synthetic DB adapter does not prove real concurrent transaction semantics. No claim that the deployed version matches the inspected commit.
- **GitHub Actions:** latest lab commit and existing branches checked; the available workflow-run connector exposes only PR-associated runs, so the full Actions history was **not verified**. No new public workflow dispatched because the test harness is private.
- **Safety:** no requests to production, no real user identities, no spending, no public PoC, no external PR or Immunefi submission.

Do not repeat this boundary test without a relevant upstream code change or new evidence. Continue with a distinct hypothesis on the next iteration.
