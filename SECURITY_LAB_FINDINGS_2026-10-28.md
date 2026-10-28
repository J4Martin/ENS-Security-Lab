# ENS Security Lab — 28 October 2026

> Private research notes for authorized bug-bounty testing, committed only to the research branch of a public fork. No vulnerability confirmed. No production, mainnet, public testnet, or external account tests conducted.

## Verified program constraints

- ENS Immunefi scope: https://immunefi.com/bug-bounty/ens/scope/
- ENS Immunefi information: https://immunefi.com/bug-bounty/ens/information/
- The ENS manager / explorer / backend source-code asset was added to the Web & App scope on 27 October 2026 (as displayed on 28 October 2026).
- A functional proof of concept demonstrating an eligible impact is required.
- Program rules prohibit testing deployed mainnet/public-testnet code. Use locally controlled environments, optionally local forks.
- ENS defines bounded HCA session access as expected behavior. The eligible cases are acting outside the grant: expiry bypass, resolver or token beyond permissions, refund above owner-signed ceilings, or owner-privilege escalation.

## Baselines

| Run | Target | Result |
| --- | --- | --- |
| https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40616408795 | core | 150 tests passed |
| https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40617724222 | manager | 3,751 tests passed, no type errors |
| https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40619069593 | api (separate test-only CSP branch) | 396 passed, 46 skipped |
| https://github.com/J4Martin/ENS-Security-Lab/actions/runs/40620822492 | core + new migration security checks | 150 baseline + 8 adversarial tests passed, no type errors |

Test-only API CSP assertion was corrected in `lab/telegram-csp-regression-20261028`; it is NOT a proved XSS or security bug. The current callback intentionally allows its one fixed nonce-authorized close-window script. No application security controls were changed.

## Migration role-boundary hypothesis (tested)

New test: `apps/manager/src/features/migration/service/retainedManagerResolver.security.test.ts`.

- The calculated deterministic resolver address changes when the HCA/deployer changes; this is a local address-calculation property, not on-chain confirmation.
- Unselected manager (opt-in missing) does not trigger retained-manager restoration.
- On simulated existing resolvers, the expected account and exact record-role bitmap are checked.
- Missing or excessive manager role bits are rejected.
- Missing HCA or wallet root rights are rejected.
- Unapproved resolver implementation is rejected.

**Result: 8/8 passed.** No unauthorized state transition was reproduced. These tests rely on mocked chain state, so they do not prove how contracts behave during actual transfers.

### Remaining questions

- After a real local migration and subsequent V2 name transfer, can an old resolver manager still modify records without consent? The TypeScript checks alone cannot answer this. Requires contracts deployed to an isolated local blockchain and a multi-account negative-control transaction.
- Do HCA session expiry, resolver boundaries, payment-token restrictions, and refund ceilings hold against an intentionally hostile delegate? This is expressly in scope if an operation outside the owner-signed grant is demonstrated.
- Are the tested commits representative of the deployed eligible release? Verify release tags before considering any report.

## Next research order

1. Review the HCA delegated-session contract/SDK trust boundary and the owner-signed bounds; prioritize a test demonstrating a forbidden state change rather than a theoretical bad configuration.
2. If a plausible path exists, construct a deterministic **local** integration test using self-controlled test keys/Anvil, pinning a release tag and preserving a legitimate control case.
3. Validate the exploit's in-scope impact and version, then prepare a concise confidential Immunefi report with replayable PoC. **Do not submit without a demonstrated violation.**
4. If not reproducible, mark this hypothesis negative and move on. Do not re-run general tests as a proxy for finding a vulnerability.

Repository safety: Changes on `lab/migration-role-boundaries-20261028` only; do not edit ORIGEN, MatchPilot, or upstream ENS.
