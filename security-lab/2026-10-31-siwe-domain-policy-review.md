# ENS Web & App — SIWE domain-policy boundary review (2026-10-31)

- **Scope:** ENS Manager/API, source-only defensive review; no live traffic.
- **Upstream pin:** `ensdomains/apps-monorepo` commit `f15e26a0bf324801396dac7a0bbd34abc0db5deb`.
- **Single hypothesis:** an environment/domain-policy mismatch in SIWE authentication might allow unintended session use across application environments.
- **Method:** compared upstream authentication service, route, Manager client and existing auth tests. Ran eight local Node assertions against a small source-derived domain/URI policy model using synthetic values. The checks are distinct from existing upstream nonce-replay and account-binding tests.
- **Outcome:** 8/8 model checks passed. The source uses an explicit domain allowlist, requires matching HTTPS URI, and separately requires signature verification plus nonce/redemption-token consumption. No unauthorized session, cross-user access, or in-scope impact was reproduced.
- **Limitations:** no full viem/Hono/PostgreSQL integration, no actual wallet signatures, no runtime environment bindings or deployed-version verification. Policy-level acceptance alone is not a vulnerability.
- **Private evidence:** source excerpt, local test harness, TAP output, review notes and SHA-256 manifest retained outside this public repository. No exploit procedure, sensitive PoC, credentials or real-user data included here.
- **CI:** the accessible commit-specific GitHub Actions query for the lab main commit returned no PR-triggered runs; it does not enumerate the full workflow history. No public workflow was started with private material.
- **Safety:** zero spend; no production, contracts, public networks, other projects, external PRs or Immunefi submissions.
- **Disposition:** no actionable security finding. Reopen only if a distinct trust-boundary crossing can be demonstrated with an authorized isolated integration.
