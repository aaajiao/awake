# Awake

A minimal macOS menu bar app to schedule automatic sleep and wake times.

<img src="icons/all.png" width="128" alt="Awake Icon">

## Features

- Schedule daily sleep time (e.g., 23:00)
- Schedule daily wake time (e.g., 07:00) or use Wake on LAN
- Choose repeat days: Every Day / Weekdays / Weekends
- Launch at login
- Bilingual: English & Chinese (auto-detect or manual selection)

## Screenshots

| Schedule Active | Schedule Inactive |
|-----------------|-------------------|
| <img src="icons/sleep.png" width="64"> | <img src="icons/awake.png" width="64"> |

## Requirements

- macOS 26 (Tahoe) or later
- Administrator privileges (for `pmset` commands)

## Installation

### Option 1: Download Release
Download `Awake.app` from [Releases](../../releases) and move to `/Applications`.

### Option 2: Build from Source
```bash
git clone https://github.com/aaajiao/awake.git
cd awake
./build.sh
open Awake.app
```

## How It Works

Awake uses macOS's built-in `pmset` command to manage power schedules:

```bash
# Set sleep and wake schedule
pmset repeat wakeorpoweron MTWRFSU 07:00:00 sleep MTWRFSU 23:00:00

# Cancel schedule
pmset repeat cancel

# View current schedule
pmset -g sched
```

The app requests administrator privileges via AppleScript when applying changes.

## Tech Stack

- **Swift 6** + **SwiftUI** + **AppKit**
- **NSPanel** for arrowless menu bar popover
- **@Observable** for state management
- **SMAppService** for login item management
- Multi-file modular architecture

## License

MIT

## Author

[aaajiao](https://github.com/aaajiao)
