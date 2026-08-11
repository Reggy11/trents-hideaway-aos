# Trent's Hideaway — Ace of Spades: Battle Builder

Play the original Jagex-era **Ace of Spades: Battle Builder** (2012) with us on
a private server. No Steam needed — the community revival client runs
standalone.

## Quick start (Windows)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/Reggy11/trents-hideaway-aos/main/join.ps1 | iex
```

That downloads the revival client from the official release, verifies its
checksum, extracts it to `C:\AoSRevival`, and launches the game.

Prefer to do it by hand? Grab `AoSRevival-0.1.5-win32-full.zip` from the
[official AoSRevival releases](https://github.com/KikoTs/aceofspades_revival/releases),
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
- It's alpha software: crashes happen, just relaunch. Reproducible bugs go to
  the Ace Of Spades: Community Discord #issues channel.

## Credits

The client and server are the open-source (MIT) work of
[KikoTs and the BattleSpades contributors](https://github.com/KikoTs/BattleSpades)
and the Ace Of Spades: Community revival. This repo just makes joining our
server one step. Original game by Jagex (2012), sunset 2019 — long live the
blocks.
