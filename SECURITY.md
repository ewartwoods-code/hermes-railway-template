# Security

## Supported configuration

The supported public surface is the authenticated Hermes dashboard on port `9119` through Railway HTTPS. The optional OpenAI-compatible API server on port `8642` is disabled by default.

The dashboard grants administrative access to provider credentials, agent tools, sessions, skills, and persistent data. Use a unique generated password, keep the session-signing secret private, and prefer OIDC/VPN access for long-lived public deployments.

## Reporting a vulnerability

Do not open a public issue containing credentials, OAuth codes, Railway variables, logs with secrets, or a live dashboard URL. Use GitHub's private vulnerability reporting for this repository. Report Hermes Agent vulnerabilities to the upstream [Nous Research security process](https://github.com/NousResearch/hermes-agent/security).

## Deployment checklist

- Keep the image pinned to a reviewed release and digest.
- Keep the volume mounted exactly at `/opt/data`.
- Keep dashboard authentication enabled.
- Keep `API_SERVER_ENABLED=false` unless an API server is explicitly required.
- Never enable `GATEWAY_ALLOW_ALL_USERS` on an internet-facing deployment.
- Review every provider and messaging integration before enabling it.
- Revoke OAuth credentials before sharing a volume backup.
