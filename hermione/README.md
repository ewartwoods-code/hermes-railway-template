# Hermione on Railway — her web chat, connected to the farm

Owner, 2026-10-07: *"Railway čats kā Hermione"*. This branch turns the Hermes
container into Hermione's chat (the dashboard's Chat tab), and nothing else.

- **Nothing runs by itself.** The container's main program is `sleep infinity`; only
  the dashboard runs. `019-hermione` sets every saved gateway intent to stopped at
  each boot, so no cron job or messaging platform from the August setup returns
  (the farm is frozen since 2026-09-21).
- **Who she is.** `SOUL.md` comes from the farm repository
  (`scripts/hermione/hermes-profile/SOUL.md`); her role: `agents/hermione/info.md`
  "Her role" there.
- **The farm.** Cloned read-only at boot into `/opt/data/ewart-woods-farm`, which is
  her working folder; farm commands run as `FARM_WORKER=hermione`.
- **Model.** `anthropic/claude-opus-5` through OpenRouter (per token); override with
  the variable `HERMIONE_MODEL`. Spending is capped by the OpenRouter key's limit.

Railway variables (values never in this repository): `OPENROUTER_API_KEY`,
`HONCHO_API_KEY`, `FARM_SYNC_TOKEN`, `FARM_REPO_DEPLOY_KEY` (a read-only deploy key
of `ewartwoods-code/ewart-woods-farm`), and the dashboard's basic-auth pair.
