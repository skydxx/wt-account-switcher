#!/usr/bin/env bash

INSTALL_DIR="$HOME/.config/wt_switcher"
BIN_DIR="$HOME/.local/bin"

echo "Installing WT Account Switcher..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

cp wt_switch.sh "$INSTALL_DIR/wt_switch.sh"
chmod +x "$INSTALL_DIR/wt_switch.sh"

# Create wt wrapper
cat > "$BIN_DIR/wt" << EOF
#!/usr/bin/env bash
source "$INSTALL_DIR/wt_switch.sh"
wt "\$@"
EOF
chmod +x "$BIN_DIR/wt"

# Add to PATH if needed
SHELL_RC="$HOME/.bashrc"
[[ "$SHELL" == *"zsh"* ]] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "$BIN_DIR" "$SHELL_RC"; then
    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$SHELL_RC"
    echo "Added $BIN_DIR to $SHELL_RC"
fi

echo ""
echo "Installation complete!"
echo "Please restart your terminal or run: source $SHELL_RC"
echo "Then configure your paths with: wt config setup"
