//
//  Supabase.swift
//  supdate_native
//
//  Supabase client and config. URL and key are read from Info.plist (set via
//  Supabase.xcconfig). Copy Supabase.xcconfig.example to Supabase.xcconfig
//  and do not commit Supabase.xcconfig.
//

import Foundation
import Supabase

enum SupabaseConfig {
    static var url: URL {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
              !s.isEmpty,
              let u = URL(string: s) else {
            fatalError("SupabaseURL missing or invalid. Copy Supabase.xcconfig.example to Supabase.xcconfig and set SUPABASE_URL.")
        }
        return u
    }

    static var publishableKey: String {
        guard let k = Bundle.main.object(forInfoDictionaryKey: "SupabaseKey") as? String,
              !k.isEmpty else {
            fatalError("SupabaseKey missing. Copy Supabase.xcconfig.example to Supabase.xcconfig and set SUPABASE_ANON_KEY.")
        }
        return k
    }
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.publishableKey
)
