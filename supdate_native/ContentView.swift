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
    @State private var curatorViewModel = CuratorViewModel()
    @State private var showCuratorPhotoPicker = false
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("'Sup'!")

                photosAccessSection
                curatorSection
            }
            .padding()
        }
        .padding()
        .onAppear {
            photosPermission.refreshStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                photosPermission.refreshStatus()
            }
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
        .sheet(isPresented: $showCuratorPhotoPicker) {
            CuratorPhotoPicker(
                onComplete: { images in
                    showCuratorPhotoPicker = false
                    Task { await curatorViewModel.runCurator(with: images) }
                },
                onCancel: { showCuratorPhotoPicker = false }
            )
        }
    }

    @ViewBuilder
    private var curatorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Curator")
                .font(.headline)
            if curatorViewModel.isIdle {
                Button("Curate My Photos") {
                    showCuratorPhotoPicker = true
                }
                .buttonStyle(.borderedProminent)
            }
            if curatorViewModel.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Choosing your best photo…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            if let rec = curatorViewModel.recommendation,
               rec.recommendedIndex >= 0,
               rec.recommendedIndex < curatorViewModel.selectedImages.count {
                let image = curatorViewModel.selectedImages[rec.recommendedIndex]
                RecommendedPhotoCard(image: image, caption: rec.caption, vibe: rec.vibe)
                HStack(spacing: 12) {
                    Button("Try Again") {
                        showCuratorPhotoPicker = true
                    }
                    .buttonStyle(.bordered)
                    Button("Reset") {
                        curatorViewModel.reset()
                    }
                    .buttonStyle(.bordered)
                }
            }
            if let message = curatorViewModel.errorMessage {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                Button("Try Again") {
                    showCuratorPhotoPicker = true
                }
                .buttonStyle(.bordered)
                Button("Reset") {
                    curatorViewModel.reset()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar, in: RoundedRectangle(cornerRadius: 12))
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
