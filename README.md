# Trent's Hideaway — Ace of Spades

Play **Ace of Spades: Battle Builder** with us on Trent's private server.
No Steam needed — the client below runs standalone.

## Quick start (Windows)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/Reggy11/trents-hideaway-aos/main/join.ps1 | iex
```

That downloads the client from this repo's release, verifies its checksum,
extracts it to `C:\AoSRevival`, and launches the game. Run it again any time —
if the game is already installed it just launches.

Prefer to do it by hand? Download
[`AoSRevival-0.1.5-win32-full.zip`](https://github.com/Reggy11/trents-hideaway-aos/releases/download/v0.1.5/AoSRevival-0.1.5-win32-full.zip)
from this repo's [Releases](https://github.com/Reggy11/trents-hideaway-aos/releases),
extract it anywhere, and run `aos.exe`.

## Joining the server

1. Launch `aos.exe`.
2. Use **Direct Connect / server browser** and enter the address Trent gave
   you: `<SERVER_ADDRESS>:27015`
3. Pick a class and deploy.

The server runs the original Match Lobby rules, all 28 maps, and fills empty
slots with bots so small groups still get full matches.

## If the game stutters

- Right-click `aos.exe` → Properties → Compatibility → tick **Disable
  fullscreen optimisations**.
- If your gaming mouse polls at 1000 Hz+, drop it to 500 Hz — the 2012 input
  loop can choke on modern polling rates.
- Windows Settings → Mouse → turn OFF **Enhance pointer precision**.
- It's alpha-era software: if it crashes, just relaunch and rejoin.

---
*Built on the MIT-licensed BattleSpades / AoSRevival open-source projects;
the license notice ships inside the download.*
