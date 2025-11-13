//
//  zenithApp.swift
//  zenith
//
//  Created by Florin Stroe on 13.11.2025.
//

import SwiftUI
import FirebaseCore

@main
struct zenithApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
