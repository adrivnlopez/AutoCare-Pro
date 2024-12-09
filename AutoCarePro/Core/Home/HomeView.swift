//
//  HomeView.swift
//  AutoCarePro
//
//  Created by Adrian Lopez on 10/23/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    @State private var selectedVehicle: Vehicle = Vehicle.defaultVehicle()
    @State private var navigateToOBD2: Bool = false // New state for navigation

    
    @EnvironmentObject var viewModel: AuthViewModel
    


    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Top vehicle Information Section
                VStack(alignment: .leading) {

                    HStack {
                        NavigationLink(destination: ProfileView()) {
                            Image("ACP")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .aspectRatio(contentMode: .fit)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(selectedVehicle.model)
                                .font(.title)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Text("Mileage: \(selectedVehicle.mileage) miles")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    
                }
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Main Connect Button
                    Button(action: {
                        if bluetoothManager.isConnected == true {
                            bluetoothManager.disconnectMockMode()
                            bluetoothManager.isConnected = false
                            navigateToOBD2 = false
                        } else {
                            bluetoothManager.enableMockMode()
                            bluetoothManager.isConnected = true
                            navigateToOBD2 = true           // trigger navigation
                        }
                    }) {
                        Text(bluetoothManager.isConnected ? "Disconnect from OBD2" : "Connect to OBD2")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(bluetoothManager.isConnected ? Color.red : Color.blue)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        
                    }
                
                    .padding()
                
                Spacer()
                
                // display OBD2 status
                
                if bluetoothManager.isConnected {
                                   Text("Connected to OBD2 Device")
                                       .font(.headline)
                                       .padding()
                               } else {
                                   Text("Not Connected")
                                       .font(.headline)
                                       .padding()
                               }
                

                    }
            
            .padding()
            .navigationDestination(isPresented: $navigateToOBD2) {
                OBD2View(bluetoothManager: bluetoothManager)
            }
                
                // Slider with Features
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 15) {
                            FeatureCardView(featureName: "Diagnostics", featureDescription: "Check your vehicle's health.", imageName: "waveform.path.ecg")
                                .id(0)
                            FeatureCardView(featureName: "Services", featureDescription: "Schedule maintenance.", imageName: "wrench.and.screwdriver")
                                .id(1)
                            FeatureCardView(featureName: "Live Data", featureDescription: "View real-time data.", imageName: "gauge.open.with.lines.needle.67percent.and.arrowtriangle.and.car")
                            
                                .id(2)
                        }
                        .padding(.horizontal)
                        .onAppear {
                            proxy.scrollTo(1, anchor: .center)
                        }
                    }
                }
                Spacer()
            }
            .navigationBarTitle("Home", displayMode: .inline)

            }
        }
    



struct FeatureCardView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var featureName: String
    var featureDescription: String
    var imageName: String
    
    var body: some View {
        VStack {
            
            Image(systemName: imageName)
                .resizable()
                .frame(width: 30, height: 30)
                .aspectRatio(contentMode: .fit)
            
            Text(featureName)
                .font(.headline)
            Text(featureDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

        }
        .frame(width: 150, height: 150)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
         


struct Vehicle {
    var model: String
    var mileage: Int
    
    static func defaultVehicle() -> Vehicle {
        return Vehicle(model: "Toyota Corolla", mileage: 35000)
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
