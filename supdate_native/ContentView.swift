//
//  ContentView.swift
//  supdate_native
//
//  Created by Shaun Hartman on 1/28/26.
//

import Supabase
import SwiftUI

struct ContentView: View {
    @State private var signOutError: String?

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("'Sup'!")
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sign out") {
                    Task { await signOut() }
                }
            }
        }
        .alert("Sign out failed", isPresented: Binding(
            get: { signOutError != nil },
            set: { if !$0 { signOutError = nil } }
        )) {
            Button("OK") { signOutError = nil }
        } message: {
            Text(signOutError ?? "")
        }
    }

    private func signOut() async {
        do {
            try await supabase.auth.signOut()
            // AuthState updates via onAuthStateChange; root shows AuthView
        } catch {
            signOutError = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
