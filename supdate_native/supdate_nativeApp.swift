//
//  supdate_nativeApp.swift
//  supdate_native
//
//  Created by Shaun Hartman on 1/28/26.
//

import Supabase
import SwiftUI

@main
struct supdate_nativeApp: App {
    @State private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authState.hasReceivedInitialSession {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if authState.isLoggedIn {
                    NavigationStack {
                        ContentView()
                    }
                } else {
                    NavigationStack {
                        AuthView()
                    }
                }
            }
            .environment(\.authState, authState)
            .onOpenURL { url in
                supabase.auth.handle(url)
            }
        }
    }
}
