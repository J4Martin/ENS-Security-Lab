# ENS Web & App — API cross-origin account boundary (defensive review)

Date: 2026-10-31. Upstream: `ensdomains/apps-monorepo@f15e26a0bf324801396dac7a0bbd34abc0db5deb`.

A new, single hypothesis was evaluated: whether cross-origin browser access to the API could reveal authenticated account data without the user's bearer token. Source review covered the API's global CORS middleware, JWT authentication, an account-scoped private route, and the Manager client authentication-header behavior.

Five **synthetic, isolated Node.js model checks** passed. They covered missing credentials, ambient cookie-only requests, invalid bearer tokens, and account-specific response isolation. This was a **model**, not an execution of the original Hono/Cloudflare Worker, and not a browser integration test.

**Result:** no unauthorized disclosure or reportable security issue demonstrated. A permissive CORS response does not, by itself, bypass bearer authentication. No real user, production service, blockchain network, or contract was contacted.

Private test code, synthetic data, and SHA-256 evidence are retained outside the public repository. No exploit details, credentials, or proof-of-concept are published. No external PR or Immunefi submission was made.

CI visibility is limited: the available GitHub connector did not provide a complete Actions run listing; no new public workflow was launched.

Status: **non-actionable with current evidence**. Revisit only if independent evidence identifies ambient credential forwarding or a separate token disclosure path.
