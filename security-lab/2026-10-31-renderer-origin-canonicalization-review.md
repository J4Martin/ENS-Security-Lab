# ENS Manager — renderer origin canonicalization (2026-10-31)

**Scope:** Web & App, Manager UI only. Defensive local research; no production access.

**Single hypothesis:** An ambiguous URL authority could cause the commemorative NFT renderer iframe to receive an elevated sandbox origin when its actual origin is untrusted or coincides with the Manager app.

**Upstream reference:** `ensdomains/apps-monorepo`, observed HEAD `5e5dc850680f93631dac29370e678076b0693721`. Reviewed `apps/manager/src/features/migration/components/success/rendererSandbox.ts`, Git blob SHA `79e3389a8da59465c11eb854233edcde67c46ffb`. The original source was copied without modifications for local testing and verified by Git blob hash.

**Outcome:** 12 isolated Node.js checks passed; zero failed. No origin privilege confusion reproduced; no demonstrated in-scope vulnerability or bounty claim.

**Evidence:** Private local harness, results, SHA-256 manifest and progress JSON retained outside this public repository. No test inputs, payloads, reproduction scripts or secrets published.

**CI review:** GitHub commit status queries for two laboratory commits returned no statuses, and the available commit-specific PR-workflow lookup returned no runs. This is not a full Actions history. No new public Actions execution was launched.

**Limitations:** This verifies the original sandbox decision helper under Node URL parsing, not browser redirects, CSP, iframe runtime or the deployed revision. A finding would require a separate, non-production impact demonstration.

**Safety:** Synthetic-only, no production traffic, no contracts, no external PRs, no Immunefi submission, no paid services. Prior investigations of push, notifications, SIWE, Telegram, avatar URL guards, delivery ownership and authentication lifecycle were not rerun.
