//
//  Supabase.swift
//  supdate_native
//
//  Supabase client and config. For production, consider moving URL/key to
//  .xcconfig or environment and not committing secrets.
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://gnejqtjrfepydifheoyx.supabase.co")!
    static let publishableKey = "sb_publishable_i5AkGvXAiUqZYWebue3PVg_cs8nLcrD"
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.publishableKey
)
