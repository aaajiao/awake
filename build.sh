#!/bin/bash

# Build script for Awake - multi-file architecture
swiftc -o Awake.app/Contents/MacOS/Awake \
  Sources/Constants.swift \
  Sources/Models/AppLanguage.swift \
  Sources/Models/RepeatDays.swift \
  Sources/Models/L10n.swift \
  Sources/Models/SystemSchedule.swift \
  Sources/State/LocalizationState.swift \
  Sources/State/ScheduleState.swift \
  Sources/Services/Protocols.swift \
  Sources/Services/PMSetService.swift \
  Sources/Services/LaunchService.swift \
  Sources/Views/Components/HourPicker.swift \
  Sources/Views/Components/AppIconView.swift \
  Sources/Views/ScheduleSection.swift \
  Sources/Views/SettingsSection.swift \
  Sources/Views/PopoverContentView.swift \
  Sources/AppDelegate/PopoverPanel.swift \
  Sources/AppDelegate/EventCoordinator.swift \
  Sources/AppDelegate/WindowManager.swift \
  Sources/AppDelegate/AppDelegate.swift \
  Sources/main.swift \
  -framework SwiftUI -framework AppKit -framework ServiceManagement

if [ $? -eq 0 ]; then
    echo "Build successful: Awake.app"
else
    echo "Build failed"
    exit 1
fi
