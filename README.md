# War Thunder Account & Region Switcher

<img src="logo.jpg" width="120" align="right" alt="WT Account Switcher Logo">

🇷🇺 *[Русская версия ниже (Russian version below)](#русская-версия)*

A fast, safe, and source-available local **account and region switcher** for War Thunder.  
Works on **Windows, macOS, and Linux** — with both **standalone launcher** and **Steam**.

Does **NOT** modify game files, hook into processes, or trigger anti-cheat. It simply swaps your local game settings and session tokens before launching the game, restoring a valid local session state that War Thunder uses for auto-login.

## Features
This utility solves two main problems for players:

**1. Region Switching**
* Quickly switch between **Pixelstorm (CIS)** and **Gaijin (Global)** regions without maintaining two separate game installs.
* Works with both standalone launcher and Steam.

**2. Account Switching**
* Save multiple local session states and switch between accounts instantly via CLI or Desktop shortcuts — no password typing required.
* Per-account region is saved: your main CIS account launches CIS, your Global alt launches Global — automatically.
* **Windows**: Generates `WT Accounts` shortcuts on your Desktop.
* **macOS**: Can automatically generate scripts for [Raycast](https://www.raycast.com/).
* **Linux**: Works seamlessly with Steam and native clients.

---

## Installation

### Windows
1. Download `WT-Account-Switcher-Windows.zip` from the [latest Release](https://github.com/skydxx/wt-account-switcher/releases/latest).
2. Extract and run `install.bat`.
3. Open a new Command Prompt or PowerShell.
4. Run `wt config setup` and follow the prompts (choose standalone or Steam).

### macOS & Linux
1. Clone this repository.
2. Run `cd mac-linux && ./install.sh`
3. Restart your terminal (or run `source ~/.zshrc` / `source ~/.bashrc`).
4. Run `wt config setup` — the setup wizard will ask whether you use standalone or Steam and detect default paths.

*(Note: to enable Raycast on Mac, run `wt config raycast on`)*

---

## How to Use

### First time: save your accounts

1. Launch the game without autologin to log in manually:
   - `wt` → Pixelstorm/CIS via standalone launcher
   - `wt global` → Gaijin/Global via standalone launcher
   - `wt steam` → launch via Steam (without switching)
2. In the game, log into the account and check **"Save Password"**.
3. Close the game.
4. Save the session:
   ```
   wt save pix    MyMainCIS     # CIS account (standalone)
   wt save global MyAltGlobal   # Global account (standalone)
   wt save steam  MySteamAcc    # Steam account
   ```

### Switching accounts

```
wt MyMainCIS       # Restores session and launches CIS
wt MyAltGlobal     # Restores session and launches Global
wt MySteamAcc      # Restores session and launches via Steam
```

On Windows, a Desktop shortcut is also generated — just double-click it.  
On Mac with Raycast enabled, you can switch directly from Raycast.

### Commands Reference

| Command | Description |
|---|---|
| `wt` | Launch WT (Pixelstorm/CIS) with forced manual login |
| `wt global` / `wtglobal` | Launch WT (Gaijin/Global) with forced manual login |
| `wt steam` | Launch WT via Steam without switching account |
| `wt <name>` | Restore saved account and launch WT |
| `wt save pix <name>` | Save current session as Pixelstorm/CIS account |
| `wt save global <name>` | Save current session as Global account |
| `wt save steam <name>` | Save current session as Steam account |
| `wt list` | List all saved accounts |
| `wt delete <name>` | Delete a saved account |
| `wt config setup` | Re-run the setup wizard |
| `wt config autologin on/off` | Toggle autologin for saved accounts |
| `wt config raycast on/off` | (Mac only) Toggle Raycast script generation |

---

## How it works
1. War Thunder stores local authentication state (`.warThunderProps.pblk`, `lastlogin.blk`) when you log in with "Save Password" checked.
2. `wt save` copies that state into a named profile folder.
3. `wt <name>` atomically restores the profile back to the game directory.
4. The game (or Steam) is then launched normally — the switcher does not modify game binaries or interfere with the running process.
5. Each profile stores its own region (`pixelstorm`/`gaijin`) and launch type (`standalone`/`steam`), so the correct launcher is used automatically.

## Security model (Local-Only)
This tool is designed to be **safe by design** as a local utility:
* **Local-only**: All profiles are saved locally on your computer.
* **No network communication**: The switcher itself does not make network requests or upload user data. War Thunder and its launcher communicate with their own servers normally.
* **No backend**: It does not rely on or connect to any external services.
* **No telemetry**: There is zero tracking or analytics.
* **No process injection**: It does not intercept network traffic or modify the War Thunder process memory.
* **Source-available**: You can inspect every line of code to verify its behavior.

## ⚠️ Trusting the tool
Because this tool manages your local authentication and session tokens, **you must trust the version you are running.** The source-available nature of this repository allows you to verify that it does not send your data anywhere.  
*Beware of closed-source forks, paid alternatives, or compiled `.exe` variants.* If you cannot read the source code, you cannot verify that the program isn't silently stealing your `.warThunderProps.pblk` token. Only use tools where the source code is public and verifiable for managing session data.

---

## Disclaimer
This is an unofficial community tool. It operates entirely locally and does not interact with the game's memory or network traffic. However, please be aware of Gaijin Entertainment's Terms of Service regarding multi-accounting. Use at your own risk.

---
---

# Русская версия

Быстрый, безопасный и открытый локальный **переключатель аккаунтов и регионов** для War Thunder.  
Работает на **Windows, macOS и Linux** — со **стандартным лаунчером** и **Steam**.

Скрипт **НЕ** изменяет бинарные файлы игры, не внедряется в процессы и не триггерит античит (EAC). Он просто подменяет локальные файлы настроек и токены сессии до запуска игры, восстанавливая валидное локальное состояние авторизации, которое War Thunder использует для автологина.

## Возможности
Утилита решает две главные проблемы игроков:

**1. Смена региона (Region Switching)**
* Быстрое переключение между серверами **Pixelstorm (СНГ)** и **Gaijin (Global)** без необходимости держать на диске два разных клиента.
* Работает как со стандартным лаунчером, так и через Steam.

**2. Смена аккаунта (Account Switching)**
* Сохранение нескольких локальных сессий и мгновенное переключение между ними через консоль или ярлыки — без необходимости вводить пароль.
* Регион сохраняется вместе с аккаунтом: аккаунт СНГ запустит Pixelstorm, аккаунт Global — соответственно, автоматически.
* **Windows**: Автоматически создает папку `WT Accounts` с ярлыками на рабочем столе.
* **macOS**: Может генерировать скрипты для [Raycast](https://www.raycast.com/).
* **Linux**: Отлично работает с нативными клиентами и Steam.

---

## Установка

### Windows
1. Скачайте `WT-Account-Switcher-Windows.zip` из [последнего Release](https://github.com/skydxx/wt-account-switcher/releases/latest).
2. Распакуйте архив и запустите `install.bat`.
3. Откройте новое окно Командной строки (CMD) или PowerShell.
4. Введите `wt config setup` и следуйте инструкциям (выберите тип установки: лаунчер или Steam).

### macOS и Linux
1. Склонируйте репозиторий.
2. Выполните: `cd mac-linux && ./install.sh`
3. Перезапустите терминал (или выполните `source ~/.zshrc` / `source ~/.bashrc`).
4. Введите `wt config setup` — мастер настройки спросит о типе установки и предложит пути по умолчанию.

*(Примечание: если используете Raycast на Mac, включите генерацию скриптов командой `wt config raycast on`)*

---

## Как пользоваться

### Первый раз: сохраните аккаунты

1. Запустите игру без автологина, чтобы войти вручную:
   - `wt` → Pixelstorm/СНГ через стандартный лаунчер
   - `wt global` → Gaijin/Global через стандартный лаунчер
   - `wt steam` → запуск через Steam (без смены аккаунта)
2. В самой игре войдите в нужный аккаунт и **обязательно поставьте галочку «Сохранить пароль»**.
3. Закройте игру.
4. Сохраните текущую сессию:
   ```
   wt save pix    МойАккСНГ      # СНГ аккаунт (через лаунчер)
   wt save global МойАккGlobal   # Global аккаунт (через лаунчер)
   wt save steam  МойСтимАкк     # Steam аккаунт
   ```

### Переключение аккаунтов

```
wt МойАккСНГ       # Восстанавливает сессию и запускает Pixelstorm/СНГ
wt МойАккGlobal    # Восстанавливает сессию и запускает Global
wt МойСтимАкк      # Восстанавливает сессию и запускает через Steam
```

На Windows ярлык на рабочем столе создаётся автоматически.  
На Mac с включённым Raycast — можно переключаться прямо через поиск Raycast.

### Список команд

| Команда | Описание |
|---|---|
| `wt` | Запустить WT (Pixelstorm/СНГ) с принудительным ручным логином |
| `wt global` / `wtglobal` | Запустить WT (Global) с принудительным ручным логином |
| `wt steam` | Запустить WT через Steam без смены аккаунта |
| `wt <имя>` | Восстановить сохранённый аккаунт и запустить WT |
| `wt save pix <имя>` | Сохранить текущую сессию как аккаунт Pixelstorm/СНГ |
| `wt save global <имя>` | Сохранить текущую сессию как аккаунт Global |
| `wt save steam <имя>` | Сохранить текущую сессию как Steam-аккаунт |
| `wt list` | Показать список всех сохранённых аккаунтов |
| `wt delete <имя>` | Удалить сохранённый аккаунт |
| `wt config setup` | Заново запустить мастер настройки |
| `wt config autologin on/off` | Включить/выключить автологин для сохранённых аккаунтов |
| `wt config raycast on/off` | (Только Mac) Включить/выключить генерацию скриптов Raycast |

---

## Как это работает
1. При входе в игру War Thunder сохраняет локальное состояние авторизации (`.warThunderProps.pblk`, `lastlogin.blk`) при включённой галочке «Сохранить пароль».
2. `wt save` копирует это состояние в именованную папку профиля.
3. `wt <имя>` атомарно восстанавливает профиль обратно в папку игры.
4. Игра (или Steam) запускается обычным образом — скрипт не изменяет бинарные файлы и не вмешивается в процесс игры.
5. В каждом профиле хранится регион (`pixelstorm`/`gaijin`) и тип запуска (`standalone`/`steam`), поэтому нужный лаунчер подставляется автоматически.

## Модель безопасности (Local-Only)
Этот инструмент спроектирован так, чтобы быть **safe by design** в качестве локальной утилиты:
* **Только локально**: Все профили сохраняются только на вашем жестком диске.
* **Без сети**: Сам скрипт не делает никаких сетевых запросов и не отправляет пользовательские данные. War Thunder и его лаунчер общаются со своими серверами в штатном режиме.
* **Без бэкенда**: Утилита не зависит от внешних сервисов и не подключается к ним.
* **Без телеметрии**: Отсутствует любой сбор статистики.
* **Без инжектов**: Скрипт не перехватывает трафик и не читает память процесса War Thunder.
* **Открытый код**: Вы можете лично изучить каждую строчку кода.

## ⚠️ Кому доверять
Поскольку этот инструмент работает с вашими токенами сессий, **вы должны доверять той версии кода, которую запускаете.** Открытый исходный код этого репозитория позволяет вам самостоятельно убедиться, что программа ничего не крадёт.  
*Осторожно с закрытыми форками, платными аналогами или скомпилированными `.exe` сборками.* Если вы не можете прочитать исходный код программы, вы не можете быть уверены, что она скрытно не копирует файл `.warThunderProps.pblk`. Доверяйте свои сессионные данные только открытому софту.

---

## Важное предупреждение
Это неофициальный фанатский инструмент. Он работает исключительно локально и никак не модифицирует память игры или сетевой трафик. Однако, согласно Пользовательскому соглашению (TOS) Gaijin Entertainment, создание нескольких аккаунтов запрещено. Вы используете этот скрипт на свой страх и риск.

## License
This project is provided under a [Non-Commercial Source-Available License](LICENSE). Commercial use and monetization are strictly prohibited.
