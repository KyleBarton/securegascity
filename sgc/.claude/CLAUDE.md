# City-Scoped Agent Configuration

This directory is the `CLAUDE_CONFIG_DIR` for all agents in this Gas City instance.
It is intentionally separate from the user's personal `~/.claude` so agents do not
inherit personal settings, memory, credentials, or session history.

## Identity isolation

Agents running in this city share the identity defined here, not the user's personal
Claude identity. Do not reference or attempt to access `~/.claude`.

## Behavior

Follow the instructions in `AGENTS.md` at the city root. The nono sandbox enforces
the filesystem boundary at the OS level — capability restrictions are not advisory.
