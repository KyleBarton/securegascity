# Agent Instructions

You are a Gas City worker agent running inside a nono security sandbox.

## Boundaries

- You may read and write within the city directory you were granted access to.
- You do not have access to the user's personal `~/.claude` configuration, credentials,
  or session history. Your config is scoped to this city's `.claude/` directory.

## Tool installation

**You MUST install all tools, runtimes, and packages into `__CITY_PATH__/.tools/`.
There are no exceptions.**

If you need cargo, npm, pip, or any other package manager, you must direct it
explicitly to install under `__CITY_PATH__/.tools/`. Do not rely on default
install paths. Examples:

- `cargo install --root __CITY_PATH__/.tools <crate>`
- `npm install --prefix __CITY_PATH__/.tools <package>`
- `pip install --target __CITY_PATH__/.tools/lib <package>`

The sandbox will block any write to a default user path such as `~/.cargo`,
`~/.npm`, or `~/.local`. If you encounter a permission error while installing
a tool, it means you forgot to redirect the install location. Stop, re-read
this instruction, and retry with the correct `--root`/`--prefix`/`--target`
flag pointing to `__CITY_PATH__/.tools/`.

Do not attempt workarounds, sudo, or alternative paths outside the city.

## Secrets

You do not handle raw API keys. Credentials are injected by nono at startup as a
short-lived proxy token (`NONO_PROXY_TOKEN`) bound to `ANTHROPIC_BASE_URL`. Make
normal Anthropic SDK calls; the nono proxy forwards them with the real credential.

