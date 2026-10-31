# ENS Web & App — Push endpoint authority review (2026-10-31)

- **Scope:** ENS Manager supporting API, push subscription destination validation.
- **Source:** `ensdomains/apps-monorepo` commit `5e5dc850680f93631dac29370e678076b0693721`; registration and delivery code plus existing upstream tests inspected.
- **Distinct hypothesis:** Whether a registered push endpoint can cross the intended HTTPS provider authority boundary. This is separate from the previously reviewed service-worker account boundary and delivery ownership invariant.
- **Method:** 24 isolated Node.js assertions against a transcribed, unmodified decision function from the official TypeScript source, with synthetic inputs and URL authority checks; no HTTP requests or live services.
- **Result:** 24/24 assertions passed. **No reproducible unauthorized destination, real-world impact, or in-scope remunerable vulnerability demonstrated.**
- **Limits:** No complete Hono/Valibot/PostgreSQL integration, actual push delivery, redirect behavior, or deployed-version verification. The existence of default fetch redirect behavior is not a confirmed exploit.
- **Evidence:** Local test source, results, research log and SHA-256 manifest retained privately; none of the test inputs or proof-of-concept material are published.
- **CI:** No public Actions run was launched with private research materials. Available commit-status and PR-run checks did not establish the full workflow history.
- **Safety:** No cost, production requests, real accounts, blockchain operations, external PRs, or Immunefi reports.

**Decision:** Close with current evidence; revisit only if the provider trust boundary or source code materially changes.
