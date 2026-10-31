# ENS Manager — notification URL scheme boundary (2026-10-31)

- **Scope:** ENS Manager, client-side rendering of notification action URLs.
- **Hypothesis:** Could an apparently permitted notification URL be interpreted as an executable or non-HTTP(S) scheme after rendering?
- **Official source:** `ensdomains/apps-monorepo` commit `5e5dc850680f93631dac29370e678076b0693721`. Inspected shared HTTP URL guard, Manager wrapper, notification action components, and upstream tests.
- **Non-duplicative method:** 22 isolated Node.js parser-differential checks using a faithful transcription of the original TypeScript decision logic, plus two nullish cases. Only synthetic data; no target traffic.
- **Result:** All final checks passed. No accepted URL resolved to a non-HTTP(S) scheme in the local Node URL parser. **No exploitable or remunerable vulnerability demonstrated.**
- **Limits:** No full React/browser integration, no verified attacker-controlled notification source, and no production-version verification. A supplementary headless-browser check timed out and is not claimed as successful.
- **CI:** Existing lab branches and main commit inspected. The accessible GitHub workflow lookup is limited to commit-associated PR runs and returned no runs for the inspected commit; this is not a complete Actions history. No new public workflow was launched.
- **Evidence:** Private local test source, final output, research log, and SHA-256 manifest were retained outside the public repository. No test payloads or exploit instructions are published here.
- **Safety:** No money spent, live services touched, real accounts used, blockchain activity, external PR, or Immunefi submission.

**Decision:** Close this hypothesis with current evidence; only revisit for a concrete browser/parser mismatch or an attacker-controlled notification rendering path.
