# Trent's Hideaway - launcher
#
# Replaces the stock "Revival Command Center". No sign-in, no public server
# list, no Discord or website links - just a name, the settings people actually
# change, and Play.
#
# It writes config_user.json (the player name) and config.txt (settings), then
# starts aos.exe with "+s" so the stock launcher never appears.
#
# Edit $ServerAddress below if the server ever moves.
# ---------------------------------------------------------------------------

$ServerAddress = '100.106.45.70:27015'   # Tailscale address of Trent's server

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Dir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$Exe      = Join-Path $Dir 'aos.exe'
$UserCfg  = Join-Path $Dir 'config_user.json'
$GameCfg  = Join-Path $Dir 'config.txt'

# --- config helpers --------------------------------------------------------
# config.txt is the client's own JSON. We only ever touch keys we have verified
# are safe; everything else is passed through untouched, so we never clobber
# keybinds, loadouts or prefab bars.

function Read-Json($path) {
    if (Test-Path -LiteralPath $path) {
        try { return (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json) } catch { }
    }
    return $null
}

function Save-Json($path, $obj) {
    $json = $obj | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding $false))
}

$user = Read-Json $UserCfg
if (-not $user) { $user = [pscustomobject]@{ username = 'Player'; language = 'english' } }
$cfg  = Read-Json $GameCfg

# --- window ----------------------------------------------------------------
$bg     = [System.Drawing.Color]::FromArgb(24,26,22)
$panel  = [System.Drawing.Color]::FromArgb(34,37,31)
$ink    = [System.Drawing.Color]::FromArgb(226,226,214)
$accent = [System.Drawing.Color]::FromArgb(214,178,58)

$form = New-Object System.Windows.Forms.Form
$form.Text            = "Trent's Hideaway"
$form.ClientSize      = New-Object System.Drawing.Size(420,470)
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox     = $false
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $bg
$form.ForeColor       = $ink
$form.Font            = New-Object System.Drawing.Font('Segoe UI',9)
$ico = Join-Path $Dir 'game.ico'
if (Test-Path -LiteralPath $ico) { try { $form.Icon = New-Object System.Drawing.Icon($ico) } catch { } }

function New-Label($text,$x,$y,$w,$size,$style,$colour) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text; $l.Left = $x; $l.Top = $y; $l.Width = $w; $l.AutoSize = $false
    $l.Height = [int]($size * 2.1)
    $l.Font = New-Object System.Drawing.Font('Segoe UI',$size,$style)
    $l.ForeColor = $colour
    $form.Controls.Add($l); return $l
}

New-Label "TRENT'S HIDEAWAY" 20 16 380 16 ([System.Drawing.FontStyle]::Bold) $accent | Out-Null
New-Label "Ace of Spades - Battle Builder" 20 46 380 9 ([System.Drawing.FontStyle]::Regular) $ink | Out-Null

# --- name ------------------------------------------------------------------
New-Label "YOUR NAME" 20 84 200 9 ([System.Drawing.FontStyle]::Bold) $accent | Out-Null
$nameBox = New-Object System.Windows.Forms.TextBox
$nameBox.Left = 20; $nameBox.Top = 106; $nameBox.Width = 380
$nameBox.MaxLength = 15
$nameBox.BackColor = $panel; $nameBox.ForeColor = $ink; $nameBox.BorderStyle = 'FixedSingle'
$nameBox.Font = New-Object System.Drawing.Font('Segoe UI',11)
$nameBox.Text = [string]$user.username
$form.Controls.Add($nameBox)

$nameHint = New-Label "" 20 134 380 8 ([System.Drawing.FontStyle]::Regular) ([System.Drawing.Color]::FromArgb(150,150,140))
$nameHint.Text = "Shown in game. Max 15 characters."

# --- settings --------------------------------------------------------------
New-Label "SETTINGS" 20 164 200 9 ([System.Drawing.FontStyle]::Bold) $accent | Out-Null

function New-Combo($label,$y,$items,$current) {
    New-Label $label 20 $y 150 9 ([System.Drawing.FontStyle]::Regular) $ink | Out-Null
    $c = New-Object System.Windows.Forms.ComboBox
    $c.Left = 180; $c.Top = ($y - 3); $c.Width = 220
    $c.DropDownStyle = 'DropDownList'
    $c.BackColor = $panel; $c.ForeColor = $ink; $c.FlatStyle = 'Flat'
    foreach ($i in $items) { [void]$c.Items.Add($i) }
    $idx = $c.Items.IndexOf($current); if ($idx -lt 0) { $idx = 0 }
    $c.SelectedIndex = $idx
    $form.Controls.Add($c); return $c
}

$modes = @('1280 x 720','1600 x 900','1920 x 1080')
$curRes = "$($cfg.width) x $($cfg.height)"
$resBox = New-Combo 'Resolution' 192 $modes $curRes

$fsBox  = New-Combo 'Display'    224 @('Windowed','Fullscreen') $(if ($cfg.fullscreen) {'Fullscreen'} else {'Windowed'})
$vsBox  = New-Combo 'VSync'      256 @('Off','On')              $(if ($cfg.vsync)      {'On'}         else {'Off'})

# Only 0/1/2 - these two are verified safe. detail_level and antialias are
# deliberately NOT exposed: detail_level rejects 2 (the stock menu then writes
# -1 and the client fails to start), and antialias cannot be enabled at all on
# this renderer because is_msaa_supported is false at runtime. Force AA from
# the graphics driver instead if you want it.
$qual = @('Low','Medium','High')
$txBox = New-Combo 'Textures' 288 $qual $qual[[Math]::Min([Math]::Max([int]$cfg.texture_quality,0),2)]
$fxBox = New-Combo 'Effects'  320 $qual $qual[[Math]::Min([Math]::Max([int]$cfg.effect_quality,0),2)]

New-Label 'Mouse sensitivity' 20 354 150 9 ([System.Drawing.FontStyle]::Regular) $ink | Out-Null
$sens = New-Object System.Windows.Forms.TrackBar
$sens.Left = 176; $sens.Top = 348; $sens.Width = 226
$sens.Minimum = 1; $sens.Maximum = 100; $sens.TickFrequency = 10
$sensVal = [int]([double]$cfg.mouse_sensitivity * 100)
$sens.Value = [Math]::Min([Math]::Max($sensVal,1),100)
$form.Controls.Add($sens)

# --- play ------------------------------------------------------------------
$play = New-Object System.Windows.Forms.Button
$play.Text = 'PLAY'
$play.Left = 20; $play.Top = 402; $play.Width = 380; $play.Height = 46
$play.FlatStyle = 'Flat'
$play.BackColor = $accent
$play.ForeColor = [System.Drawing.Color]::FromArgb(24,26,22)
$play.Font = New-Object System.Drawing.Font('Segoe UI',13,[System.Drawing.FontStyle]::Bold)
$play.FlatAppearance.BorderSize = 0
$form.Controls.Add($play)
$form.AcceptButton = $play

$play.Add_Click({
    $n = $nameBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($n)) {
        [System.Windows.Forms.MessageBox]::Show('Enter a name first.','Trents Hideaway') | Out-Null
        return
    }

    $user.username = $n
    if (-not $user.language) { $user | Add-Member -NotePropertyName language -NotePropertyValue 'english' -Force }
    Save-Json $UserCfg $user

    if ($cfg) {
        $wh = $resBox.SelectedItem -split ' x '
        $cfg.width  = [int]$wh[0]
        $cfg.height = [int]$wh[1]
        $cfg.fullscreen = ($fsBox.SelectedItem -eq 'Fullscreen')
        $cfg.vsync      = ($vsBox.SelectedItem -eq 'On')
        $cfg.texture_quality = $txBox.SelectedIndex
        $cfg.effect_quality  = $fxBox.SelectedIndex
        $cfg.mouse_sensitivity = [Math]::Round($sens.Value / 100.0, 2)
        Save-Json $GameCfg $cfg
    }

    $form.Hide()
    Start-Process -FilePath $Exe -ArgumentList '+s','+connect',$ServerAddress -WorkingDirectory $Dir
    $form.Close()
})

[void]$form.ShowDialog()
