# ENS Web & App — authenticated provider-event boundary (2026-10-28)

**Outcome: no reproducible in-scope vulnerability or bounty claim established.**

- **Single new hypothesis:** an untrusted or mismatched third-party email-provider event might affect another account's notification-channel data. This boundary was not covered by the earlier laboratory checks for favorites, preferences, notification feed, Telegram OAuth state, and channel ownership.
- **Scope:** ENS Web & App Manager/Explorer supporting backend services, checked against Immunefi's scope updated **27 October 2026**. No production testing.
- **Upstream:** `ensdomains/apps-monorepo`, commit `dcc4a03d1890dc480388d714a741515501c410ca`; `workers/api-worker/src/app/routes/webhook/sendgrid.ts`, Git blob `5ab2c6585e6f353d3b05ab343e88df4f8b0a316e`.
- **Evidence:** original TypeScript signature-verification functions source-extracted and transpiled for an isolated Node.js/WebCrypto harness. Ephemeral P-256 keys and `.invalid` synthetic mailbox identities only. **7/7 local assertions passed**. The existing upstream webhook tests were inspected to avoid repeating their cases.
- **Private SHA-256 evidence:** extracted source `32cb3763e8063d6ae07be08d26b4e3a77301408e17a6f744aedcc4ed23870a09`; test harness `836f609d7cdf13e55811a213e750bf472aed188412f34b892b8c74a9b27c5742`; results `d49d5bfdec1f94d8bbff994836cbbb360d30cfd110effc36e07e31bf4198e48e`.
- **Private files (not committed):** `/mnt/data/ens_security_lab_private/sendgrid_timestamp_20261028/`.
- **Limitations:** isolated signature verification, not an integrated Hono/SendGrid/PostgreSQL run; no proof of real-world attacker capabilities, user impact, deployed-code equivalence, or bounty eligibility. Additional private observations are deliberately omitted from this public record.
- **GitHub Actions:** repository and recent commit checked; latest commit has no combined CI statuses or PR-associated workflow runs returned by available connector. The connector does not list all Actions runs, so full execution history could not be verified. No public Action dispatched with private test code.
- **Safety:** zero cost; no production requests, blockchain activity, user accounts, third-party data, public PoC, external PR, or Immunefi submission. ORIGEN and all other projects untouched.

Do not repeat this hypothesis without new source changes or additional evidence.