//
//  AuthView.swift
//  supdate_native
//
//  Container for auth screens: Sign in (default) with link to Sign up, and vice versa.
//

import SwiftUI

struct AuthView: View {
    @State private var showSignUp = false

    var body: some View {
        if showSignUp {
            SignUpView(onSwitchToSignIn: { showSignUp = false })
        } else {
            SignInView(onSwitchToSignUp: { showSignUp = true })
        }
    }
}

#Preview {
    AuthView()
        .environment(\.authState, AuthState())
}
