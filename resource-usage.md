# Invasor resource usage (core and modules)

Measured on 2026-10-03 on the Legion Go, with the service running and the 6 modules loaded (Demo off).

## Invasor idle (core + all modules)

| | Measured |
|---|---|
| **Memory (RSS)** | **38 MB** in total; about 21 MB are its own and the rest is shared system libraries |
| **CPU** | **1.1 % of one core** (30 s sample). With 16 CPU threads, that is ~0.07 % of the machine |
| **Threads** | 7 |

CPU split by thread:
- **Gamepad reader (hidraw)**, 0.43 %: the biggest consumer, because the Deck protocol sends about 250 reports per
  second even when you touch nothing. It only decodes them when the buttons change.
- **Core worker threads**, 0.60 %: they poll Steam every 3 s (window list and Steam id) and check which game is
  running (`/proc`).
- **The rest**, ~0.06 %: the main loop, the gamepad detector and Noty's server.

## Each module

Its backend, in memory and measured separately, plus the size of its UI:

| Module | Backend memory | UI (ui.js) | Idle CPU | When it works |
|---|---|---|---|---|
| Artwork | ~1 MB | 6 KB | 0 | Only when you use it: it searches for and downloads images |
| Deckico | <0.1 MB | — | 0 | A moment on every Steam start: it walks the libraries and sets icons |
| Ducky | ~0.7 MB | 8 KB | 0 | Only when options change (reads/writes a TOML file) |
| Fishy | ~2.7 MB | 10 KB | 0 | Same as Ducky |
| GE-RR | ~1.1 MB | 4 KB | 0 | On every Steam start: one GitHub query and, if there is a new version, the download |
| Noty | ~0.3 MB | 3 KB | ~0 | One thread waiting for requests; each notification is instant |

A good part of that memory is Python standard libraries (network, TOML…). If two modules use the same one, it is
loaded only once, so they don't fully add up: that is why the real total is 38 MB.

In Steam, the UI is light: the core bundle is 58 KB and the modules are 3 to 15 KB each. In the 2026-10-01 load
measurement, 11 modules added about 134 KB of JS heap and opening the panel cost ~24 ms (not repeated on
2026-10-03).

## How far it can go

The measured peaks are times (download, extraction…), not CPU or RAM; the CPU and RAM figures in this table are
estimates from the code.

| Situation | CPU | Memory | Duration |
|---|---|---|---|
| Injecting into Steam, opening the panel, switching tabs | A peak of milliseconds | Same | <0.1 s |
| Installing a zip or "Rescan" | Starts a separate Python to check the module | ~+15–20 MB in that separate process | Under 1 s, 30 s at most |
| **GE-RR downloading a new version** | ~20–30 % of one core while downloading and computing hashes (estimated); a whole core when extracting | +a few MB (reads in 1 MB blocks) | Download ~13 s and extraction ~3 s, measured on this connection. Needs ~2.2 GB of temporary disk |
| **Artwork applying an image** | Brief | Normal image (1–5 MB): +20–30 MB. **Huge image (up to 128 MB, after asking for confirmation): can exceed 0.5 GB** temporarily | Seconds |
| Deckico on Steam start | Brief, disk reads | +little | Usually under 1 s |

The only memory peak that can get big is Artwork with giant images. The image is sent to Steam as base64 over the
WebSocket, and there are several copies in memory along the way. It only happens with images over 20 MB, which
already ask for confirmation, and never above 128 MB. Possible improvement: lower that limit or send the image in
chunks.

**In short:** idle, Invasor with everything loaded takes ~38 MB and ~1 % of one core, half of that 1 % from reading
the gamepad. The peaks are occasional and caused by the user: the GE-RR and Artwork downloads.
