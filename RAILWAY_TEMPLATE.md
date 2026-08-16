# Deploy and Host Hermes Agent

Hermes Agent is an open-source AI agent by Nous Research. This template deploys the official Hermes container image with an authenticated web dashboard, persistent state, and native OpenAI Codex/ChatGPT OAuth support.

## About Hosting Hermes Agent

The template creates one Railway service from the public `otopba/hermes-railway-template` repository, exposes dashboard port `9119` over HTTPS, and mounts a persistent volume at Hermes' upstream data path `/opt/data`.

Dashboard username, password, and session signing are configured automatically. The password and signing secret are independently generated for every deployment. The optional OpenAI-compatible API server stays disabled by default.

After Railway reports `SUCCESS`, reveal `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` in the service Variables tab and sign in to the generated domain as `admin`.

To connect a ChatGPT subscription, open the service shell and run:

```sh
hermes auth add openai-codex
```

Complete the device-code sign-in shown by Hermes. Credentials are written to `/opt/data` and survive redeployments.

## Why Deploy Hermes Agent on Railway

- One-click deployment from the official Nous Research image
- Persistent credentials, sessions, memory, skills, and configuration
- HTTPS dashboard with generated authentication secrets
- Healthchecked deploys and automatic restart on failure
- Native Hermes OpenAI Codex OAuth flow, without storing a ChatGPT password
- GitHub-backed source with pinned image tag and immutable digest

## Common Use Cases

- Run a personal always-on Hermes agent backed by a ChatGPT subscription
- Use Hermes' web dashboard from multiple devices
- Add Telegram, Discord, Slack, or other supported gateway integrations
- Keep agent memory and OAuth credentials across container replacements
- Test Hermes workflows without maintaining a VPS or Docker host

## Dependencies for Hermes Agent Hosting

- A Railway account with capacity for one service and one persistent volume
- A ChatGPT account only if you choose the `openai-codex` provider
- Optional credentials for messaging platforms or other model providers you enable later

### Deployment Dependencies

- Source: `https://github.com/otopba/hermes-railway-template` (`main`)
- Base image: `nousresearch/hermes-agent:v2026.8.3`, pinned by digest
- Public port: `9119`
- Healthcheck: `/api/health`
- Persistent volume: `/opt/data`
- Start command: `/opt/hermes/docker/entrypoint-dispatch.sh gateway run`

This is a community-maintained deployment template and is not affiliated with Nous Research, OpenAI, or Railway.
