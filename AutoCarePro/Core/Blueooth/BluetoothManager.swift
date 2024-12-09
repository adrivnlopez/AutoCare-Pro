//
//  BluetoothManager.swift
//  AutoCarePro
//
//  Created by Adrian Lopez on 12/4/24.
//

import CoreBluetooth
import Foundation


class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var receivedCodes: [String] = [] // Added to track OBD2 codes
    @Published var isConnected: Bool = false
    @Published var connectionSuccessful: Bool = false // New property for triggering navigation
    
    
    
    private var centralManager: CBCentralManager!
    private var obdPeripheral: CBPeripheral?
    private var obdCharacteristic: CBCharacteristic?
    var mockMode: Bool = false


    
    
    func enableMockMode() {
           self.mockMode = true
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               self.isConnected = true
               self.receivedCodes = [
                   "P0301 - Cylinder 1 Misfire Detected",
                   "P0420 - Catalyst System Efficiency Below Threshold (Bank 1)",
                   "P0171 - System Too Lean (Bank 1)"
               ]
           }
       }
    
    func disconnectMockMode() {
            if mockMode {
                self.mockMode = false
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.receivedCodes = []
                }
            }
        }
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on")
        } else {
            print("Bluetooth is not available.")
        }
    }

    func startScanning() {
           if mockMode {
               enableMockMode()
           } else {
               if self.centralManager.state == .poweredOn {
                   print("Starting scan for OBD2 devices...")
                   self.centralManager.scanForPeripherals(withServices: nil, options: nil)
               } else {
                   print("Cannot start scanning. Bluetooth is not powered on.")
               }
           }
       }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
        if let name = peripheral.name, name.contains("OBD") { // Adjust to match ELM 327 device name
            print("Connecting to \(name)")
            self.centralManager.stopScan()
            self.obdPeripheral = peripheral
            self.obdPeripheral?.delegate = self
            self.centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to OBD2 device")
        self.isConnected = true
        self.connectionSuccessful = true // Trigger navigation
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        for service in peripheral.services ?? [] {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        for characteristic in service.characteristics ?? [] {
            print("Discovered characteristic: \(characteristic.uuid)")
            if characteristic.properties.contains(.notify) || characteristic.properties.contains(.read) {
                self.obdCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to characteristic: \(characteristic.uuid)")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiving data: \(error.localizedDescription)")
            return
        }

        if let data = characteristic.value {
            self.processReceivedData(data)
        }
    }

    private func processReceivedData(_ data: Data) {
        if let receivedString = String(data: data, encoding: .utf8) {
            print("Received OBD2 data: \(receivedString)")
            // Handle or parse the received data here
        } else {
            print("Failed to decode received data")
        }
    }


    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from OBD2 device")
        self.isConnected = false
        self.connectionSuccessful = false // Reset navigation trigger
    }
}
