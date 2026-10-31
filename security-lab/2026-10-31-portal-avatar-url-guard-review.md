# ENS Web & App — Explorer avatar URL guard review (2026-10-31)

- **Target:** ENS Explorer (Portal), OG-image avatar fetching.
- **Official source:** `ensdomains/apps-monorepo` commit `5e5dc850680f93631dac29370e678076b0693721`; inspected `apps/portal/src/worker/safe-fetch.ts`, `avatar.ts` and upstream regression tests.
- **Hypothesis:** unexpected hostname normalization might undermine outbound URL safety checks and redirect validation.
- **Non-duplicative method:** ten offline checks focused on internationalized hostnames and canonicalization cases absent from the upstream test suite. Synthetic input and stubbed fetch; no network requests.
- **Result:** 10/10 final checks passed. **No bypass, in-scope impact or bounty-eligible vulnerability demonstrated.**
- **Limitations:** source-derived JavaScript guard harness, not compiled TypeScript or a Cloudflare Worker/production integration. No assertions about the deployed version.
- **Evidence:** local private harness, TAP output, investigation log and SHA-256 manifest retained outside the public repository.
- **Safety:** no production requests, secrets, accounts, paid resources, blockchain actions, external PR or Immunefi submission. No private test material committed.
- **Decision:** closed for this source snapshot; revisit only on a material code change or new evidence.
