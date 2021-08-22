//
//  AppDelegate.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var aboutBoxWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Get the application menu.
        let mainMenu = NSApplication.shared.mainMenu
        let appMenu = mainMenu?.item(at: 0)?.submenu

        // Create status item
        let statusBarHeight = NSStatusBar.system.thickness
        let scale = CGFloat(0.727) // Leave some padding space
        self.statusItem = NSStatusBar.system.statusItem(withLength: statusBarHeight * 2 * scale)
        self.statusItem?.menu = appMenu

        // Replace status item view with custom one
        let itemView = NSHostingView(rootView: StatusItemView(height: statusBarHeight * scale).environmentObject(BatteryLevelReader.shared))
        itemView.setFrameSize(NSSize(width: statusBarHeight * 2 * scale, height: statusBarHeight))
        self.statusItem?.button?.subviews.forEach{ $0.removeFromSuperview() }
        self.statusItem?.button?.addSubview(itemView)
    }
}
