//
//  PhotosPermission.swift
//  supdate_native
//
//  Wraps Photo Library authorization: current status and requesting access.
//  Used so the app can prompt for permission and show evidence it was granted.
//

import Photos
import SwiftUI

@Observable
@MainActor
final class PhotosPermission {
    /// Current authorization status for read-write photo library access.
    private(set) var status: PHAuthorizationStatus = .notDetermined

    /// True when the app is allowed to read the photo library (full or limited).
    var hasAccess: Bool {
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined, .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    /// Updates `status` from the system. Call on appear or when returning from Settings.
    func refreshStatus() {
        status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    /// Requests photo library access. Only shows the system dialog when status is `.notDetermined`;
    /// otherwise does nothing. Updates `status` when the user responds.
    func requestAuthorization() {
        let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard current == .notDetermined else {
            status = current
            return
        }
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
            Task { @MainActor in
                self?.status = newStatus
            }
        }
    }
}
