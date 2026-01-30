//
//  supdate_nativeApp.swift
//  supdate_native
//
//  Created by Shaun Hartman on 1/28/26.
//

import SwiftUI

@main
struct supdate_nativeApp: App {
    @State private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            Group {
                if authState.isLoggedIn {
                    NavigationStack {
                        ContentView()
                    }
                } else {
                    AuthView()
                }
            }
            .environment(\.authState, authState)
        }
    }
}
