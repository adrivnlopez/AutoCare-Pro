//
//  CAPSTONEApp.swift
//  CAPSTONE
//
//  Created by Adrian Lopez on 10/14/24.
//

import SwiftUI
import Firebase

@main
struct AutoCareProApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
