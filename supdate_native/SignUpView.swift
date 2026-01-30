//
//  SignUpView.swift
//  supdate_native
//
//  Sign up with email and password. On success, session updates via AuthState;
//  if email confirmation is on, we show "Check your email to confirm."
//

import Supabase
import SwiftUI

struct SignUpView: View {
    @Environment(\.authState) private var authState

    var onSwitchToSignIn: (() -> Void)?

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showEmailConfirmationMessage = false
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if showEmailConfirmationMessage {
                Section {
                    Text("Check your email to confirm your account.")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Sign up") {
                    Task { await signUp() }
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                .frame(maxWidth: .infinity)
            }

            if let onSwitchToSignIn {
                Section {
                    Button("Already have an account? Sign in") {
                        onSwitchToSignIn()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Sign up")
    }

    private func signUp() async {
        errorMessage = nil
        showEmailConfirmationMessage = false
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            if response.session == nil {
                showEmailConfirmationMessage = true
            }
            // If session is non-nil, AuthState will update and root will show ContentView
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignUpView()
        .environment(\.authState, AuthState())
}
