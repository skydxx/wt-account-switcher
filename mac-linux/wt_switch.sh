#!/usr/bin/env zsh
# War Thunder Account Switcher (Mac/Linux)

_WT_CONFIG_DIR="$HOME/.config/wt_switcher"
_WT_CONFIG_FILE="$_WT_CONFIG_DIR/config.env"
_WT_ACCOUNTS_DIR="$_WT_CONFIG_DIR/accounts"
_WT_RAYCAST_DIR="$HOME/raycast-scripts"

# Default config values
WT_LAUNCHER_PATH=""
WT_GAME_DIR=""
WT_SAVES_DIR=""
RAYCAST_ENABLED="off"
AUTOLOGIN_ENABLED="on"

# Load config if exists
if [[ -f "$_WT_CONFIG_FILE" ]]; then
    source "$_WT_CONFIG_FILE"
fi

_wt_save_config() {
    mkdir -p "$_WT_CONFIG_DIR"
    cat > "$_WT_CONFIG_FILE" << EOF
WT_LAUNCHER_PATH="$WT_LAUNCHER_PATH"
WT_GAME_DIR="$WT_GAME_DIR"
WT_SAVES_DIR="$WT_SAVES_DIR"
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

_wt_setup() {
    local os=$(_wt_detect_os)
    
    echo "=== War Thunder Account Switcher Setup ==="
    
    if [[ "$os" == "mac" ]]; then
        local def_launcher="/Applications/WarThunderLauncher.app"
        local def_game="$def_launcher/Contents/WarThunder.app/Contents/Resources/game"
        local def_saves="$HOME/My Games/WarThunder"
    else
        local def_launcher="steam://rungameid/236390"
        local def_game="$HOME/.local/share/Steam/steamapps/common/War Thunder"
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

    _wt_save_config
    echo "✅ Configuration saved to $_WT_CONFIG_FILE"
}

_wt_usage() {
    echo "War Thunder Account Switcher"
    echo ""
    echo "Launch Commands:"
    echo "  wt                     — Launch WT (Pixelstorm) without autologin"
    echo "  wt global              — Launch WT (Global) without autologin"
    echo "  wt <name>              — Launch saved account"
    echo ""
    echo "Management Commands:"
    echo "  wt save pix <name>     — Save current session as Pixelstorm account"
    echo "  wt save global <name>  — Save current session as Global account"
    echo "  wt list                — List saved accounts"
    echo "  wt delete <name>       — Delete saved account"
    echo ""
    echo "Configuration Commands:"
    echo "  wt config setup          — Run initial path setup"
    echo "  wt config raycast on/off — Enable/disable Raycast script generation (Mac only)"
    echo "  wt config autologin on/off - Enable/disable autologin for saved accounts"
    echo ""
}

_wt_set_autologin() {
    local state="$1" # yes or no
    local common_blk="$WT_SAVES_DIR/Saves/common.blk"
    if [[ -f "$common_blk" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/autologin:b=.*/autologin:b=$state/" "$common_blk"
        else
            sed -i "s/autologin:b=.*/autologin:b=$state/" "$common_blk"
        fi
    fi
}

_wt_launch() {
    local partner="$1" # pixelstorm or gaijin
    local force_autologin="$2" # yes or no

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
        open "$WT_LAUNCHER_PATH"
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
    if [[ -z "$WT_LAUNCHER_PATH" && "$cmd" != "config" && "$cmd" != "-h" && "$cmd" != "--help" && "$cmd" != "" ]]; then
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

            if [[ "$server" != "pix" && "$server" != "global" ]]; then
                echo "Usage: wt save pix <name> OR wt save global <name>"
                return 1
            fi
            if [[ -z "$name" ]]; then
                echo "Usage: wt save $server <name>"
                return 1
            fi

            local dest="$_WT_ACCOUNTS_DIR/$name"
            mkdir -p "$dest"

            # Copy in-game auth files
            cp "$WT_SAVES_DIR/.warThunderProps.pblk" "$dest/.warThunderProps.pblk" 2>/dev/null
            cp "$WT_SAVES_DIR/Saves/lastlogin.blk" "$dest/lastlogin.blk" 2>/dev/null

            if [[ "$server" == "pix" ]]; then
                echo 'partner:t="pixelstorm"' > "$dest/yupartner.blk"
            else
                echo 'partner:t="gaijin"' > "$dest/yupartner.blk"
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
                local partner_raw badge
                partner_raw=$(cat "$d/yupartner.blk" 2>/dev/null)
                [[ "$partner_raw" == *pixelstorm* ]] && badge="pix" || badge="global"
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

            pkill -9 -f "WarThunderLauncher" 2>/dev/null || true
            pkill -9 -f "aces" 2>/dev/null || true
            sleep 0.2

            cp "$src/.warThunderProps.pblk" "$WT_SAVES_DIR/.warThunderProps.pblk" 2>/dev/null
            mkdir -p "$WT_SAVES_DIR/Saves"
            cp "$src/lastlogin.blk" "$WT_SAVES_DIR/Saves/lastlogin.blk" 2>/dev/null

            local partner_raw badge partner
            partner_raw=$(cat "$src/yupartner.blk" 2>/dev/null)
            if [[ "$partner_raw" == *pixelstorm* ]]; then
                partner="pixelstorm"
            else
                partner="gaijin"
            fi

            local login_flag="yes"
            [[ "$AUTOLOGIN_ENABLED" == "off" ]] && login_flag="no"

            _wt_set_autologin "$login_flag"
            echo "partner:t=\"$partner\"" > "$WT_GAME_DIR/yupartner.blk"

            [[ "$partner" == "pixelstorm" ]] && badge="pix" || badge="global"
            echo "🎮 Launching '$name' [$badge] (Autologin: $login_flag)"
            
            if [[ "$OSTYPE" == "darwin"* ]]; then
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
