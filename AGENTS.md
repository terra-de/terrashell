# terrashell — Terra DE Quickshell Config

System-installed Quickshell configuration for the Terra desktop environment.

## What it is

A complete Quickshell shell config that provides a modern desktop shell on Hyprland.

## How it runs

The `terrashell` wrapper (installed to `/usr/bin/terrashell`) runs:

```bash
qs -p /usr/share/terrashell/shell.qml
```

## Layout

```
/usr/share/terrashell/
├── shell.qml              # Entry point
├── app/                   # Shell entry composition
├── config/                # Defaults + user override merge
├── design/                # Reusable tokens, primitives, controls
├── features/              # Feature composition + view-models
├── services/              # OS integration, IPC, state
├── tests/                 # QML unit tests
├── utils/                 # Shared QML utilities
└── assets/                # Sound files, etc.
```

## Development

The canonical development workspace is at `~/.dots/hyprland/.config/quickshell/`.
Before tagging a terrashell release, mirror the tree here and commit.

## Key Differences from Dev Config

- `ConfigStore.qml` uses `TERRA_CONFIG_PATH` env var (not `QS_CONFIG_PATH`) for user config overrides
- The `scripts/` directory only contains dev/test scripts; user-facing commands are in `tctl`
