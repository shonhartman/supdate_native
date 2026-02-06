//
//  RecommendedPhotoCard.swift
//  supdate_native
//
//  Displays the AI's chosen photo, caption, and vibe in a minimal card.
//

import SwiftUI
import UIKit

struct RecommendedPhotoCard: View {
    let image: UIImage
    let caption: String
    let vibe: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if !caption.isEmpty {
                Text(caption)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            if !vibe.isEmpty {
                Text(vibe)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RecommendedPhotoCard(
        image: UIImage(systemName: "photo")!,
        caption: "Sunset at the pier.",
        vibe: "Chill summer vibes"
    )
    .padding()
}
