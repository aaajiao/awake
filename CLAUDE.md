# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Awake is a macOS menu bar app that manages system sleep/wake schedules using `pmset`. It's a multi-file SwiftUI/AppKit hybrid application targeting macOS 26+.

## Build Command

```bash
./build.sh
```

Or manually:

```bash
swiftc -o Awake.app/Contents/MacOS/Awake \
  Sources/Constants.swift \
  Sources/Models/*.swift \
  Sources/State/*.swift \
  Sources/Services/*.swift \
  Sources/Views/Components/*.swift \
  Sources/Views/*.swift \
  Sources/AppDelegate/*.swift \
  Sources/main.swift \
  -framework SwiftUI -framework AppKit -framework ServiceManagement
```

## Architecture

**Multi-file hybrid AppKit/SwiftUI app** with clear separation of concerns:

```
Sources/
├── main.swift                 # Entry point
├── Constants.swift            # UI constants, storage keys, resource loader
├── Models/
│   ├── AppLanguage.swift      # Language enum (Chinese/English/System)
│   ├── RepeatDays.swift       # Day selection enum
│   ├── SystemSchedule.swift   # pmset output parser
│   └── L10n.swift             # Localization strings
├── State/
│   ├── ScheduleState.swift    # @Observable schedule state
│   └── LocalizationState.swift # @Observable localization state
├── Services/
│   ├── Protocols.swift        # Service protocols for testability
│   ├── PMSetService.swift     # pmset command execution
│   └── LaunchService.swift    # Login item management
├── Views/
│   ├── PopoverContentView.swift  # Main popover content
│   ├── ScheduleSection.swift     # Schedule settings UI
│   ├── SettingsSection.swift     # App settings UI
│   └── Components/
│       ├── HourPicker.swift      # Reusable hour picker
│       └── AppIconView.swift     # App icon display
└── AppDelegate/
    ├── AppDelegate.swift      # NSStatusItem + coordination
    ├── WindowManager.swift    # Panel positioning & lifecycle
    ├── EventCoordinator.swift # Global/local event monitors
    └── PopoverPanel.swift     # Custom NSPanel subclass
```

## Key Technical Details

- **System state is truth**: App reads `pmset -g sched` to determine current schedule, not local storage
- **Admin privileges**: Uses AppleScript `do shell script ... with administrator privileges` for pmset commands
- **Icon switching**: `sleep.icns` (schedule active) / `awake.icns` (schedule inactive) loaded via `ResourceLoader`
- **No Xcode project**: Compiled directly with `swiftc`, app bundle manually structured
- **Custom NSPanel**: Uses `PopoverPanel` (NSPanel subclass) instead of NSPopover for arrowless design with 10px gap below menu bar (see `menuBarGap` in WindowManager.swift)
- **Event monitors**: `EventCoordinator` manages global monitor (outside clicks) and local monitor (Escape key)
- **Service protocols**: `Protocols.swift` defines interfaces for testability

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

## Legacy

The original single-file implementation is preserved in `main.swift` at the project root for reference.
