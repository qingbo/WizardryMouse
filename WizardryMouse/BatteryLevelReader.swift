//
//  BatteryLevelReader.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import Foundation
import IOKit

class BatteryLevelReader: NSObject, ObservableObject {
    static let shared = BatteryLevelReader()

    private static let timerIntervalSeconds = 60
    private static let levelUpdateIntervalMinutes = 60 // Update every hour.
    private var timer: DispatchSourceTimer?

    private var plistDecoder = PropertyListDecoder()

    @Published var bluetoothDevices: [BluetoothDevice] = []
    @Published var minBatteryPercent: Int? // Minimum battery level of all mice.
    @Published var updatedAt: Date?
    @Published var timeSinceUpdate = "Checking..."

    override init() {
        super.init()

        let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(BatteryLevelReader.timerIntervalSeconds))
        timer!.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                var minutes = self!.calculateMintues()
                
                if minutes == nil || minutes! >= BatteryLevelReader.levelUpdateIntervalMinutes {
                    self!.update()
                    minutes = 0
                }
                
                if minutes != nil {
                    self!.updateTimeSinceUpdate(minutes!)
                }
            }
        }
        timer!.resume()
    }

    private func calculateMintues() -> Int? {
        guard let updatedAt = updatedAt else {
            return nil
        }
        let interval = Date().timeIntervalSinceReferenceDate - updatedAt.timeIntervalSinceReferenceDate
        return Int(interval / 60)
    }
    
    private func updateTimeSinceUpdate(_ minutes: Int) {
        let unit = minutes == 1 ? "minute" : "minutes"
        timeSinceUpdate = "\(minutes) \(unit)"
    }

    private func update() {
        bluetoothDevices = []
        minBatteryPercent = nil
        
        var iter: io_iterator_t = 0
        let ret = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                               IOServiceNameMatching("AppleDeviceManagementHIDEventService"),
                                               &iter)
        guard ret == KERN_SUCCESS else {
            return
        }
        repeat {
            let service = IOIteratorNext(iter)
            guard service != 0 else {
                break
            }
            
            // Get product name
            let propProduct = IORegistryEntryCreateCFProperty(service,
                                                              "Product" as CFString,
                                                              kCFAllocatorDefault, 0)
            let product = propProduct!.takeRetainedValue() as! String
            guard product.hasPrefix("Magic Mouse") else {
                continue
            }
            
            // Get battery percent
            let propBattery = IORegistryEntryCreateCFProperty(service,
                                                              "BatteryPercent" as CFString,
                                                              kCFAllocatorDefault, 0)
            guard propBattery != nil else {
                continue
            }
            let batteryPercent = propBattery?.takeRetainedValue() as! Int
            
            // Get serial number
            let propSerialNumber = IORegistryEntryCreateCFProperty(service,
                                                                   "SerialNumber" as CFString,
                                                                   kCFAllocatorDefault, 0)
            guard propSerialNumber != nil else {
                continue
            }
            let serialNumber = propSerialNumber!.takeRetainedValue() as! String
            
            
            if minBatteryPercent == nil || batteryPercent < minBatteryPercent! {
                minBatteryPercent = batteryPercent
            }
            bluetoothDevices.append(BluetoothDevice(
                product: product,
                serialNumber: serialNumber,
                batteryPercent: batteryPercent
            ))
        } while true
        
        updatedAt = Date()
    }
}

struct BluetoothDevice: Identifiable, Hashable {
    var id: String {
        serialNumber
    }
    
    let product: String
    let serialNumber: String
    let batteryPercent: Int
}
