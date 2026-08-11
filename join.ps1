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

function Get-HideawayLauncher {
  # Fetches our own launcher - the one with the name box and settings that
  # replaces the stock Revival Command Center.
  #
  # It is downloaded rather than shipped inside the 353 MB release on purpose:
  # updating the launcher is then a push to this repo, and nobody re-downloads
  # the client. Returns $true if the launcher is present afterwards.
  $target = Join-Path $dest 'TrentsHideaway.ps1'
  $src = 'https://raw.githubusercontent.com/Reggy11/trents-hideaway-aos/main/TrentsHideaway.ps1'
  try {
    curl.exe -L -s --fail -o $target $src
    if ((Test-Path $target) -and ((Get-Item $target).Length -gt 500)) { return $true }
  } catch { }
  Write-Host 'Could not fetch the launcher - the shortcut will start the game directly.' -ForegroundColor Yellow
  return $false
}

function New-HideawayShortcut {
  # Creates a .lnk pointing at our launcher (or, if that could not be fetched,
  # straight at the game with +s).
  #
  # +s is what skips the stock Command Center. Pinning aos.exe itself to the
  # taskbar drops that argument, which is why pinning the raw exe lands you on
  # the starter window. A .lnk carries its arguments through pinning, so pin
  # THIS, not the exe.
  #
  # Windows has blocked scripted taskbar pinning since Windows 10, so the pin
  # itself has to be done by hand - right-click the shortcut > Pin to taskbar.
  $exe = Join-Path $dest 'aos.exe'
  if (-not (Test-Path $exe)) { return }

  $launcher = Join-Path $dest 'TrentsHideaway.ps1'
  $useLauncher = Test-Path $launcher

  $paths = @(Join-Path $dest 'Trents Hideaway.lnk')
  $desktop = [Environment]::GetFolderPath('Desktop')
  if ($desktop) { $paths += (Join-Path $desktop 'Trents Hideaway.lnk') }

  $icon = Join-Path $dest 'game.ico'
  $shell = New-Object -ComObject WScript.Shell
  foreach ($p in $paths) {
    try {
      $sc = $shell.CreateShortcut($p)
      if ($useLauncher) {
        $sc.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        $sc.Arguments  = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcher`""
        $sc.WindowStyle = 7        # minimised, so no console flashes past
      } else {
        $sc.TargetPath = $exe
        $sc.Arguments  = '+s'
      }
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
  # Also runs here so people who installed before these existed get them, and so
  # re-running the one-liner is how you pick up a newer launcher.
  Get-HideawayLauncher | Out-Null
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

$haveLauncher = Get-HideawayLauncher
New-HideawayShortcut

Write-Host 'Installed.' -ForegroundColor Green
Write-Host ''
Write-Host 'A "Trents Hideaway" shortcut is now on your Desktop.' -ForegroundColor Cyan
Write-Host 'Right-click it > Pin to taskbar. Set your name in it, hit PLAY,' -ForegroundColor Cyan
Write-Host 'and it drops you straight into the server.' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Do NOT pin aos.exe directly - that bypasses the launcher and lands' -ForegroundColor Cyan
Write-Host 'you on the old starter window.' -ForegroundColor Cyan

if ($haveLauncher) {
  # Open our launcher so they can set a name before the first match, rather
  # than joining as "Player".
  Start-Process powershell -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass',
    '-WindowStyle','Hidden','-File',(Join-Path $dest 'TrentsHideaway.ps1')
} else {
  Start-Hideaway
}
