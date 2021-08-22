//
//  MouseStatusMenu.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import SwiftUI
import AppKit


struct MouseStatusMenu: View {
    @EnvironmentObject var batteryStatus: BatteryLevelReader

    var body: some View {
        Button(action: {}) {
            Image(systemName: "clock.arrow.2.circlepath")
            if batteryStatus.updatedAt != nil {
                Text("Updated \(batteryStatus.timeSinceUpdate) ago")
            } else {
                Text("Waiting...")
            }
        }.disabled(true)

        Divider()

        ForEach(batteryStatus.bluetoothMice, id: \.self) { mouse in
            Button(action: {}) {
                let batteryLevel = batteryStatus.mouseBatteryLevel[mouse.addressString]
                Image(systemName: "battery.\(mapBatteryLevel(level: batteryLevel))")

                let percentage = batteryLevel == nil ? "?%" : "\(Int(batteryLevel! * 100))%"
                Text("\(mouse.name) - \(percentage)")
            }.disabled(true)
        }
        if batteryStatus.bluetoothMice.count == 0 {
            Text("No Bluetooth mouse")
        }
    }

    private func mapBatteryLevel(level: Double?) -> Int {
        guard let level = level else {
            return 0
        }

        switch level {
        case 0.10..<0.35:
            return 25
        case 0.35..<0.60:
            return 50
        case 0.60..<0.85:
            return 75
        case 0.85..<100:
            return 100
        default:
            return 0
        }
    }
}
