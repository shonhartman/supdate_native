//
//  CuratorViewModel.swift
//  supdate_native
//
//  State and orchestration for the AI Curator: selection, processing, and recommendation.
//

import Observation
import UIKit

enum CuratorState {
    case idle
    case loading
    case success(CuratorRecommendation)
    case error(String)
}

@Observable
final class CuratorViewModel {
    private(set) var state: CuratorState = .idle
    /// Selected images in order; used to show the recommended photo by index.
    private(set) var selectedImages: [UIImage] = []

    var isIdle: Bool {
        if case .idle = state { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var recommendation: CuratorRecommendation? {
        if case .success(let r) = state { return r }
        return nil
    }

    var errorMessage: String? {
        if case .error(let message) = state { return message }
        return nil
    }

    /// Process images and call the Edge Function. Call from main actor after user selects 2–10 photos.
    func runCurator(with images: [UIImage]) async {
        state = .loading
        selectedImages = images

        guard images.count >= 2, images.count <= 10 else {
            state = .error("Please select between 2 and 10 photos.")
            return
        }

        let base64Strings = images.compactMap { CuratorImageProcessor.process($0) }
        guard base64Strings.count == images.count else {
            state = .error("Could not process one or more images.")
            return
        }

        do {
            let result = try await CuratorService.invokeCurator(imagesBase64: base64Strings)
            state = .success(result)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func reset() {
        state = .idle
        selectedImages = []
    }
}
