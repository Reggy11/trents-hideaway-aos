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

function New-HideawayShortcut {
  # Creates a .lnk that launches the game directly.
  #
  # The +s argument is what skips the Command Center. Pinning aos.exe itself to
  # the taskbar drops that argument, which is why pinning the raw exe lands you
  # on the starter window instead of in the game. A .lnk carries its arguments
  # through pinning, so pin THIS, not the exe.
  #
  # Windows has blocked scripted taskbar pinning since Windows 10, so the pin
  # itself has to be done by hand - right-click the shortcut > Pin to taskbar.
  $exe = Join-Path $dest 'aos.exe'
  if (-not (Test-Path $exe)) { return }

  $paths = @(Join-Path $dest 'Trents Hideaway.lnk')
  $desktop = [Environment]::GetFolderPath('Desktop')
  if ($desktop) { $paths += (Join-Path $desktop 'Trents Hideaway.lnk') }

  $icon = Join-Path $dest 'game.ico'
  $shell = New-Object -ComObject WScript.Shell
  foreach ($p in $paths) {
    try {
      $sc = $shell.CreateShortcut($p)
      $sc.TargetPath       = $exe
      $sc.Arguments        = '+s'
      $sc.WorkingDirectory = $dest
      $sc.Description      = "Trent's Hideaway - Ace of Spades"
      if (Test-Path $icon) { $sc.IconLocation = "$icon,0" }
      $sc.Save()
    } catch {
      # A shortcut is a convenience, never a reason to fail the install.
      Write-Host "Could not create shortcut at $p - skipping." -ForegroundColor Yellow
    }
  }
}

if (Test-Path (Join-Path $dest 'aos.exe')) {
  Write-Host 'AoSRevival already installed - launching.' -ForegroundColor Green
  # Also runs here so people who installed before shortcuts existed get one.
  New-HideawayShortcut
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

New-HideawayShortcut

Write-Host 'Launching Ace of Spades. Ask Trent for the server address!' -ForegroundColor Green
Write-Host ''
Write-Host 'TIP: a "Trents Hideaway" shortcut is now on your Desktop.' -ForegroundColor Cyan
Write-Host '     Right-click it > Pin to taskbar, and it will boot straight' -ForegroundColor Cyan
Write-Host '     into the game. Do NOT pin aos.exe directly - that skips the' -ForegroundColor Cyan
Write-Host '     shortcut and drops you on the starter window instead.' -ForegroundColor Cyan
Start-Hideaway
