//
//  WizardryMouseApp.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import SwiftUI

@main
struct WizardryMouseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var batteryStatus = BatteryLevelReader.shared

    var body: some Scene {
        Settings {
            AppSettings()
        }
        .commands {
            // Customize the preferences menu button so that the window can be activated.
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button(action: showPreferencesWindow) {
                    Text("Preferences")
                }
            }

            CommandGroup(before: CommandGroupPlacement.appSettings) {
                MouseStatusMenu().environmentObject(batteryStatus)

                Divider()
            }

            CommandGroup(after: CommandGroupPlacement.appSettings) {
                Button(action: showAboutWindow) {
                    Text("About")
                }
                Button(action: quit) {
                    Text("Quit Wizardry Mouse")
                }
            }
        }
    }

    private func quit() {
        NSApplication.shared.terminate(self)
    }

    private func showPreferencesWindow() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showAboutWindow() {
        NSApplication.shared.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
