# sgc-guide: Secure Gas City Quick Reference

## What is this sandbox?

You are running inside a **nono** kernel-enforced sandbox. Your `$HOME` is redirected to the city directory (not `~/.claude` of the host user). This prevents identity bleed: you cannot read the host user's Claude config, credentials, or personal files.

The city directory is your workspace. Everything outside it is off-limits by the OS.

## Starting and restarting the city

```bash
# From the city directory
cd "$CITY_PATH" && gc start

# Restart (picks up config changes)
cd "$CITY_PATH" && gc restart
```

## Adding a rig

```bash
gc rig add /path/to/rig
```

The file-based provider has no Dolt conflict, so `gc rig add` works cleanly without extra steps.

## Installing tools

The sandbox blocks writes to default user paths (`~/.cargo`, `~/.nvm`, etc.). Use explicit prefix flags:

```bash
# Rust / cargo
cargo install --root "$CITY_PATH/.tools" <crate>

# npm (global-style)
npm install --prefix "$CITY_PATH/.tools" <package>

# Python wheels
pip install --target "$CITY_PATH/.tools/lib/python" <package>
```

Add `$CITY_PATH/.tools/bin` to `$PATH` if you need installed binaries on the path.

## When a tool fails reading a home-dir path

The sandbox redirects `$HOME` to `$CITY_PATH/home`. If a tool looks for config at `~/.toolrc` and fails, seed the file there:

```bash
# Write config into the redirected home, not the real ~
echo "..." > "$HOME/.toolrc"
```

`sgc-init.sh` pre-seeds `$HOME/.gitconfig` for git. Other tools may need similar seeding.

## Troubleshooting

**git fails with "Please tell me who you are"**
`$HOME/.gitconfig` is missing. Check that `sgc-init.sh` ran successfully:
```bash
ls "$HOME/.gitconfig"
```
If absent, create it:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

**Permission denied on a path outside the city**
The sandbox is blocking the access intentionally. Move the resource inside `$CITY_PATH` or ask the city operator to add an `--allow` flag when launching nono.

**Tool writes to `~/.cargo` and fails**
Use `--root "$CITY_PATH/.tools"` as shown in the Installing tools section above.
