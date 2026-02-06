//
//  CuratorPhotoPicker.swift
//  supdate_native
//
//  Presents PHPickerViewController for selecting 2–10 photos.
//

import PhotosUI
import SwiftUI
import UIKit

struct CuratorPhotoPicker: UIViewControllerRepresentable {
    static let minSelection = 2
    static let maxSelection = 10

    var onComplete: ([UIImage]) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = Self.maxSelection
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete, onCancel: onCancel)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: ([UIImage]) -> Void
        let onCancel: () -> Void

        init(onComplete: @escaping ([UIImage]) -> Void, onCancel: @escaping () -> Void) {
            self.onComplete = onComplete
            self.onCancel = onCancel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                picker.dismiss(animated: true)
                onCancel()
                return
            }
            guard results.count >= CuratorPhotoPicker.minSelection else {
                let alert = UIAlertController(
                    title: "More photos needed",
                    message: "Please select at least \(CuratorPhotoPicker.minSelection) photos to curate.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                picker.present(alert, animated: true)
                return
            }
            picker.dismiss(animated: true)
            loadImages(from: results) { [onComplete] images in
                DispatchQueue.main.async {
                    onComplete(images)
                }
            }
        }

        private func loadImages(from results: [PHPickerResult], completion: @escaping ([UIImage]) -> Void) {
            let group = DispatchGroup()
            var slotImages: [UIImage?] = Array(repeating: nil, count: results.count)
            let lock = NSLock()
            for (index, result) in results.enumerated() {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    defer { group.leave() }
                    if let image = object as? UIImage {
                        lock.lock()
                        slotImages[index] = image
                        lock.unlock()
                    }
                }
            }
            group.notify(queue: .global(qos: .userInitiated)) {
                lock.lock()
                let ordered = slotImages.compactMap { $0 }
                lock.unlock()
                completion(ordered)
            }
        }
    }
}
