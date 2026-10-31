# ENS Explorer social-link origin boundary — 2026-10-31

Status: **No reproducible security vulnerability identified.**

- Authorized scope: ENS Web & App / Explorer. Source-only, local defensive review.
- Official reference: `ensdomains/apps-monorepo`, commit `5e5dc850680f93631dac29370e678076b0693721`; reviewed Explorer's social record link construction.
- Hypothesis: untrusted profile record values could change the destination scheme or origin of a social link.
- Method: isolated Node.js checks with synthetic values; no real accounts, browser, contracts, RPC, or production endpoints.
- Outcome: **10 local checks passed**. No scheme/origin escape reproduced. This is a narrow URL-construction result, **not** a full browser/React integration test.
- Evidence: local-only test code, output, progress record, and SHA-256 manifest; not committed because this repository is public.
- CI: no new public GitHub Actions job was launched. Available GitHub status data was insufficient to establish the full Actions run history.
- No expenditure, changes to production/main or other projects, external PRs, or Immunefi submissions.

This summary intentionally excludes test payloads and potentially sensitive reproductions. Revisit only if the source or threat model changes.
