//
//  OBD2View.swift
//  AutoCarePro
//
//  Created by Adrian Lopez on 12/8/24.
//

import SwiftUI

struct OBD2View: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        VStack {
            if bluetoothManager.isConnected {
                Text("Connected to OBD2 Device")
                    .font(.headline)
                    .padding()

                List(bluetoothManager.receivedCodes, id: \.self) { code in
                    Text(code)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                                    bluetoothManager.disconnectMockMode()
                                }) {
                                    Text("Disconnect")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                                .padding()
                
            } else {
                Text("Not Connected")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()

                Button(action: {
                    bluetoothManager.enableMockMode()
                }) {
                    Text("Connect to OBD2")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            
        }
        .padding()
        .onAppear {
            bluetoothManager.enableMockMode()
        }
        .navigationTitle("OBD2 Scanner")
    }
}

struct OBD2View_Previews: PreviewProvider {
    static var previews: some View {
        OBD2View(bluetoothManager: BluetoothManager())
    }
}
