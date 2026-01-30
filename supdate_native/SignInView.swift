//
//  SignInView.swift
//  supdate_native
//
//  Sign in with email and password. On success, AuthState updates and root shows main content.
//

import Supabase
import SwiftUI

struct SignInView: View {
    @Environment(\.authState) private var authState

    var onSwitchToSignUp: (() -> Void)?

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Sign in") {
                    Task { await signIn() }
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                .frame(maxWidth: .infinity)
            }

            if let onSwitchToSignUp {
                Section {
                    Button("Create account") {
                        onSwitchToSignUp()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Sign in")
    }

    private func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await supabase.auth.signIn(email: email, password: password)
            // AuthState will update via onAuthStateChange; root shows ContentView
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
        .environment(\.authState, AuthState())
}
