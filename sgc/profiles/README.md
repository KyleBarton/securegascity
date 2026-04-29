# Nono Profiles

nono only reads profiles from `~/.config/nono/profiles/`. Files in this directory
are templates — copy them there before launching the city.

## Naming convention

`gc_<city-name>_<agent-name>.json`

## Installation

```sh
cp profiles/gc_sgc_worker.json ~/.config/nono/profiles/
```

## Adding credentials

Add named credentials to the `credentials` array. Built-in nono service routes
cover all major LLM providers.

```json
{
  "network": {
    "credentials": ["anthropic", "github"]
  }
}
```
