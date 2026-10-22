# Staging security checklist

Do not paste secrets, tokens, or Worker URLs into ChatGPT, Git, screenshots, or test fixtures.

## Access control recommendation

| Control | Role | Private? |
| --- | --- | --- |
| Empty production `HAJJ_LIVE_BASE_URL` | Store builds never call staging | Yes for production users |
| Cloudflare Access, All traffic, owner email + one service token | Edge authentication **before** the Worker runs | Yes, if enabled and not bypassed |
| Dashboard `PILOT_GATE` | Second check inside the Worker | **No** by itself (shared secret) |
| `X-Muhasabah-Install` | Opaque quota bucket | **No** (spoofable) |
| `muhasabah-hajj-sources-staging.muhasabah-dev.workers.dev` with Access **off** | Public URL | **No** — do not deploy in that state |

**Owner authenticates (browser):** Cloudflare Access login (email OTP or Cloudflare account).  
**Flutter staging client:** Access **service token** headers `CF-Access-Client-Id` and `CF-Access-Client-Secret`, plus `X-Muhasabah-Pilot`. Values live only in gitignored `tool/hajj_staging.defines.json`.  
**Unauthorised requests:** Access login/403 at the edge; if Access is skipped, Worker 503 (unset gate) or 403 (wrong gate).  
**Cost:** Zero Trust **Free** is documented at USD 0 for ≤50 users. Do not upgrade Zero Trust to pay-as-you-go. Access does not require Workers Paid.  
**Personal data:** Access will process the **owner’s email** for login and keep short Zero Trust logs (about 24 hours on Free). Hajj names, passports, health notes, and reflections must **not** be sent. The Worker still rejects those fields.

If Access cannot be turned on, **stop**. A header in an APK is not owner-only security.

## Secrets handling

- Generate `PILOT_GATE` and the Access service token in a password manager.
- Set `PILOT_GATE` with `wrangler secret put` (interactive). Never `--var PILOT_GATE=...` on the command line, never wrangler.toml.
- Rotate: new secret + `wrangler secret put`; revoke the old Access token in Zero Trust.
- Wrangler login cookies stay in the user profile, not the repo.
- `.gitignore` covers `wrangler.toml`, `wrangler.staging.toml`, `.dev.vars`, and `tool/hajj_staging.defines.json`.

## Source retrieval

- Adapters only: `haj.gov.sa`, `nusuk.sa`, `www.gov.uk` pilgrimage page.
- Client `url` / `uri` / `href` rejected.
- Redirects `manual`; destination host re-checked; max 2 hops; `/api/` and `login` blocked.
- HTTPS only; 8 s timeout; 8 KB body; HTML/XHTML/XML/text only.
- One GET attempt; 24 h memory cache; in-flight coalescing.
- `verificationStatus` remains `unverified`. `uri` and `retrievedAt` preserved.
- Timeout / 401 / 403 / 429 / cap → stale cache or manual-link guidance.
- Staging `ENVIRONMENT` cannot enable mock origin.

Do not loop live GETs against government sites.

## Flutter

- Consent toggle required on device.
- AI gateway remains disabled.
- Staging dart-defines are **not** in release Gradle/Xcode configs.
- HTTP except HTTPS allowed only for `127.0.0.1`, `localhost`, `::1`, `10.0.2.2`.
- 403/429/unavailable: user-visible message; store unchanged.

## Residual risks (accepted until Access + no APK distribution)

- Service tokens inside a debug APK are extractable. Mitigation: **do not distribute** the staging build.
- Access misconfiguration (bypass / “everyone”) would publish the Worker. Mitigation: fail-closed `PILOT_GATE` still required on staging, but that is not authentication.
- Isolate quotas are **not** worldwide hard caps.
- Public scanners hitting Access still count toward the account 100,000 Worker requests/day if they reach the Worker; Access usually stops them first.
- Zero Trust logs contain the owner’s email, not Hajj private text, if operators stay on Free logging defaults.
