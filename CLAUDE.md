# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Awake is a macOS menu bar app that manages system sleep/wake schedules using `pmset`. It's a single-file SwiftUI application targeting macOS 26+.

## Build Command

```bash
swiftc -o Awake.app/Contents/MacOS/Awake main.swift -framework SwiftUI -framework AppKit -parse-as-library
```

## Architecture

**Single-file hybrid AppKit/SwiftUI app** (`main.swift` ~700 lines) with these components:

| Section | Purpose |
|---------|---------|
| `AppLanguage` / `L10n` | Localization (Chinese/English/System) |
| `RepeatDays` / `SystemSchedule` | Data models |
| `ScheduleState` | `@Observable` state management |
| `PMSetService` | Executes `pmset` commands via AppleScript for admin privileges |
| `LaunchService` | `SMAppService` for login item management |
| `PopoverContentView` | SwiftUI content for the panel |
| `PopoverPanel` | Custom `NSPanel` subclass for menu bar popup (no arrow, flush with menu bar) |
| `AppDelegate` | `NSStatusItem` + panel management |
| `AwakeApp` | `@main` entry point using `NSApplication.run()` |

## Key Technical Details

- **System state is truth**: App reads `pmset -g sched` to determine current schedule, not local storage
- **Admin privileges**: Uses AppleScript `do shell script ... with administrator privileges` for pmset commands
- **Icon switching**: `sleep.icns` (schedule active) / `awake.icns` (schedule inactive) loaded from Resources
- **No Xcode project**: Compiled directly with `swiftc`, app bundle manually structured
- **Custom NSPanel**: Uses `PopoverPanel` (NSPanel subclass) instead of NSPopover to achieve flush positioning below menu bar without arrow
- **Event monitors**: Global monitor closes panel on outside clicks; local monitor handles Escape key

## App Bundle Structure

```
Awake.app/Contents/
├── Info.plist          # LSUIElement=true (menu bar only)
├── MacOS/Awake         # Compiled binary
└── Resources/
    ├── AppIcon.icns    # Finder icon
    ├── awake.icns      # Menu bar: inactive
    └── sleep.icns      # Menu bar: active
```

## pmset Commands Used

```bash
pmset -g sched                                    # Read current schedule
pmset repeat wakeorpoweron DAYS HH:MM:SS sleep DAYS HH:MM:SS  # Set schedule
pmset repeat cancel                               # Clear schedule
```

Days format: `MTWRFSU` (Monday-Sunday), `MTWRF` (weekdays), `SU` (weekends)
