# Trent's Hideaway — one-step joiner for Ace of Spades: Battle Builder.
# Downloads the official AoSRevival client release, verifies its SHA256,
# extracts to C:\AoSRevival, and launches the game.

$ErrorActionPreference = 'Stop'

$version = '0.1.5'
$zipName = "AoSRevival-$version-win32-full.zip"
$url = "https://github.com/Reggy11/trents-hideaway-aos/releases/download/v$version/$zipName"
$expected = 'a6f81797cb58b01dbefec92ee4466de6645f05e61a76d74c5647a875e8b327c0'
$dest = 'C:\AoSRevival'

function Start-Hideaway {
  # Split local boot: the server-list URL points at an unreachable local
  # address (no revival registry contact) and +s skips the Command Center.
  $env:AOS_SERVER_LIST_URL = 'http://127.0.0.1:9/serverlist'
  Start-Process -FilePath (Join-Path $dest 'aos.exe') -ArgumentList '+s' -WorkingDirectory $dest
}

if (Test-Path (Join-Path $dest 'aos.exe')) {
  Write-Host 'AoSRevival already installed - launching.' -ForegroundColor Green
  Start-Hideaway
  return
}

New-Item -ItemType Directory -Force $dest | Out-Null
$zipPath = Join-Path $dest $zipName

Write-Host "Downloading $zipName (~353 MB) from the official release..." -ForegroundColor Cyan
curl.exe -L --progress-bar -o $zipPath $url

Write-Host 'Verifying SHA256 checksum...' -ForegroundColor Cyan
$hash = (Get-FileHash -Algorithm SHA256 $zipPath).Hash.ToLower()
if ($hash -ne $expected) {
  Remove-Item $zipPath -Force -Confirm:$false
  throw "Checksum mismatch (got $hash) - download corrupted or tampered. Nothing was installed."
}
Write-Host 'Checksum OK.' -ForegroundColor Green

Write-Host 'Extracting...' -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $dest -Force
Remove-Item $zipPath -Force -Confirm:$false

# Leave a double-clickable launcher behind for future sessions.
@"
@echo off
set AOS_SERVER_LIST_URL=http://127.0.0.1:9/serverlist
start "" /D "$dest" "$dest\aos.exe" +s
"@ | Set-Content -Path (Join-Path $dest 'Launch Trents Hideaway.cmd') -Encoding ascii

Write-Host 'Launching Ace of Spades. Ask Trent for the server address!' -ForegroundColor Green
Write-Host "Next time, just run '$dest\Launch Trents Hideaway.cmd'." -ForegroundColor Cyan
Start-Hideaway
