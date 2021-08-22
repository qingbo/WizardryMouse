//
//  BatteryLevelReader.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import Foundation
import IOBluetooth

class BatteryLevelReader: NSObject, ObservableObject {
    static let shared = BatteryLevelReader()

    private static let timerIntervalSeconds = 60
    private static let levelUpdateIntervalSeconds = 3600 // Update every hour.
    private var timer: DispatchSourceTimer?
    private var secondsSinceUpdate = levelUpdateIntervalSeconds // So that update will run on startup.

    private var plistDecoder = PropertyListDecoder()

    @Published var bluetoothMice: [IOBluetoothDevice] = [] // List of connected mice.
    @Published var mouseBatteryLevel: [String: Double] = [:] // Mapping of mouse address to battery level.
    @Published var minBatteryLevel: Double? // Minimum battery level of all mice.
    @Published var updatedAt: Date?
    @Published var timeSinceUpdate = "0 minutes"

    override init() {
        super.init()

        let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(BatteryLevelReader.timerIntervalSeconds))
        timer!.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self!.calculateMintues()
                if self!.secondsSinceUpdate >= BatteryLevelReader.levelUpdateIntervalSeconds {
                    self!.update()
                    self!.secondsSinceUpdate = 0
                } else {
                    self!.secondsSinceUpdate += 60
                }
            }
        }
        timer!.resume()
    }

    private func calculateMintues() {
        guard let updatedAt = updatedAt else {
            return
        }
        let interval = Date().timeIntervalSinceReferenceDate - updatedAt.timeIntervalSinceReferenceDate
        let minutes = Int(interval / 60)
        let unit = minutes == 1 ? "minute" : "minutes"
        timeSinceUpdate = "\(minutes) \(unit)"
    }

    private func update() {
        bluetoothMice = []
        // Get connected mice.
        let pairdDevices = IOBluetoothDevice.pairedDevices() ?? []
        for device in pairdDevices {
            if let device = device as? IOBluetoothDevice {
                if device.isConnected() && device.classOfDevice == 1408 {
                    bluetoothMice.append(device)
                }
            }
        }

        // Read battery level information from plist
        if let data = try? Data(contentsOf: URL(fileURLWithPath: "/Library/Preferences/com.apple.bluetooth.plist")) {
            let bluetoothPlist = try? plistDecoder.decode(BluetoothPropertyList.self, from: data)

            minBatteryLevel = nil
            for mouse in bluetoothMice {
                let address = mouse.addressString!
                let batteryLevel = bluetoothPlist?.DeviceCache?[address]?.BatteryPercent
                if batteryLevel == nil {
                    continue
                }
                mouseBatteryLevel[address] = batteryLevel
                if minBatteryLevel == nil || batteryLevel! < minBatteryLevel! {
                    minBatteryLevel = batteryLevel
                }
            }
        }
        updatedAt = Date()
    }
}

struct DeviceBattery: Codable {
    let BatteryPercent: Double?
}

struct BluetoothPropertyList: Codable {
    let DeviceCache: [String: DeviceBattery]?
}
