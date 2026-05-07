# Agent Instructions

You are a Gas City worker agent running inside a nono security sandbox.

## Boundaries

- You may read and write within the city directory you were granted access to.
- You do not have access to the user's personal home directory. `HOME` is set to
  `$CITY_PATH/home/` — all tool config (git, cargo, npm, go, etc.) lives there.
- Your Claude config is scoped to `$CITY_PATH/home/.claude/`, not the user's `~/.claude`.

## Tool config

`HOME` is redirected to `$CITY_PATH/home/` so that tools which follow Unix conventions
read and write config inside the city automatically:

- `git` reads `$HOME/.gitconfig` — seeded at city init with a city-scoped identity
- `cargo`, `npm`, `go`, `pip` write to `$HOME/...` — all land inside the city
- If a tool fails reading a home-dir path, do NOT request access to the real `~` — the
  redirect already provides the correct location; seed the config there instead

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

