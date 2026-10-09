# Invasor workspace

The folder that holds the [Invasor](invasor) core and its module repositories side by side, as
`invasor/docs/MODULES.md` (section 8) expects: every module finds the core's tools and build kit in `../invasor`.

This repository only has what ties them together; each repository inside keeps its own history.

| File | What it does |
|---|---|
| `repos.conf` | The list of repositories: the core and one per module |
| `.github/workflows/market.yml` | Every 12 hours it generates `market.json`, the module market's catalog, from `repos.conf` and the repositories' releases, and publishes it on the `market-data` branch |
| `bootstrap.sh` | Clones what is missing from `repos.conf` and checks the build tools |
| `build-core.sh` | Builds the core's installable `invasor-<version>.tar.gz` into `dist/` |
| `build-modules.sh` | Builds the installable zip of every module into `dist/` |
| `resource-usage.md` | Measured CPU and memory use of the core and each module |

## Starting on a new machine
```sh
git clone git@github.com:Gamemode-Invasor/invasor-workspace.git proyecto-invasor && cd proyecto-invasor
./bootstrap.sh git@github.com:Gamemode-Invasor
(cd invasor/frontend && npm install)
./build-core.sh && ./build-modules.sh       # results in dist/
```

## Adding a module repository
Create it next to the others and add its folder name to `repos.conf`. Once it has a release (a zip and its `.sha256`, see
`invasor/docs/MODULES.md`) it shows up in the Invasor market within about an hour.

## License
[GNU General Public License v3.0 or later](LICENSE) (GPL-3.0-or-later).
