# War Thunder Account Switcher

A fast, safe, and open-source local account switcher for War Thunder. Works on **Windows, macOS, and Linux**.

Does **NOT** modify game files, hook into processes, or trigger anti-cheat. It simply swaps your local game settings and session tokens before launching the game, acting exactly as if you manually typed your password and checked "Save Password" in the game menu.

## Features
- Save and switch between multiple accounts instantly via CLI or Desktop shortcuts.
- Toggles `pixelstorm` (CIS) and `gaijin` (Global) regions automatically based on the saved account.
- Disables autologin when running the vanilla launcher so you can safely log into a new account.
- **Windows**: Generates `WT Accounts` shortcuts on your Desktop.
- **macOS**: Can automatically generate scripts for [Raycast](https://www.raycast.com/).
- **Linux**: Works seamlessly with Steam Proton and native clients.

---

## Installation

### Windows
1. Download or clone this repository.
2. Go to the `windows` folder and run `install.bat`.
3. Open a new Command Prompt or PowerShell.
4. Run `wt config setup` and provide the paths to your Launcher and Game directories.

### macOS & Linux
1. Open terminal and clone this repository.
2. Run `cd mac-linux && ./install.sh`
3. Restart your terminal (or run `source ~/.zshrc` / `source ~/.bashrc`).
4. Run `wt config setup` and verify the detected paths.

*(Note: if using Raycast on Mac, enable generation by running `wt config raycast on`)*

---

## How to Use

1. Launch the game normally without autologin:
   - `wt` (for Pixelstorm/CIS region)
   - `wt global` (for Gaijin/Global region)
2. In the game, log into your account and check the **"Save Password"** box.
3. Close the game.
4. Open your terminal (or CMD/PowerShell) and save the session:
   - `wt save pix MyMainAcc`
   - `wt save global MyAltAcc`
5. Done! You can now switch to that account instantly:
   - In terminal: `wt MyMainAcc`
   - On Windows: Double-click the shortcut generated in the `Desktop/WT Accounts` folder.
   - On Mac (Raycast): Open Raycast and type `wt MyMainAcc`.

### Commands Reference

| Command | Description |
|---|---|
| `wt` | Launch WT (Pixelstorm) and force manual login |
| `wt global` | Launch WT (Global) and force manual login |
| `wt <name>` | Launch a saved account with autologin |
| `wt save pix <name>` | Save current session as a Pixelstorm account |
| `wt save global <name>`| Save current session as a Global account |
| `wt list` | List all saved accounts |
| `wt delete <name>` | Delete a saved account |
| `wt config setup` | Reconfigure paths to the game and launcher |
| `wt config autologin on/off` | Toggle whether saved accounts use autologin |
| `wt config raycast on/off` | (Mac only) Toggle Raycast script generation |

---

## Disclaimer
This is an unofficial community tool. It operates entirely locally and does not interact with the game's memory or network traffic. However, please be aware of Gaijin Entertainment's Terms of Service regarding multi-accounting. Use at your own risk.
