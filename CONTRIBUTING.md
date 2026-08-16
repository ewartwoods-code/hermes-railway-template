# Contributing

Keep this template deliberately small. Runtime features and Hermes bugs belong in [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent); this repository owns only the Railway packaging, safe defaults, documentation, and acceptance checks.

Before opening a pull request:

```sh
python3 -m json.tool railway.json >/dev/null
scripts/smoke-test.sh
git diff --check
```

Do not add provider keys, OAuth credentials, copied Hermes source, a replacement entrypoint, or a parallel dashboard/gateway supervisor.
