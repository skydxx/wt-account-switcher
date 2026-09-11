#!/usr/bin/env zsh
# War Thunder Account & Region Switcher (Mac/Linux)

_WT_CONFIG_DIR="$HOME/.config/wt_switcher"
_WT_CONFIG_FILE="$_WT_CONFIG_DIR/config.env"
_WT_ACCOUNTS_DIR="$_WT_CONFIG_DIR/accounts"
_WT_RAYCAST_DIR="$HOME/raycast-scripts"

# Default config values
WT_LAUNCHER_PATH=""
WT_GAME_DIR=""
WT_SAVES_DIR=""
WT_LAUNCH_TYPE=""    # "standalone" | "steam"
RAYCAST_ENABLED="off"
AUTOLOGIN_ENABLED="on"

# Load config if exists
if [[ -f "$_WT_CONFIG_FILE" ]]; then
    source "$_WT_CONFIG_FILE"
fi

_wt_save_config() {
    # Ensure config and accounts are private
    umask 077
    mkdir -p "$_WT_CONFIG_DIR"
    cat > "$_WT_CONFIG_FILE" << EOF
WT_LAUNCHER_PATH="$WT_LAUNCHER_PATH"
WT_GAME_DIR="$WT_GAME_DIR"
WT_SAVES_DIR="$WT_SAVES_DIR"
WT_LAUNCH_TYPE="$WT_LAUNCH_TYPE"
RAYCAST_ENABLED="$RAYCAST_ENABLED"
AUTOLOGIN_ENABLED="$AUTOLOGIN_ENABLED"
EOF
}

_wt_detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    else
        echo "linux"
    fi
}

_wt_detect_steam() {
    local os=$(_wt_detect_os)
    if [[ "$os" == "mac" ]]; then
        # Check both default Steam locations on Mac
        local steam_path1="$HOME/Library/Application Support/Steam/steamapps/common/War Thunder"
        local steam_path2="/Applications/Steam.app"
        [[ -d "$steam_path1" ]] && echo "yes" && return
        [[ -d "$steam_path2" ]] && echo "maybe" && return
    else
        local steam_path1="$HOME/.steam/steam/steamapps/common/War Thunder"
        local steam_path2="$HOME/.local/share/Steam/steamapps/common/War Thunder"
        [[ -d "$steam_path1" || -d "$steam_path2" ]] && echo "yes" && return
    fi
    echo "no"
}

_wt_setup() {
    local os=$(_wt_detect_os)
    local steam_detected=$(_wt_detect_steam)

    echo "=== War Thunder Account & Region Switcher Setup ==="
    echo ""

    # Ask installation type
    echo "How did you install War Thunder?"
    echo "  1) Standalone launcher (WarThunderLauncher.app / WarThunderLauncher.exe)"
    echo "  2) Steam"
    if [[ "$steam_detected" == "yes" ]]; then
        echo "     (Steam installation detected on this machine)"
    fi
    echo -n "Choose [1/2]: "
    read launch_choice

    if [[ "$launch_choice" == "2" ]]; then
        WT_LAUNCH_TYPE="steam"
        WT_LAUNCHER_PATH="steam://rungameid/236390"

        if [[ "$os" == "mac" ]]; then
            local steam_game_default="$HOME/Library/Application Support/Steam/steamapps/common/War Thunder"
            # On Mac Steam, .warThunderProps.pblk typically lives in the game folder itself
            local steam_saves_default="$steam_game_default"
        else
            local steam_game_default1="$HOME/.steam/steam/steamapps/common/War Thunder"
            local steam_game_default2="$HOME/.local/share/Steam/steamapps/common/War Thunder"
            local steam_game_default="$steam_game_default1"
            [[ -d "$steam_game_default2" ]] && steam_game_default="$steam_game_default2"
            # On Linux Steam, same — game folder contains the saves
            local steam_saves_default="$steam_game_default"
        fi

        echo -n "Path to War Thunder game folder (where yupartner.blk is) [$steam_game_default]: "
        read input_game
        WT_GAME_DIR="${input_game:-$steam_game_default}"

        echo -n "Path to Saves folder (where .warThunderProps.pblk is) [$steam_saves_default]: "
        echo "   (can be different if game and saves are on different drives)"
        read input_saves
        WT_SAVES_DIR="${input_saves:-$steam_saves_default}"

        echo ""
        echo "ℹ️  Steam launch mode configured."
        echo "   Game folder:  $WT_GAME_DIR"
        echo "   Saves folder: $WT_SAVES_DIR"
        echo "   Launch via:   steam://rungameid/236390"
    else
        WT_LAUNCH_TYPE="standalone"

        if [[ "$os" == "mac" ]]; then
            local def_launcher="/Applications/WarThunderLauncher.app"
            local def_game="$def_launcher/Contents/WarThunder.app/Contents/Resources/game"
            local def_saves="$HOME/My Games/WarThunder"
        else
            local def_launcher="$HOME/Games/WarThunderLauncher/WarThunderLauncher"
            local def_game="$HOME/Games/WarThunder"
            local def_saves="$HOME/.config/WarThunder"
        fi

        echo -n "Path to Launcher [$def_launcher]: "
        read input_launcher
        WT_LAUNCHER_PATH="${input_launcher:-$def_launcher}"

        echo -n "Path to Game Folder (where yupartner.blk is) [$def_game]: "
        read input_game
        WT_GAME_DIR="${input_game:-$def_game}"

        echo -n "Path to Saves Folder (where .warThunderProps.pblk is) [$def_saves]: "
        read input_saves
        WT_SAVES_DIR="${input_saves:-$def_saves}"
    fi

    _wt_save_config
    echo ""
    echo "✅ Configuration saved to $_WT_CONFIG_FILE"
    echo "   Run 'wt -h' to see available commands."
}

_wt_usage() {
    echo "War Thunder Account & Region Switcher"
    echo ""
    echo "Region / Launch Commands:"
    echo "  wt                     — Launch WT (Pixelstorm/CIS) with forced manual login"
    echo "  wt global              — Launch WT (Gaijin/Global) with forced manual login"
    echo "  wt steam               — Launch WT via Steam (without switching account)"
    echo ""
    echo "Account Commands:"
    echo "  wt <name>              — Restore saved account and launch WT"
    echo "  wt save pix <name>     — Save current session as Pixelstorm account"
    echo "  wt save global <name>  — Save current session as Global account"
    echo "  wt save steam <name>   — Save current session as Steam account"
    echo "  wt list                — List saved accounts"
    echo "  wt delete <name>       — Delete saved account"
    echo ""
    echo "Configuration Commands:"
    echo "  wt config setup          — Run initial path setup"
    echo "  wt config raycast on/off — Enable/disable Raycast script generation (Mac only)"
    echo "  wt config autologin on/off — Enable/disable autologin for saved accounts"
    echo ""
}

_wt_set_autologin() {
    local state="$1" # yes or no
    local common_blk="$WT_SAVES_DIR/Saves/common.blk"
    # For Steam, common.blk may be directly in the saves dir (no Saves/ subfolder)
    [[ ! -f "$common_blk" ]] && common_blk="$WT_SAVES_DIR/common.blk"
    if [[ -f "$common_blk" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/autologin:b=.*/autologin:b=$state/" "$common_blk"
        else
            sed -i "s/autologin:b=.*/autologin:b=$state/" "$common_blk"
        fi
    fi
}

_wt_get_saves_lastlogin_path() {
    # Returns the correct path to lastlogin.blk depending on install type
    if [[ "$WT_LAUNCH_TYPE" == "steam" ]]; then
        echo "$WT_SAVES_DIR/lastlogin.blk"
    else
        echo "$WT_SAVES_DIR/Saves/lastlogin.blk"
    fi
}

_wt_launch() {
    local partner="$1"  # pixelstorm | gaijin
    local force_autologin="$2"  # yes | no

    # Kill processes
    pkill -9 -f "WarThunderLauncher" 2>/dev/null || true
    pkill -9 -f "aces" 2>/dev/null || true
    sleep 0.2

    _wt_set_autologin "$force_autologin"

    if [[ -d "$WT_GAME_DIR" ]]; then
        echo "partner:t=\"$partner\"" > "$WT_GAME_DIR/yupartner.blk"
    fi

    local badge
    [[ "$partner" == "pixelstorm" ]] && badge="pix" || badge="global"

    echo "🎮 Launching War Thunder [$badge] (Autologin: $force_autologin)"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ "$WT_LAUNCHER_PATH" == steam://* ]]; then
            open "$WT_LAUNCHER_PATH"
        else
            open "$WT_LAUNCHER_PATH"
        fi
    else
        if [[ "$WT_LAUNCHER_PATH" == steam://* ]]; then
            xdg-open "$WT_LAUNCHER_PATH"
        else
            "$WT_LAUNCHER_PATH" &
        fi
    fi
}

_wt_create_shortcut() {
    local name="$1"
    local server="$2"

    if [[ "$RAYCAST_ENABLED" == "on" && "$OSTYPE" == "darwin"* ]]; then
        mkdir -p "$_WT_RAYCAST_DIR"
        local icon="🎮"
        [[ "$server" == "global" ]] && icon="🌍"
        [[ "$server" == "steam" ]] && icon="🚂"
        local script_path="$_WT_RAYCAST_DIR/wt-${name}.sh"
        cat > "$script_path" << SCRIPT
#!/usr/bin/env zsh
# @raycast.schemaVersion 1
# @raycast.title wt $name
# @raycast.mode silent
# @raycast.packageName War Thunder
# @raycast.icon $icon
# @raycast.description [$server] Launch War Thunder account

source "\$HOME/.config/wt_switcher/wt_switch.sh"
wt "$name"
SCRIPT
        chmod +x "$script_path"
    fi
}

wt() {
    local cmd="$1"

    # Require setup if paths are missing
    if [[ -z "$WT_LAUNCHER_PATH" && "$cmd" != "config" && "$cmd" != "-h" && "$cmd" != "--help" && "$cmd" != "help" && "$cmd" != "" ]]; then
        echo "Please run 'wt config setup' first."
        return 1
    fi

    case "$cmd" in
        config)
            local subcmd="$2"
            local val="$3"
            case "$subcmd" in
                setup) _wt_setup ;;
                raycast)
                    if [[ "$val" == "on" || "$val" == "off" ]]; then
                        RAYCAST_ENABLED="$val"
                        _wt_save_config
                        echo "Raycast generation: $val"
                    else
                        echo "Usage: wt config raycast on/off"
                    fi
                    ;;
                autologin)
                    if [[ "$val" == "on" || "$val" == "off" ]]; then
                        AUTOLOGIN_ENABLED="$val"
                        _wt_save_config
                        echo "Autologin for saved accounts: $val"
                    else
                        echo "Usage: wt config autologin on/off"
                    fi
                    ;;
                *) echo "Unknown config command. See wt -h" ;;
            esac
            ;;

        save)
            local server="$2"
            local name="$3"

            if [[ "$server" != "pix" && "$server" != "global" && "$server" != "steam" ]]; then
                echo "Usage: wt save pix <name> OR wt save global <name> OR wt save steam <name>"
                return 1
            fi
            if [[ -z "$name" ]]; then
                echo "Usage: wt save $server <name>"
                return 1
            fi

            if [[ ! -f "$WT_SAVES_DIR/.warThunderProps.pblk" ]]; then
                echo "Error: Cannot find active session token in '$WT_SAVES_DIR'."
                echo "Please log into the game normally first, checking 'Save Password'."
                return 1
            fi

            local dest="$_WT_ACCOUNTS_DIR/$name"
            umask 077
            mkdir -p "$dest"

            # Copy auth files
            cp "$WT_SAVES_DIR/.warThunderProps.pblk" "$dest/.warThunderProps.pblk" 2>/dev/null

            local lastlogin_src=$(_wt_get_saves_lastlogin_path)
            [[ -f "$lastlogin_src" ]] && cp "$lastlogin_src" "$dest/lastlogin.blk" 2>/dev/null

            # Save region / launch type metadata
            if [[ "$server" == "pix" ]]; then
                echo 'partner:t="pixelstorm"' > "$dest/yupartner.blk"
                echo "standalone" > "$dest/launch_type"
            elif [[ "$server" == "steam" ]]; then
                # Preserve whichever partner was active
                [[ -f "$WT_GAME_DIR/yupartner.blk" ]] && cp "$WT_GAME_DIR/yupartner.blk" "$dest/yupartner.blk" \
                    || echo 'partner:t="gaijin"' > "$dest/yupartner.blk"
                echo "steam" > "$dest/launch_type"
            else
                echo 'partner:t="gaijin"' > "$dest/yupartner.blk"
                echo "standalone" > "$dest/launch_type"
            fi

            _wt_create_shortcut "$name" "$server"

            echo "✅ Account '$name' saved [$server]"
            [[ "$RAYCAST_ENABLED" == "on" ]] && echo "   Raycast script updated."
            ;;

        list)
            if [[ ! -d "$_WT_ACCOUNTS_DIR" ]] || [[ -z "$(ls -A "$_WT_ACCOUNTS_DIR" 2>/dev/null)" ]]; then
                echo "No saved accounts."
                return 0
            fi
            echo "Saved accounts:"
            for d in "$_WT_ACCOUNTS_DIR"/*/; do
                [[ -d "$d" ]] || continue
                local n=$(basename "$d")
                local partner_raw badge launch_type_raw
                partner_raw=$(cat "$d/yupartner.blk" 2>/dev/null)
                launch_type_raw=$(cat "$d/launch_type" 2>/dev/null)
                [[ "$partner_raw" == *pixelstorm* ]] && badge="pix" || badge="global"
                [[ "$launch_type_raw" == "steam" ]] && badge="$badge/steam"
                echo "  • $n  [$badge]"
            done
            ;;

        delete)
            local name="$2"
            if [[ -z "$name" ]]; then
                echo "Usage: wt delete <name>"
                return 1
            fi
            local dest="$_WT_ACCOUNTS_DIR/$name"
            if [[ ! -d "$dest" ]]; then
                echo "Account '$name' not found"
                return 1
            fi
            rm -rf "$dest"
            rm -f "$_WT_RAYCAST_DIR/wt-${name}.sh"
            echo "🗑️  Account '$name' deleted"
            ;;

        global)
            _wt_launch "gaijin" "no"
            ;;

        steam)
            # Launch via Steam without switching account (just open Steam launch URL)
            pkill -9 -f "WarThunderLauncher" 2>/dev/null || true
            pkill -9 -f "aces" 2>/dev/null || true
            sleep 0.2
            echo "🚂 Launching War Thunder via Steam"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open "steam://rungameid/236390"
            else
                xdg-open "steam://rungameid/236390"
            fi
            ;;

        ""|pix)
            if [[ -z "$WT_LAUNCHER_PATH" ]]; then
                _wt_usage
            else
                _wt_launch "pixelstorm" "no"
            fi
            ;;

        --help|-h|help)
            _wt_usage
            ;;

        *)
            local name="$cmd"
            local src="$_WT_ACCOUNTS_DIR/$name"
            if [[ ! -d "$src" ]]; then
                echo "Account '$name' not found. List accounts: wt list"
                return 1
            fi
            if [[ ! -f "$src/.warThunderProps.pblk" ]]; then
                echo "Error: Profile '$name' is corrupted (missing session token)."
                return 1
            fi

            pkill -9 -f "WarThunderLauncher" 2>/dev/null || true
            pkill -9 -f "aces" 2>/dev/null || true
            sleep 0.2

            # Read profile metadata
            local profile_launch_type=$(cat "$src/launch_type" 2>/dev/null)
            local partner_raw partner badge
            partner_raw=$(cat "$src/yupartner.blk" 2>/dev/null)
            if [[ "$partner_raw" == *pixelstorm* ]]; then
                partner="pixelstorm"
                badge="pix"
            else
                partner="gaijin"
                badge="global"
            fi

            # Determine where to write saves for this profile
            local profile_saves_dir="$WT_SAVES_DIR"
            local profile_lastlogin_dst
            if [[ "$profile_launch_type" == "steam" ]]; then
                # Steam: saves are in game dir, no Saves/ subfolder for lastlogin
                profile_saves_dir="$WT_GAME_DIR"
                profile_lastlogin_dst="$profile_saves_dir/lastlogin.blk"
            else
                profile_lastlogin_dst="$WT_SAVES_DIR/Saves/lastlogin.blk"
            fi

            # Backup current active session
            local backup_dir="$WT_SAVES_DIR/Saves/wt_switcher_backup"
            mkdir -p "$backup_dir"
            [[ -f "$profile_saves_dir/.warThunderProps.pblk" ]] && cp "$profile_saves_dir/.warThunderProps.pblk" "$backup_dir/"
            [[ -f "$profile_lastlogin_dst" ]] && cp "$profile_lastlogin_dst" "$backup_dir/"

            # Atomic replace: copy to .tmp first, then mv
            cp "$src/.warThunderProps.pblk" "$profile_saves_dir/.warThunderProps.pblk.tmp" 2>/dev/null || {
                echo "Error: Failed to read session token from profile."
                rm -rf "$backup_dir"
                return 1
            }
            mv -f "$profile_saves_dir/.warThunderProps.pblk.tmp" "$profile_saves_dir/.warThunderProps.pblk"

            if [[ -f "$src/lastlogin.blk" ]]; then
                mkdir -p "$(dirname "$profile_lastlogin_dst")"
                cp "$src/lastlogin.blk" "${profile_lastlogin_dst}.tmp" 2>/dev/null
                mv -f "${profile_lastlogin_dst}.tmp" "$profile_lastlogin_dst"
            fi

            # Cleanup backup after successful switch
            rm -rf "$backup_dir"

            # Set partner/region
            echo "partner:t=\"$partner\"" > "$WT_GAME_DIR/yupartner.blk"

            local login_flag="yes"
            [[ "$AUTOLOGIN_ENABLED" == "off" ]] && login_flag="no"
            _wt_set_autologin "$login_flag"

            echo "🎮 Launching '$name' [$badge] (Autologin: $login_flag)"

            # Launch: use steam if profile was saved as steam type
            if [[ "$profile_launch_type" == "steam" ]]; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    open "steam://rungameid/236390"
                else
                    xdg-open "steam://rungameid/236390"
                fi
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                open "$WT_LAUNCHER_PATH"
            else
                if [[ "$WT_LAUNCHER_PATH" == steam://* ]]; then
                    xdg-open "$WT_LAUNCHER_PATH"
                else
                    "$WT_LAUNCHER_PATH" &
                fi
            fi
            ;;
    esac
}

wtglobal() {
    wt global
}
