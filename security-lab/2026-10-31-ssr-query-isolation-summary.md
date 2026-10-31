# ENS Web & App — SSR private-query isolation (defensive review)

Date: 2026-10-31. Official source: `ensdomains/apps-monorepo@f15e26a0bf324801396dac7a0bbd34abc0db5deb`; inspected file `apps/manager/src/router.tsx`, Git blob `28af98e4c43943a9d794167c2bb4d32868c3157b`.

**One hypothesis:** whether two concurrent Manager server-side rendering requests could accidentally share authenticated query cache state, allowing one synthetic account's private data to appear in another account's response.

**Execution:** the exact upstream TypeScript file (blob SHA checked) was transpiled and executed locally under Node.js. External framework dependencies were replaced with inert test doubles. Six focused assertions passed: request-local QueryClient creation, matching SSR integration, independent private cache values for two synthetic users, independent mutation invalidation, and no cache inheritance by a subsequent request.

**Outcome:** the tested server-side construction creates independent query clients. No cross-request data disclosure or in-scope bounty finding was demonstrated. The isolated execution does not validate full TanStack runtime behavior, deployed Workers, or client-side wallet switching.

The private offline test harness, output, and SHA-256 manifest are retained outside this public repository. No PoC, exploit steps, secrets, personal data, production traffic, blockchain activity, or external submissions were involved. No GitHub Actions were launched because the test harness is private and the connector does not expose a complete Actions history.

Status: **non-actionable on current evidence**.