//
//  HomeView.swift
//  AutoCarePro
//
//  Created by Adrian Lopez on 10/23/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedVehicle: Vehicle = Vehicle.defaultVehicle()
    @State private var isConnected: Bool = false
    var body: some View {
        NavigationView {
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
                    isConnected.toggle()
                }) {
                    Text(isConnected ? "Disconnect from OBD2" : "Connect to OBD2")
                        .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isConnected ? Color.red : Color.blue)
                            .cornerRadius(15)
                            .padding(.horizontal)
                }
                
                // Slider with Features
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 15) {
                            FeatureCardView(featureName: "Diagnostics", featureDescription: "Check your vehicle's health.", imageName: "diagnostics_icon")
                                .id(0)
                            FeatureCardView(featureName: "Services", featureDescription: "Schedule maintenance.", imageName: "service_icon")
                                .id(1)
                            FeatureCardView(featureName: "Live Data", featureDescription: "View real-time data.", imageName: "live_data_icon")
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
}

struct FeatureCardView: View {
    var featureName: String
    var featureDescription: String
    var imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 60, height: 60)
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

#Preview {
    HomeView()
}
