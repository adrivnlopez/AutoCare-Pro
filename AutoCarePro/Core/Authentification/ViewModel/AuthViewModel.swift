//
//  AuthViewModel.swift
//  AutoCarePro
//
//  Created by Adrian Lopez on 10/20/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreCombineSwift

protocol AuthenticationFormProtocol {                       // test comment
    var formIsValid: Bool { get }
}

@MainActor                                                  // publish all UI updates to main thread
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?          // firebase user object
    @Published var currentUser: User?                       // user data model
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)                          // encodes user data
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)  // uploads data to firebase
            await fetchUser()       // after uploading data, need to fetch to display on screen
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()       // signs out user on backend
            self.userSession = nil          // wipes out user sessoin & takes user back to login screen
            self.currentUser = nil          // wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }        // get current users id
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}    // trys to fetch user
        self.currentUser = try? snapshot.data(as: User.self)
    }
}
