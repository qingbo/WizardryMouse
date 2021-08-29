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

        ForEach(batteryStatus.bluetoothDevices, id: \.self) { device in
            Button(action: {}) {
                Image(systemName: "battery.\(mapBatteryPercent(percent: device.batteryPercent))")
                Text("\(device.product) - \(device.batteryPercent)%")
            }.disabled(true)
        }
        if batteryStatus.bluetoothDevices.count == 0 {
            Text("No Bluetooth mouse")
        }
    }

    private func mapBatteryPercent(percent: Int) -> Int {
        switch percent {
        case 10..<35:
            return 25
        case 35..<60:
            if #available(macOS 12, *) {
                return 50
            } else {
                return 100
            }
        case 60..<85:
            if #available(macOS 12, *) {
                return 75
            } else {
                return 100
            }
        case 85..<1000:
            return 100
        default:
            return 0
        }
    }
}
