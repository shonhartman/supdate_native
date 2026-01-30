//
//  AuthState.swift
//  supdate_native
//
//  Single source of truth for auth session. Subscribes to Supabase auth
//  state changes and updates session so the UI can branch on logged-in vs logged-out.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class AuthState {
    private(set) var session: Session?

    /// True after Supabase has emitted the initial session (restored from storage or nil).
    /// Use this to avoid showing AuthView before we know whether the user is logged in.
    private(set) var hasReceivedInitialSession = false

    var isLoggedIn: Bool { session != nil }
    var currentUser: User? { session?.user }

    private var registration: (any AuthStateChangeListenerRegistration)?

    init() {
        Task { await attachListener() }
    }

    private func attachListener() async {
        let reg = await supabase.auth.onAuthStateChange { [weak self] _, session in
            Task { @MainActor in
                guard let self else { return }
                self.session = session
                self.hasReceivedInitialSession = true
            }
        }
        registration = reg
    }
}

// MARK: - Environment

private struct AuthStateKey: EnvironmentKey {
    static let defaultValue: AuthState? = nil
}

extension EnvironmentValues {
    var authState: AuthState? {
        get { self[AuthStateKey.self] }
        set { self[AuthStateKey.self] = newValue }
    }
}
