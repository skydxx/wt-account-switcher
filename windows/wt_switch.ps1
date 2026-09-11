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
    LauncherPath    = "C:\Program Files (x86)\Steam\steamapps\common\War Thunder\launcher.exe"
    GameDir         = "C:\Program Files (x86)\Steam\steamapps\common\War Thunder"
    SavesDir        = "$env:USERPROFILE\Documents\My Games\WarThunder"
    LaunchType      = "standalone"   # "standalone" | "steam"
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

function Detect-SteamWT {
    $path1 = "C:\Program Files (x86)\Steam\steamapps\common\War Thunder"
    $path2 = "C:\Program Files\Steam\steamapps\common\War Thunder"
    return ((Test-Path $path1) -or (Test-Path $path2))
}

function Get-LastLoginPath {
    # Steam version: lastlogin.blk is directly in SavesDir (game folder)
    # Standalone: it's in SavesDir\Saves\
    if ($Config.LaunchType -eq "steam") {
        return "$($Config.SavesDir)\lastlogin.blk"
    } else {
        return "$($Config.SavesDir)\Saves\lastlogin.blk"
    }
}

function Setup-Config {
    Write-Host "=== War Thunder Account & Region Switcher Setup ===" -ForegroundColor Cyan
    Write-Host ""

    $steamDetected = Detect-SteamWT
    Write-Host "How did you install War Thunder?"
    Write-Host "  1) Standalone launcher (WarThunderLauncher.exe)"
    Write-Host "  2) Steam"
    if ($steamDetected) { Write-Host "     (Steam installation detected on this machine)" -ForegroundColor DarkGray }

    $choice = Read-Host "Choose [1/2]"

    if ($choice -eq "2") {
        $Config.LaunchType = "steam"
        $Config.LauncherPath = "steam://rungameid/236390"

        $defGame = "C:\Program Files (x86)\Steam\steamapps\common\War Thunder"
        if (-not (Test-Path $defGame)) { $defGame = "C:\Program Files\Steam\steamapps\common\War Thunder" }
        # Default saves: same as game dir for Steam (can differ if on different drives)
        $defSaves = $defGame

        $inGame = Read-Host "Path to Game Folder (where yupartner.blk is) [$defGame]"
        if ($inGame) { $Config.GameDir = $inGame } else { $Config.GameDir = $defGame }

        Write-Host "   (can differ from game folder if game and saves are on different drives)" -ForegroundColor DarkGray
        $inSaves = Read-Host "Path to Saves Folder (where .warThunderProps.pblk is) [$defSaves]"
        if ($inSaves) { $Config.SavesDir = $inSaves } else { $Config.SavesDir = $defSaves }

        Write-Host ""
        Write-Host "ℹ️  Steam launch mode configured." -ForegroundColor Cyan
        Write-Host "   Game folder:  $($Config.GameDir)"
        Write-Host "   Saves folder: $($Config.SavesDir)"
        Write-Host "   Launch via:   steam://rungameid/236390"
    } else {
        $Config.LaunchType = "standalone"

        $defLauncher = "$($Config.LauncherPath)"
        $inLauncher = Read-Host "Path to Launcher [$defLauncher]"
        if ($inLauncher) { $Config.LauncherPath = $inLauncher }

        $defGame = $Config.GameDir
        $inGame = Read-Host "Path to Game Folder (where yupartner.blk is) [$defGame]"
        if ($inGame) { $Config.GameDir = $inGame }

        $defSaves = $Config.SavesDir
        $inSaves = Read-Host "Path to Saves Folder (where .warThunderProps.pblk is) [$defSaves]"
        if ($inSaves) { $Config.SavesDir = $inSaves }
    }

    Save-Config
    Write-Host ""
    Write-Host "✅ Configuration saved." -ForegroundColor Green
    Write-Host "   Run 'wt -h' to see available commands."
}

function Show-Help {
    Write-Host "War Thunder Account & Region Switcher (Windows)"
    Write-Host ""
    Write-Host "Region / Launch Commands:"
    Write-Host "  wt                     - Launch WT (Pixelstorm/CIS) with forced manual login"
    Write-Host "  wt global              - Launch WT (Gaijin/Global) with forced manual login"
    Write-Host "  wt steam               - Launch WT via Steam (without switching account)"
    Write-Host ""
    Write-Host "Account Commands:"
    Write-Host "  wt <name>              - Restore saved account and launch WT"
    Write-Host "  wt save pix <name>     - Save current session as Pixelstorm account"
    Write-Host "  wt save global <name>  - Save current session as Global account"
    Write-Host "  wt save steam <name>   - Save current session as Steam account"
    Write-Host "  wt list                - List saved accounts"
    Write-Host "  wt delete <name>       - Delete saved account"
    Write-Host ""
    Write-Host "Configuration Commands:"
    Write-Host "  wt config setup          - Run initial path setup"
    Write-Host "  wt config autologin on/off - Enable/disable autologin for saved accounts"
    Write-Host ""
}

function Set-Autologin([string]$state) {
    # common.blk: in Saves\ for standalone, directly in SavesDir for Steam
    $commonBlk = "$($Config.SavesDir)\Saves\common.blk"
    if (-not (Test-Path $commonBlk)) { $commonBlk = "$($Config.SavesDir)\common.blk" }
    if (Test-Path $commonBlk) {
        $content = Get-Content $commonBlk
        $content = $content -replace "autologin:b=.*", "autologin:b=$state"
        Set-Content -Path $commonBlk -Value $content -Encoding UTF8
    }
}

function Launch-WT([string]$partner, [string]$autologin) {
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
    # Use launcher icon if it's not a steam:// URL
    if ($Config.LauncherPath -notlike "steam://*") {
        $Shortcut.IconLocation = "$($Config.LauncherPath)"
    }
    $Shortcut.Save()
}

$cmd = if ($ArgsList -and $ArgsList.Count -gt 0) { $ArgsList[0] } else { "" }

if (-not (Test-Path $ConfigFile) -and $cmd -notin @("config", "-h", "--help", "help")) {
    Write-Host "Please run 'wt config setup' first." -ForegroundColor Yellow
    exit 1
}

switch ($cmd) {
    "config" {
        $subcmd = if ($ArgsList.Count -gt 1) { $ArgsList[1] } else { "" }
        $val    = if ($ArgsList.Count -gt 2) { $ArgsList[2] } else { "" }
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
        $name   = if ($ArgsList.Count -gt 2) { $ArgsList[2] } else { "" }

        if ($server -notin @("pix", "global", "steam")) {
            Write-Host "Usage: wt save pix <name> OR wt save global <name> OR wt save steam <name>"
            exit 1
        }
        if ([string]::IsNullOrEmpty($name)) { Write-Host "Usage: wt save $server <name>"; exit 1 }

        $auth1 = "$($Config.SavesDir)\.warThunderProps.pblk"
        if (-not (Test-Path $auth1)) {
            Write-Host "Error: Cannot find active session token in $($Config.SavesDir)." -ForegroundColor Red
            Write-Host "Please log into the game normally first, checking 'Save Password'." -ForegroundColor Yellow
            exit 1
        }

        $dest = "$AccountsDir\$name"
        if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

        Copy-Item $auth1 "$dest\.warThunderProps.pblk" -Force

        $lastloginSrc = Get-LastLoginPath
        if (Test-Path $lastloginSrc) { Copy-Item $lastloginSrc "$dest\lastlogin.blk" -Force }

        if ($server -eq "steam") {
            # Preserve whatever partner was active at save time
            $partnerSrc = "$($Config.GameDir)\yupartner.blk"
            if (Test-Path $partnerSrc) {
                Copy-Item $partnerSrc "$dest\yupartner.blk" -Force
            } else {
                "partner:t=`"gaijin`"" | Set-Content "$dest\yupartner.blk" -Encoding UTF8
            }
            "steam" | Set-Content "$dest\launch_type" -Encoding UTF8
        } elseif ($server -eq "pix") {
            "partner:t=`"pixelstorm`"" | Set-Content "$dest\yupartner.blk" -Encoding UTF8
            "standalone" | Set-Content "$dest\launch_type" -Encoding UTF8
        } else {
            "partner:t=`"gaijin`"" | Set-Content "$dest\yupartner.blk" -Encoding UTF8
            "standalone" | Set-Content "$dest\launch_type" -Encoding UTF8
        }

        Create-Shortcut $name

        Write-Host "✅ Account '$name' saved [$server]" -ForegroundColor Green
        Write-Host "   Shortcut created in Desktop\WT Accounts"
    }

    "list" {
        if (-not (Test-Path $AccountsDir)) { Write-Host "No saved accounts."; exit 0 }
        $dirs = Get-ChildItem $AccountsDir -Directory -ErrorAction SilentlyContinue
        if (-not $dirs -or $dirs.Count -eq 0) { Write-Host "No saved accounts."; exit 0 }
        Write-Host "Saved accounts:"
        foreach ($d in $dirs) {
            $partnerRaw   = Get-Content "$($d.FullName)\yupartner.blk" -ErrorAction SilentlyContinue
            $launchTypeRaw = Get-Content "$($d.FullName)\launch_type"  -ErrorAction SilentlyContinue
            $badge = if ($partnerRaw -like "*pixelstorm*") { "pix" } else { "global" }
            if ($launchTypeRaw -eq "steam") { $badge = "$badge/steam" }
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

    "steam" {
        # Launch via Steam without account switch
        Stop-Process -Name "WarThunderLauncher" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "aces" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200
        Write-Host "🚂 Launching War Thunder via Steam" -ForegroundColor Cyan
        Start-Process "steam://rungameid/236390"
    }

    "global" { Launch-WT "gaijin" "no" }
    "pix"    { Launch-WT "pixelstorm" "no" }

    "" {
        if (-not (Test-Path $ConfigFile)) { Show-Help }
        else { Launch-WT "pixelstorm" "no" }
    }

    { $_ -in @("-h", "--help", "help") } { Show-Help }

    default {
        $name = $cmd
        $src  = "$AccountsDir\$name"
        if (-not (Test-Path $src)) {
            Write-Host "Account '$name' not found. List accounts: wt list" -ForegroundColor Red
            exit 1
        }

        $auth1_src = "$src\.warThunderProps.pblk"
        if (-not (Test-Path $auth1_src)) {
            Write-Host "Error: Profile '$name' is corrupted (missing session token)." -ForegroundColor Red
            exit 1
        }

        Stop-Process -Name "WarThunderLauncher" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "aces" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200

        # Read profile metadata
        $profileLaunchType = (Get-Content "$src\launch_type" -ErrorAction SilentlyContinue)
        $partnerRaw        = Get-Content "$src\yupartner.blk" -ErrorAction SilentlyContinue
        $partnerStr        = if ($partnerRaw -like "*pixelstorm*") { "pixelstorm" } else { "gaijin" }
        $badge             = if ($partnerStr -eq "pixelstorm") { "pix" } else { "global" }

        # Determine correct saves dir for this profile
        $profileSavesDir = $Config.SavesDir
        $lastloginDst    = if ($profileLaunchType -eq "steam") {
            "$profileSavesDir\lastlogin.blk"
        } else {
            "$profileSavesDir\Saves\lastlogin.blk"
        }

        # Backup current session (lives only for the duration of the operation)
        $backupDir = "$profileSavesDir\wt_switcher_backup"
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
        $curAuth1 = "$profileSavesDir\.warThunderProps.pblk"
        if (Test-Path $curAuth1)    { Copy-Item $curAuth1    "$backupDir\.warThunderProps.pblk" -Force }
        if (Test-Path $lastloginDst) { Copy-Item $lastloginDst "$backupDir\lastlogin.blk" -Force }

        # Atomic replace
        try {
            Copy-Item $auth1_src "$profileSavesDir\.warThunderProps.pblk.tmp" -Force -ErrorAction Stop
            Move-Item "$profileSavesDir\.warThunderProps.pblk.tmp" "$profileSavesDir\.warThunderProps.pblk" -Force -ErrorAction Stop
        } catch {
            Write-Host "Error: Failed to restore session token." -ForegroundColor Red
            if (Test-Path $backupDir) { Remove-Item -Recurse -Force $backupDir }
            exit 1
        }

        $lastloginSrc = "$src\lastlogin.blk"
        if (Test-Path $lastloginSrc) {
            $lastloginDir = Split-Path $lastloginDst
            if (-not (Test-Path $lastloginDir)) { New-Item -ItemType Directory -Path $lastloginDir | Out-Null }
            Copy-Item $lastloginSrc "$lastloginDst.tmp" -Force -ErrorAction SilentlyContinue
            Move-Item "$lastloginDst.tmp" $lastloginDst -Force -ErrorAction SilentlyContinue
        }

        # Cleanup backup after success
        if (Test-Path $backupDir) { Remove-Item -Recurse -Force $backupDir }

        # Set partner/region
        "partner:t=`"$partnerStr`"" | Set-Content "$($Config.GameDir)\yupartner.blk" -Encoding UTF8

        $loginFlag = if ($Config.AutologinEnabled) { "yes" } else { "no" }
        Set-Autologin $loginFlag

        Write-Host "🎮 Launching '$name' [$badge] (Autologin: $loginFlag)" -ForegroundColor Cyan

        # Launch via Steam if profile was saved as steam type
        if ($profileLaunchType -eq "steam") {
            Start-Process "steam://rungameid/236390"
        } elseif ($Config.LauncherPath -like "steam://*") {
            Start-Process $Config.LauncherPath
        } else {
            Start-Process -FilePath $Config.LauncherPath
        }
    }
}
