//
//  Supabase.swift
//  supdate_native
//
//  Supabase client and config. URL and key are read from Info.plist (set via
//  Supabase.xcconfig) or, if missing, from the bundled Supabase.xcconfig file.
//  Copy Supabase.xcconfig.example to Supabase.xcconfig and do not commit Supabase.xcconfig.
//

import Foundation
import Supabase

enum SupabaseConfig {
    static var url: URL {
        if let s = stringFromInfoOrXcconfig(key: "SupabaseURL", xcconfigKey: "SUPABASE_URL"),
           !s.isEmpty,
           let u = URL(string: s) {
            return u
        }
        fatalError("SupabaseURL missing or invalid. Copy Supabase.xcconfig.example to Supabase.xcconfig and set SUPABASE_URL.")
    }

    static var publishableKey: String {
        if let k = stringFromInfoOrXcconfig(key: "SupabaseKey", xcconfigKey: "SUPABASE_ANON_KEY"),
           !k.isEmpty {
            return k
        }
        fatalError("SupabaseKey missing. Copy Supabase.xcconfig.example to Supabase.xcconfig and set SUPABASE_ANON_KEY.")
    }

    /// Tries Info.plist first, then the bundled Supabase.xcconfig file (for when INFOPLIST_KEY_* doesn't apply, e.g. Previews).
    private static func stringFromInfoOrXcconfig(key: String, xcconfigKey: String) -> String? {
        if let s = Bundle.main.object(forInfoDictionaryKey: key) as? String, !s.isEmpty {
            return s
        }
        return valueFromBundledXcconfig(key: xcconfigKey)
    }

    private static func valueFromBundledXcconfig(key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "Supabase", withExtension: "xcconfig"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") { continue }
            let parts = trimmed.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            if parts.count == 2,
               parts[0].trimmingCharacters(in: .whitespaces) == key {
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.publishableKey
)
