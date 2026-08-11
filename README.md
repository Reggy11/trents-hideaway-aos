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
[`AoSRevival-0.1.6-win32-full.zip`](https://github.com/Reggy11/trents-hideaway-aos/releases/download/v0.1.6/AoSRevival-0.1.6-win32-full.zip)
from this repo's [Releases](https://github.com/Reggy11/trents-hideaway-aos/releases),
extract it anywhere, and run `aos.exe`.

## Joining the server

We play over Tailscale — a free private network, so nobody has to open router
ports or share home IPs. One-time setup:

1. Install [Tailscale](https://tailscale.com/download/windows) (free) and sign
   in with the invite link Trent sends you.
2. That's it — Tailscale runs in the background from then on.

Then, every game night:

1. Make sure Tailscale is running (the tray icon says Connected).
2. Open the **Trents Hideaway** shortcut on your Desktop.
3. Type the name you want to play as, then hit **PLAY**.
4. Pick a class and deploy.

That's it — no address to type, no server list. The launcher connects you
straight to the server.

**Set your name the first time.** If you skip it you'll show up in game as
`Player`, because that's the name the client ships with.

### Pin it to your taskbar

Right-click the **Trents Hideaway** shortcut → **Pin to taskbar**.

Pin the *shortcut*, not `aos.exe`. The shortcut passes the `+s` flag that skips
the launcher window; pinning the raw `.exe` drops that flag, and you land on the
starter screen every time instead of in the game.

(`Launch Trents Hideaway.cmd` in `C:\AoSRevival` still works too — it does the
same thing, just via a console window.)

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
