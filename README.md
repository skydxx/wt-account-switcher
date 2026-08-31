# War Thunder Account Switcher

🇷🇺 *[Русская версия ниже (Russian version below)](#русская-версия)*

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
| `wt global` (or `wtglobal`) | Launch WT (Global) and force manual login |
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

---
---

# Русская версия

Быстрый, безопасный и открытый локальный менеджер аккаунтов для War Thunder. Работает на **Windows, macOS и Linux**.

Скрипт **НЕ** изменяет бинарные файлы игры, не внедряется в процессы и не триггерит античит (EAC). Он просто подменяет локальные файлы настроек и токены сессии до запуска игры. Для игры это выглядит так, будто вы сами ввели пароль и нажали «Сохранить пароль».

## Возможности
- Мгновенное сохранение и переключение между несколькими аккаунтами через консоль или ярлыки на рабочем столе.
- Автоматически переключает регионы между `pixelstorm` (СНГ) и `gaijin` (Глобал) в зависимости от сохраненного аккаунта.
- Автоматически отключает автологин при обычном запуске (чтобы вы могли спокойно войти в новый аккаунт).
- **Windows**: Генерирует удобные ярлыки в папке `WT Accounts` на рабочем столе.
- **macOS**: Умеет автоматически генерировать скрипты для [Raycast](https://www.raycast.com/).
- **Linux**: Отлично работает как с нативным клиентом, так и через Steam Proton.

---

## Установка

### Windows
1. Скачайте или склонируйте этот репозиторий.
2. Зайдите в папку `windows` и запустите `install.bat`.
3. Откройте новое окно Командной строки (CMD) или PowerShell.
4. Введите `wt config setup` и укажите пути к лаунчеру и папке с игрой.

### macOS и Linux
1. Откройте терминал и склонируйте репозиторий.
2. Выполните: `cd mac-linux && ./install.sh`
3. Перезапустите терминал (или выполните `source ~/.zshrc` / `source ~/.bashrc`).
4. Введите `wt config setup` и подтвердите предложенные пути (или укажите свои).

*(Примечание: если используете Raycast на Mac, включите генерацию скриптов командой `wt config raycast on`)*

---

## Как пользоваться

1. Запустите игру как обычно, без автологина:
   - `wt` (для региона Pixelstorm/СНГ)
   - `wt global` (для региона Gaijin/Global)
2. В самой игре войдите в нужный аккаунт и **обязательно поставьте галочку «Сохранить пароль»**.
3. Закройте игру.
4. Откройте терминал (или CMD/PowerShell) и сохраните текущую сессию:
   - `wt save pix MyMainAcc` *(для СНГ)*
   - `wt save global MyAltAcc` *(для Глобала)*
5. Готово! Теперь вы можете мгновенно заходить на этот аккаунт:
   - В терминале: `wt MyMainAcc`
   - На Windows: Двойным кликом по ярлыку в папке `WT Accounts` на рабочем столе.
   - На Mac (Raycast): Откройте Raycast и введите `wt MyMainAcc`.

### Список команд

| Команда | Описание |
|---|---|
| `wt` | Запустить WT (Pixelstorm) и принудительно запросить ручной логин |
| `wt global` (или `wtglobal`) | Запустить WT (Global) и принудительно запросить ручной логин |
| `wt <имя>` | Запустить сохраненный аккаунт (сработает автологин) |
| `wt save pix <имя>` | Сохранить текущую сессию как аккаунт Pixelstorm |
| `wt save global <имя>`| Сохранить текущую сессию как аккаунт Global |
| `wt list` | Показать список всех сохраненных аккаунтов |
| `wt delete <имя>` | Удалить сохраненный аккаунт |
| `wt config setup` | Заново настроить пути к игре и сохранениям |
| `wt config autologin on/off` | Включить/выключить автологин для сохраненных аккаунтов |
| `wt config raycast on/off` | (Только Mac) Включить/выключить генерацию скриптов Raycast |

---

## Важное предупреждение
Это неофициальный фанатский инструмент. Он работает исключительно локально и никак не модифицирует память игры или сетевой трафик. Однако, согласно Пользовательскому соглашению (TOS) Gaijin Entertainment, создание нескольких аккаунтов запрещено. Вы используете этот скрипт на свой страх и риск.
