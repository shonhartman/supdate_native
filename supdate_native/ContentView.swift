//
//  ContentView.swift
//  supdate_native
//
//  Created by Shaun Hartman on 1/28/26.
//

import Photos
import Supabase
import SwiftUI

struct ContentView: View {
    @State private var photosPermission = PhotosPermission()
    @State private var signOutError: String?
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("'Sup'!")

            photosAccessSection
        }
        .padding()
        .onAppear {
            photosPermission.refreshStatus()
        }
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

    @ViewBuilder
    private var photosAccessSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(photosAccessStatusText)
                .font(.subheadline)

            if photosPermission.status == .notDetermined {
                Button("Grant access") {
                    photosPermission.requestAuthorization()
                }
                .buttonStyle(.borderedProminent)
            }

            if photosPermission.status == .denied || photosPermission.status == .restricted {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar, in: RoundedRectangle(cornerRadius: 12))
    }

    private var photosAccessStatusText: String {
        if photosPermission.hasAccess {
            return "Photos access: Granted"
        }
        switch photosPermission.status {
        case .notDetermined:
            return "Photos access: Not set"
        case .denied, .restricted:
            return "Photos access: Not allowed. You can enable it in Settings."
        default:
            return "Photos access: Not set"
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
