//
//  LoggedInView.swift
//  zenith
//
//  Created by Florin Stroe on 13.11.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoggedInView: View {
    @Binding var isAuthenticated: Bool
    @State private var userEmail = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isEditingName = false
    @State private var editedFirstName = ""
    @State private var editedLastName = ""
    @State private var isSaving = false
    
    private var initials: String {
        let f = firstName.first.map { String($0) } ?? ""
        let l = lastName.first.map { String($0) } ?? ""
        let result = (f + l)
        return result.isEmpty ? "?" : result.uppercased()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text(initials)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)
            }
            .frame(width: 96, height: 96)
            
            Text("Welcome, \(firstName) \(lastName)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(userEmail)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                )
            
            Button {
                editedFirstName = firstName
                editedLastName = lastName
                isEditingName = true
            } label: {
                Label("Edit Profile", systemImage: "pencil")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.blue)
            
            Button(role: .destructive, action: logout) {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            if let user = Auth.auth().currentUser {
                userEmail = user.email ?? "No email"
                fetchUserData(userId: user.uid)
            }
        }
        .sheet(isPresented: $isEditingName) {
            NavigationView {
                VStack(spacing: 20) {
                    TextField("First Name", text: $editedFirstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Last Name", text: $editedLastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: saveUserData) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isSaving)
                    
                    Spacer()
                }
                .padding(.top, 20)
                .navigationTitle("Edit Profile")
                .navigationBarItems(trailing: Button("Cancel") {
                    isEditingName = false
                })
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                firstName = data?["firstName"] as? String ?? ""
                lastName = data?["lastName"] as? String ?? ""
            }
        }
    }
    
    func saveUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isSaving = true
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).setData([
            "firstName": editedFirstName,
            "lastName": editedLastName
        ], merge: true) { error in
            isSaving = false
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                firstName = editedFirstName
                lastName = editedLastName
                isEditingName = false
            }
        }
    }
}

