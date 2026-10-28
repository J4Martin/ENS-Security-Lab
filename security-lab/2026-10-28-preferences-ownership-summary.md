# ENS API: notification preferences ownership review (2026-10-28)

Status: **closed — no vulnerability reproduced**.

- Scope: ENS Web & App API, authenticated notification preferences GET/PATCH.
- Single hypothesis: a user could read another user's verified channels/preferences or modify another user's notification toggles.
- Upstream source: `ensdomains/apps-monorepo`, commit `86c897eed0c447a740140e8c5c3e9737790a3291`, file `workers/api-worker/src/app/routes/notifications/preferences.ts`, blob `1caf4a19783f3decfd10e0a46ecb972562f8c627`.
- Evidence: original upstream TypeScript handler transpiled and executed locally with isolated synthetic users and mock Drizzle/Hono adapters; **6 of 6 assertions passed**. Tests cover two-way GET/PATCH isolation, a foreign user_id in submitted data, partial updates, and new-account defaults.
- Source SHA-256: `414c893155e38f5cae73440479bf89faf586b575d641f0fbf060c58e20e86f03`.
- Local test script SHA-256: `9aef15a9429be9a2a47762e7a5ae717aeb1cfe0da0ee4c54c6367dcc30fb3f5a`.
- Local result JSON SHA-256: `faf6cfb7faaf7e0e376f2dfa092f5754817c09e8c70dc0b56a0346d67ea76277`.
- Private test and evidence files: `/mnt/data/ens_security_lab_private/preferences_20261028/` (not committed).
- Limits: JWT middleware and PostgreSQL were mocked; this is not a live deployment test and does not establish absence of other flaws.
- Actions: no real users, no production requests, no external PR, no Immunefi submission, no paid services, no sensitive PoC published.
- GitHub Actions: existing laboratory runs reviewed; no new public workflow dispatched because private test code must not be uploaded to the public repository.

Do not repeat this hypothesis without new upstream changes or evidence. The test code is deliberately not included here.
