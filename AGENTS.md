# Repository Guide

This repository is a template system for Gas City + nono. When working here, keep
the following in mind.

## Template placeholder convention

Files in `sgc/` use two placeholders that `sgc-init.sh` fills at city-init time:

- `__CITY_PATH__` — absolute path to the city directory (e.g. `/Users/kyle/cities/myproject`)
- `__CITY_NAME__` — basename of that path (e.g. `myproject`)

Files currently substituted by the init script: `city.toml`, `AGENTS.md`.
If you add a new template file that needs substitution, add it to the loop in
`sgc-init.sh` alongside those two.

## Profile file naming

The nono profile template is named `gc-__CITY_NAME__-worker.json` — the
pattern is `gc-` + `__CITY_NAME__` + `-worker`. Hyphens are used as
separators because nono requires alphanumeric-plus-hyphen profile names.

The init script identifies template profiles by matching `*__CITY_NAME__*.json`
and renames them on copy, expanding the placeholder in the filename.

## Why we extend `default`, not `claude-code`

The built-in `claude-code` nono profile grants `$HOME/.claude`, `$HOME/.claude.json`,
and macOS keychain paths. Extending it would silently inherit those home-directory
grants and undermine city isolation. We extend `default` instead and add only what
the city actually needs, with explicit deny rules for the home paths we want blocked.

## Runtime groups are intentionally absent

The built-in `claude-code` profile includes `node_runtime`, `rust_runtime`,
`python_runtime`, and `nix_runtime`. These grant read access to user-home runtime
paths (`~/.cargo/bin`, `~/.nvm`, etc.), which conflicts with containment. They are
excluded from the city profile. If a city needs them, add them explicitly to that
city's profile and document the tradeoff.

## Tool installation

Agents are instructed (in `sgc/AGENTS.md`) to install all tools under
`$CITY_PATH/.tools/` using explicit `--root`/`--prefix`/`--target` flags. No env
vars redirect this automatically — the sandbox is the enforcement mechanism. If an
agent forgets and hits a permission error, that is intentional and expected.

## CLAUDE_CONFIG_DIR

Setting `CLAUDE_CONFIG_DIR` to `$CITY_PATH/.claude` before launching `gc` is what
scopes the agent's identity to the city. The `sgc/.claude/CLAUDE.md` file is what
agents see as their global config. Without this env var set, agents inherit the
user's personal `~/.claude` — that is the identity-bleed failure mode this whole
setup prevents.
