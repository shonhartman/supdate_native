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

### Deploying the AI Curator Edge Function

The `recommend-photo` Edge Function lives in `supabase/functions/recommend-photo/` and uses **Google Gemini 2.5 Flash (vision)** to pick the best photo and generate a caption and vibe. To deploy:

1. Install the [Supabase CLI](https://supabase.com/docs/guides/cli) and log in.
2. From the repo root, link the project (one-time): `supabase link --project-ref <your-project-ref>`.
3. Set the Gemini API key (get one at [Google AI Studio](https://aistudio.google.com/apikey)):  
   `supabase secrets set GEMINI_API_KEY=<your-key>`
4. Deploy with JWT verification skipped at the gateway (the function verifies the JWT itself):  
   `supabase functions deploy recommend-photo --no-verify-jwt`

The function accepts `{ "images": [ "<base64>", ... ] }` (2–10 items) and returns `{ "recommendedIndex", "caption", "vibe" }`. It requires a signed-in user (JWT). If you get **401 Unauthorized**, ensure you’re signed in in the app, the app’s `SUPABASE_URL` / `SUPABASE_ANON_KEY` match the linked project, and the function verifies the JWT inside the function. If 401, ensure you're signed in.

---

## License

Proprietary.
