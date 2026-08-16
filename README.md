# Hermes Agent on Railway

[![Template checks](https://github.com/otopba/hermes-railway-template/actions/workflows/template-checks.yml/badge.svg)](https://github.com/otopba/hermes-railway-template/actions/workflows/template-checks.yml)
[![Hermes Agent](https://img.shields.io/badge/Hermes_Agent-v2026.8.3-6f42c1)](https://github.com/NousResearch/hermes-agent/releases/tag/v2026.8.3)

Deploy [Hermes Agent](https://github.com/NousResearch/hermes-agent) to Railway with the official Nous Research container image, persistent storage, an authenticated web dashboard, and OpenAI Codex/ChatGPT OAuth support.

> Community-maintained deployment template. This repository is not affiliated with Nous Research, OpenAI, or Railway.

<!-- RAILWAY_DEPLOY_BUTTON_START -->
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/hermes-agent-official-image)
<!-- RAILWAY_DEPLOY_BUTTON_END -->

## What this template provides

- Official `nousresearch/hermes-agent` image pinned to a release and immutable multi-platform digest
- Hermes' upstream PID 1 entrypoint and s6 supervision, unchanged
- Persistent Railway volume mounted at the upstream path: `/opt/data`
- Authenticated dashboard on Railway's HTTPS domain
- Lightweight `/api/health` deployment healthcheck
- OpenAI Codex OAuth through Hermes' native `openai-codex` provider
- Optional API server disabled by default to reduce the public attack surface
- Dependabot image update pull requests and a full container smoke test

## Deploy

Use the Railway button above. Railway creates one service, a public HTTPS domain, and a persistent volume. The template generates independent dashboard password and session-signing secrets.

After the deployment reaches `SUCCESS`:

1. Open the service's **Variables** tab and reveal `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD`.
2. Open the generated public domain and sign in as `admin`.
3. Open the dashboard terminal/console and run:

   ```sh
   hermes auth add openai-codex
   ```

4. Open the device-code URL shown by Hermes, enter the code, and finish ChatGPT sign-in.
5. Run `hermes model` if you want to select a different Codex model.

Hermes writes OAuth credentials, configuration, sessions, skills, and memory under `/opt/data`; the Railway volume keeps them across restarts and redeployments.

## Security defaults

The dashboard refuses to start on a public bind without an authentication provider. This template configures the bundled username/password provider with generated credentials and stable session signing.

- Do not expose port `8642` unless you intentionally enable the OpenAI-compatible API server and configure `API_SERVER_KEY`.
- Do not set `GATEWAY_ALLOW_ALL_USERS=true`; use each messaging platform's pairing or allowlist controls.
- Treat dashboard access as administrative access to the agent and its credentials.
- For stronger internet-facing access control, put the dashboard behind an OIDC provider, a VPN, Tailscale, or an authenticated reverse proxy.

See [SECURITY.md](SECURITY.md) before exposing additional ports or integrations.

## Template configuration

| Setting | Value |
| --- | --- |
| Source | This repository (`main`) |
| Base image | `nousresearch/hermes-agent:v2026.8.3` pinned by digest |
| Start command | `/opt/hermes/docker/entrypoint-dispatch.sh gateway run` |
| Public port | `9119` |
| Healthcheck | `/api/health` |
| Persistent volume | `/opt/data` |
| Restart policy | On failure, up to 10 retries |
| Optional API server | Disabled |

The Railway template creates these variables:

| Variable | Purpose |
| --- | --- |
| `PORT=9119` | Railway public HTTP target |
| `HERMES_DASHBOARD=1` | Enables the supervised dashboard |
| `HERMES_DASHBOARD_HOST=0.0.0.0` | Makes the dashboard reachable by Railway |
| `HERMES_DASHBOARD_PORT=9119` | Dashboard listen port |
| `HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin` | Initial dashboard username |
| `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` | Generated dashboard password |
| `HERMES_DASHBOARD_BASIC_AUTH_SECRET` | Generated stable session-signing secret |
| `API_SERVER_ENABLED=false` | Keeps the optional API server closed |

## Run locally

```sh
cp .env.example .env
# Replace both placeholder secrets in .env, then:
docker compose up --build
```

Open <http://127.0.0.1:9119>. Stop with `docker compose down`; add `--volumes` only when you intentionally want to erase all local Hermes state.

Run the same acceptance test used in CI:

```sh
scripts/smoke-test.sh
```

The test verifies the authenticated dashboard, health endpoint, disabled API server, non-leaking password, and volume persistence after container recreation. It does not authorize a real ChatGPT account.

## Updating Hermes

Dependabot watches the Docker base image. For each update:

1. Review the upstream [release notes](https://github.com/NousResearch/hermes-agent/releases).
2. Confirm the tag and digest both changed in `Dockerfile`.
3. Let the container smoke test pass.
4. Deploy to a disposable Railway project and verify `/api/health`, dashboard login, and volume persistence.
5. Merge only after the live checks pass.

Never change this template to `:latest`: a mutable tag can introduce breaking changes during an unrelated rebuild.

## Resources

- [Hermes Agent documentation](https://hermes-agent.nousresearch.com/docs)
- [Official Docker guide](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/docker.md)
- [Hermes Agent releases](https://github.com/NousResearch/hermes-agent/releases)
- [Railway template documentation](https://docs.railway.com/templates)

## License

The deployment files in this repository are available under the [MIT License](LICENSE). Hermes Agent and the upstream container image remain governed by their own upstream license and notices.
