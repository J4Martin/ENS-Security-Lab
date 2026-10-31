# ENS Web & App — defensive boundary review (2026-10-31)

**Scope:** ENS API Worker; one isolated authorization/data-integrity hypothesis.

**Source:** official `ensdomains/apps-monorepo`, Telegram webhook route (Git blob `077654d978ba6099af3bf08b50ee171da60c32bf`) and Telegram attempt service (Git blob `8f6172206f6e103bc630fc52e0dc6c19de6e395a`).

**Prior-work check:** reviewed lab branch inventory and relevant upstream tests. Existing upstream happy-path tests were not rerun. Complete GitHub Actions history was not accessible through the available integration.

**Execution:** six isolated local Node.js defensive checks using synthetic identities and in-memory data; all passed. Tests use an adapted logical model, not a full execution of the official Hono/Drizzle application. No GitHub Actions run was launched because this lab is public.

**Disposition:** no demonstrated unauthorized access, exploitable weakness, or bounty-eligible impact. This is not a security report. No production endpoints, contracts, real users, or external networks were touched.

**Private evidence:** the test harness, result log, research notes and SHA-256 manifest remain outside this public repository. No exploit instructions, credentials or sensitive proof of concept are included here.

**Status:** closed pending materially new evidence.