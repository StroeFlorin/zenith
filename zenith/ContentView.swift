//
//  ContentView.swift
//  zenith
//
//  Created by Florin Stroe on 13.11.2025.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                LoggedInView(isAuthenticated: $isAuthenticated)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
    }
    
    func checkAuthenticationStatus() {
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        }
    }
}

#Preview {
    ContentView()
}
