# matrixstatus

Go replacement for `scripts/matrixstatus.sh`.

## Build

```sh
go build ./...
go build -o matrixstatus .
```

## CLI

```sh
matrixstatus Coffee
matrixstatus Away "out for lunch"
matrixstatus Back
matrixstatus online
matrixstatus --login
```

Running `matrixstatus` without arguments opens the desktop GUI.

## Config

Settings are stored in:

```text
~/.config/matrixstatus/config.toml
```

On first run, the app imports compatible Matrix values from:

```text
/home/chris/sirenv/scripts/.env
```

The GUI follows the system light/dark theme by default. Set `ui.theme` to
`dark`, `light`, or `system` in the config.

