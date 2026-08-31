param (
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ArgsList
)

$ConfigDir = "$env:APPDATA\WT_Switcher"
$ConfigFile = "$ConfigDir\config.json"
$AccountsDir = "$ConfigDir\accounts"
$ShortcutsDir = "$env:USERPROFILE\Desktop\WT Accounts"

# Default config
$Config = @{
    LauncherPath = "steam://rungameid/236390"
    GameDir = "C:\Program Files (x86)\Steam\steamapps\common\War Thunder"
    SavesDir = "$env:USERPROFILE\Documents\My Games\WarThunder"
    AutologinEnabled = $true
}

if (Test-Path $ConfigFile) {
    $loaded = Get-Content $ConfigFile | ConvertFrom-Json
    foreach ($prop in $loaded.psobject.properties) {
        $Config[$prop.Name] = $prop.Value
    }
}

function Save-Config {
    if (-not (Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir | Out-Null }
    $Config | ConvertTo-Json | Set-Content $ConfigFile
}

function Setup-Config {
    Write-Host "=== War Thunder Account Switcher Setup ===" -ForegroundColor Cyan
    
    $inLauncher = Read-Host "Path to Launcher [$($Config.LauncherPath)]"
    if ($inLauncher) { $Config.LauncherPath = $inLauncher }

    $inGame = Read-Host "Path to Game Folder (where yupartner.blk is) [$($Config.GameDir)]"
    if ($inGame) { $Config.GameDir = $inGame }

    $inSaves = Read-Host "Path to Saves Folder (where .warThunderProps.pblk is) [$($Config.SavesDir)]"
    if ($inSaves) { $Config.SavesDir = $inSaves }

    Save-Config
    Write-Host "✅ Configuration saved." -ForegroundColor Green
}

function Show-Help {
    Write-Host "War Thunder Account Switcher (Windows)"
    Write-Host ""
    Write-Host "Launch Commands:"
    Write-Host "  wt                     - Launch WT (Pixelstorm) without autologin"
    Write-Host "  wt global              - Launch WT (Global) without autologin"
    Write-Host "  wt <name>              - Launch saved account"
    Write-Host ""
    Write-Host "Management Commands:"
    Write-Host "  wt save pix <name>     - Save current session as Pixelstorm account"
    Write-Host "  wt save global <name>  - Save current session as Global account"
    Write-Host "  wt list                - List saved accounts"
    Write-Host "  wt delete <name>       - Delete saved account"
    Write-Host ""
    Write-Host "Configuration Commands:"
    Write-Host "  wt config setup          - Run initial path setup"
    Write-Host "  wt config autologin on/off - Enable/disable autologin for saved accounts"
    Write-Host ""
}

function Set-Autologin([string]$state) {
    $commonBlk = "$($Config.SavesDir)\Saves\common.blk"
    if (Test-Path $commonBlk) {
        $content = Get-Content $commonBlk
        $content = $content -replace "autologin:b=.*", "autologin:b=$state"
        Set-Content -Path $commonBlk -Value $content -Encoding UTF8
    }
}

function Launch-WT([string]$partner, [string]$autologin) {
    # Kill processes
    Stop-Process -Name "WarThunderLauncher" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "aces" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 200

    Set-Autologin $autologin
    
    $partnerFile = "$($Config.GameDir)\yupartner.blk"
    if (Test-Path $Config.GameDir) {
        "partner:t=`"$partner`"" | Set-Content -Path $partnerFile -Encoding UTF8
    }

    $badge = if ($partner -eq "pixelstorm") { "pix" } else { "global" }
    Write-Host "🎮 Launching War Thunder [$badge] (Autologin: $autologin)" -ForegroundColor Cyan
    
    if ($Config.LauncherPath -like "steam://*") {
        Start-Process $Config.LauncherPath
    } else {
        Start-Process -FilePath $Config.LauncherPath
    }
}

function Create-Shortcut([string]$name) {
    if (-not (Test-Path $ShortcutsDir)) { New-Item -ItemType Directory -Path $ShortcutsDir | Out-Null }
    
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$ShortcutsDir\$name.lnk")
    $Shortcut.TargetPath = "cmd.exe"
    $Shortcut.Arguments = "/c wt $name"
    $Shortcut.IconLocation = "$($Config.LauncherPath)"
    $Shortcut.Save()
}

$cmd = if ($ArgsList.Count -gt 0) { $ArgsList[0] } else { "" }

if (-not (Test-Path $ConfigFile) -and $cmd -notin @("config", "-h", "--help")) {
    Write-Host "Please run 'wt config setup' first." -ForegroundColor Yellow
    exit 1
}

switch ($cmd) {
    "config" {
        $subcmd = if ($ArgsList.Count -gt 1) { $ArgsList[1] } else { "" }
        $val = if ($ArgsList.Count -gt 2) { $ArgsList[2] } else { "" }
        if ($subcmd -eq "setup") { Setup-Config }
        elseif ($subcmd -eq "autologin") {
            if ($val -eq "on" -or $val -eq "off") {
                $Config.AutologinEnabled = ($val -eq "on")
                Save-Config
                Write-Host "Autologin for saved accounts: $val" -ForegroundColor Green
            } else { Write-Host "Usage: wt config autologin on/off" }
        }
        else { Write-Host "Unknown config command. See wt -h" }
    }
    "save" {
        $server = if ($ArgsList.Count -gt 1) { $ArgsList[1] } else { "" }
        $name = if ($ArgsList.Count -gt 2) { $ArgsList[2] } else { "" }

        if ($server -notin @("pix", "global")) { Write-Host "Usage: wt save pix <name> OR wt save global <name>"; exit 1 }
        if ([string]::IsNullOrEmpty($name)) { Write-Host "Usage: wt save $server <name>"; exit 1 }
        
        $auth1 = "$($Config.SavesDir)\.warThunderProps.pblk"
        if (-not (Test-Path $auth1)) {
            Write-Host "Error: Cannot find active session token in $($Config.SavesDir)." -ForegroundColor Red
            Write-Host "Please log into the game normally first, checking 'Save Password'." -ForegroundColor Yellow
            exit 1
        }

        $dest = "$AccountsDir\$name"
        if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

        $auth2 = "$($Config.SavesDir)\Saves\lastlogin.blk"
        if (Test-Path $auth1) { Copy-Item $auth1 "$dest\.warThunderProps.pblk" -Force }
        if (Test-Path $auth2) { Copy-Item $auth2 "$dest\lastlogin.blk" -Force }

        $partnerStr = if ($server -eq "pix") { "pixelstorm" } else { "gaijin" }
        "partner:t=`"$partnerStr`"" | Set-Content "$dest\yupartner.blk" -Encoding UTF8

        Create-Shortcut $name

        Write-Host "✅ Account '$name' saved [$server]" -ForegroundColor Green
        Write-Host "   Shortcut created in Desktop\WT Accounts"
    }
    "list" {
        if (-not (Test-Path $AccountsDir)) { Write-Host "No saved accounts."; exit 0 }
        $dirs = Get-ChildItem $AccountsDir -Directory
        if ($dirs.Count -eq 0) { Write-Host "No saved accounts."; exit 0 }
        Write-Host "Saved accounts:"
        foreach ($d in $dirs) {
            $partnerRaw = Get-Content "$($d.FullName)\yupartner.blk" -ErrorAction SilentlyContinue
            $badge = if ($partnerRaw -like "*pixelstorm*") { "pix" } else { "global" }
            Write-Host "  • $($d.Name)  [$badge]"
        }
    }
    "delete" {
        $name = if ($ArgsList.Count -gt 1) { $ArgsList[1] } else { "" }
        if ([string]::IsNullOrEmpty($name)) { Write-Host "Usage: wt delete <name>"; exit 1 }
        $dest = "$AccountsDir\$name"
        if (-not (Test-Path $dest)) { Write-Host "Account '$name' not found"; exit 1 }
        Remove-Item -Recurse -Force $dest
        $link = "$ShortcutsDir\$name.lnk"
        if (Test-Path $link) { Remove-Item $link }
        Write-Host "🗑️ Account '$name' deleted"
    }
    "global" { Launch-WT "gaijin" "no" }
    "pix" { Launch-WT "pixelstorm" "no" }
    "" { 
        if (-not (Test-Path $ConfigFile)) { Show-Help }
        else { Launch-WT "pixelstorm" "no" }
    }
    "-h" { Show-Help }
    "--help" { Show-Help }
    "help" { Show-Help }
    default {
        $name = $cmd
        $src = "$AccountsDir\$name"
        if (-not (Test-Path $src)) { Write-Host "Account '$name' not found. List accounts: wt list" -ForegroundColor Red; exit 1 }

        $auth1_src = "$src\.warThunderProps.pblk"
        if (-not (Test-Path $auth1_src)) {
            Write-Host "Error: Profile '$name' is corrupted (missing session token)." -ForegroundColor Red
            exit 1
        }

        Stop-Process -Name "WarThunderLauncher" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "aces" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200

        # Backup current session
        $backupDir = "$($Config.SavesDir)\Saves\wt_switcher_backup"
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
        
        $auth1 = "$($Config.SavesDir)\.warThunderProps.pblk"
        $auth2 = "$($Config.SavesDir)\Saves\lastlogin.blk"
        if (Test-Path $auth1) { Copy-Item $auth1 "$backupDir\.warThunderProps.pblk" -Force }
        if (Test-Path $auth2) { Copy-Item $auth2 "$backupDir\lastlogin.blk" -Force }

        # Perform copy with atomic move
        try {
            Copy-Item $auth1_src "$($Config.SavesDir)\.warThunderProps.pblk.tmp" -Force -ErrorAction Stop
            Move-Item "$($Config.SavesDir)\.warThunderProps.pblk.tmp" "$($Config.SavesDir)\.warThunderProps.pblk" -Force -ErrorAction Stop
        } catch {
            Write-Host "Error: Failed to restore session token." -ForegroundColor Red
            exit 1
        }
        
        $savesSubDir = "$($Config.SavesDir)\Saves"
        if (-not (Test-Path $savesSubDir)) { New-Item -ItemType Directory -Path $savesSubDir | Out-Null }
        
        $auth2_src = "$src\lastlogin.blk"
        if (Test-Path $auth2_src) {
            Copy-Item $auth2_src "$savesSubDir\lastlogin.blk.tmp" -Force -ErrorAction SilentlyContinue
            Move-Item "$savesSubDir\lastlogin.blk.tmp" "$savesSubDir\lastlogin.blk" -Force -ErrorAction SilentlyContinue
        }

        # Cleanup backup since operation succeeded atomically
        if (Test-Path $backupDir) { Remove-Item -Recurse -Force $backupDir }

        $partnerRaw = Get-Content "$src\yupartner.blk"
        $partnerStr = if ($partnerRaw -like "*pixelstorm*") { "pixelstorm" } else { "gaijin" }

        $loginFlag = if ($Config.AutologinEnabled) { "yes" } else { "no" }

        Set-Autologin $loginFlag
        "partner:t=`"$partnerStr`"" | Set-Content "$($Config.GameDir)\yupartner.blk" -Encoding UTF8

        $badge = if ($partnerStr -eq "pixelstorm") { "pix" } else { "global" }
        Write-Host "🎮 Launching '$name' [$badge] (Autologin: $loginFlag)" -ForegroundColor Cyan
        
        if ($Config.LauncherPath -like "steam://*") {
            Start-Process $Config.LauncherPath
        } else {
            Start-Process -FilePath $Config.LauncherPath
        }
    }
}
