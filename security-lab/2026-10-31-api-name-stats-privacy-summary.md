# ENS Web & App — API name-stats privacy boundary (2026-10-31)

- **Scope:** ENS Manager supporting API, offline source-only review.
- **Official source:** `ensdomains/apps-monorepo` commit `f15e26a0bf324801396dac7a0bbd34abc0db5deb`.
- **Single hypothesis:** an unauthenticated name-statistics response might expose individual users' saved favorites rather than intended aggregate counts.
- **Method:** inspected upstream route, analytics aggregation and official tests; eight isolated local Node assertions with two synthetic identities. The checks deliberately avoid rerunning the existing upstream normal-path tests.
- **Outcome:** All eight source-derived model checks passed; **no user-specific data disclosure or in-scope vulnerability reproduced**. The route projects aggregate counts, not per-user rows.
- **Limits:** This is a model of source validation and response projection, not an integrated Hono/PostgreSQL/PostHog or production test. No claim about deployment equivalence.
- **Evidence:** Private test harness, JSON results, investigation notes and SHA-256 manifest retained outside this public repository.
- **CI:** No public workflow run with private evidence. Available GitHub connector cannot enumerate the full Actions history; commit-associated PR-run lookup for the lab's main commit returned no runs.
- **Safety:** No costs, live target traffic, real users, blockchain activity, other-project changes, external PRs or Immunefi submission.
- **Decision:** Close this hypothesis unless new source changes or a distinct, remotely reproducible attack path emerges.
