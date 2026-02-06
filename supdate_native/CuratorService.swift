//
//  CuratorService.swift
//  supdate_native
//
//  Invokes the recommend-photo Edge Function and decodes the recommendation.
//

import Foundation
import Supabase

struct CuratorRecommendation: Decodable {
    let recommendedIndex: Int
    let caption: String
    let vibe: String
}

enum CuratorService {
    private static let functionName = "recommend-photo"

    private struct InvokeBody: Encodable {
        let images: [String]
    }

    /// Sends base64 image strings to the Edge Function and returns the decoded recommendation.
    /// Requires an authenticated session. The Supabase client automatically attaches the user's JWT
    /// to the request. We refresh the session only when the token is expired or near expiry to avoid
    /// extra latency and to work better when offline with a valid cached token.
    static func invokeCurator(imagesBase64: [String]) async throws -> CuratorRecommendation {
        let session = try await supabase.auth.session
        if session.isExpired {
            try await supabase.auth.refreshSession()
        }
        let body = InvokeBody(images: imagesBase64)
        let options = FunctionInvokeOptions(body: body)
        let response: CuratorRecommendation = try await supabase.functions.invoke(
            functionName,
            options: options
        )
        return response
    }
}
