# supdate_native

**Supdate** is an AI-automated social media engine built to leverage local device sensors—HealthKit, CoreLocation, and related hardware—to drive context-aware, automated content and engagement.

This repository is the **pure SwiftUI native pilot**: a high-performance iOS app focused on background tasks, deep hardware integration, and pushing native performance limits.

---

## Technical Architecture

- **Pure SwiftUI** native implementation (no cross-platform UI layer).
- Optimized for **background execution** and **sensor pipelines** (health, location, motion).
- **Deep hardware integration** via Apple frameworks; no abstraction layer over device APIs.

**Parallel pilot:** This project runs alongside a Flutter version. Both implementations share product goals; the native pilot exists to benchmark performance, battery impact, and sensor fidelity against the Flutter baseline.

---

## Tech Stack

|              |         |
| ------------ | ------- |
| **Language** | Swift 6 |
| **UI**       | SwiftUI |
| **Target**   | iOS 18+ |

---

## Current State

Minimal SwiftUI shell: `supdate_nativeApp` → `WindowGroup` → `ContentView` (placeholder UI). App entry and structure are in place; sensor integration and AI automation are planned.

---

## Setup

1. Clone the repo.
2. **Supabase (auth):** Copy `Supabase.xcconfig.example` to `Supabase.xcconfig` and set `SUPABASE_URL` and `SUPABASE_ANON_KEY` to your project’s values. Do not commit `Supabase.xcconfig` (it is gitignored).
3. Open `supdate_native.xcodeproj` in Xcode.
4. Select a simulator or device (iOS 18+).
5. Run (⌘R).

---

## License

Proprietary.
