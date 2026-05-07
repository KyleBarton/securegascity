# securegascity

A template for running [Gas City](https://github.com/anthropics/gas-city) agent cities inside [nono](https://nono.sh) sandboxes.

Gas City is Anthropic's multi-agent orchestration framework. nono is a kernel-enforced capability sandbox (Landlock on Linux, Seatbelt on macOS). This project combines them so that every agent in a city runs inside an OS-level security boundary rather than relying on the agent's own discipline.

## What this solves

Two failure modes in multi-agent systems:

- **Capability bleed** — an agent accessing filesystem paths or credentials it shouldn't
- **Identity bleed** — an agent inheriting the user's personal Claude configuration (`~/.claude`, `~/.claude.json`)

## What's here

```
sgc/                        Template city directory
  city.toml                 Gas City config (nono provider, worker agent)
  AGENTS.md                 Agent instructions, injected at city init
  home/.claude/CLAUDE.md    Seeded home directory for the agent (HOME redirect target)
  profiles/
    gc-__CITY_NAME__-worker.json   Nono security profile template
    README.md               Profile installation instructions
sgc-init.sh                 Initializes a new city from the template
```

## Quick start

```bash
./sgc-init.sh
# prompts for destination path, e.g. ~/cities/myproject
```

The script:
1. Copies the `sgc/` template tree to your chosen path, filling all `__CITY_PATH__` and `__CITY_NAME__` placeholders with real values
2. Installs the nono security profile to `~/.config/nono/profiles/`

Then launch the city:

```bash
cd "$CITY_PATH" && gc start
```

## Security design

The nono profile (`gc-__CITY_NAME__-worker.json`) extends nono's `default` profile — not the built-in `claude-code` profile — so it does not inherit the home-directory grants (`$HOME/.claude`, `$HOME/.claude.json`, keychain paths) that the built-in profile provides. The city gets:

- Read/write access to the city directory only
- Explicit deny rules for `$HOME/.claude` and `$HOME/.claude.json`
- Anthropic credential injection via nono's phantom token pattern (no raw API keys)
- No access to user home runtimes (`~/.cargo`, `~/.nvm`, `~/.pyenv`, etc.)

Agents that need to install tools must use `--root`/`--prefix`/`--target` flags pointing to `$CITY_PATH/.tools/`. The sandbox blocks writes to default user paths, giving the agent a chance to reconsider if it forgets.
