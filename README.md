# Studlok

**Earn Your Scroll.**

Studlok locks the distracting apps on your phone (Instagram, TikTok, whatever
pulls you in) until you finish a real study session. Not a reminder you can
swipe away, an actual OS-enforced lock, built on Apple's Family Controls /
Screen Time framework. Finish a Deep Work session or pass a Quiz, and your
apps unlock for exactly as long as you earned, then lock again automatically.

Built solo, for [RevenueCat's Shipaton 2026](https://www.shipaton.com/) (Next Gen Award track).

## Why

I was studying for a Physics exam and kept opening Instagram and YouTube to
"just take a quick break." I failed that exam, not because the material was
impossible, but because I couldn't keep my own phone out of my own way for
long enough to actually learn it. Studlok is the app I wished existed that
day: no willpower required, just a real lock and a real way to earn it back.

## How it works

1. **Pick what to lock** — choose the apps that eat your time. They lock immediately.
2. **Earn your way back in** — finish a Deep Work session or pass a Quiz.
3. **Unlock, then re-lock** — apps open for exactly as long as you earned, then lock again automatically.

## Features

- **Real enforcement** — native Swift, built on `FamilyControls` / `ManagedSettings` / `DeviceActivityMonitor`, not a Flutter-only reminder.
- **Deep Work & Quiz sessions** — two ways to earn scroll time back, whichever fits the moment.
- **Hardcoded practice packs** — Test Prep (SAT/AP-style, ~90 questions) and CS & Coding (~70 questions), with local spaced repetition (weighted toward what you actually got wrong) and per-pack mastery tracking. No backend needed for any of this.
- **AI-generated quizzes (Pro)** — sign in with Apple or Google, upload a photo or PDF of your own course notes, and get a real quiz generated from that material via Anthropic's Claude API.
- **Adjustable pass threshold** — the score needed to unlock scroll time is a setting (50-90%), not a hardcoded number.
- **GPA goal tracking** — set a GPA goal in onboarding, see real ongoing progress toward it on the dashboard (sessions completed, questions mastered), never a fabricated prediction.
- **Studlok Pro** — a free daily session cap, removed by an auto-renewing subscription (RevenueCat), which also unlocks the AI quiz feature.
- **Privacy-first** — the core app needs no account at all; everything (locked apps, session history, streak, practice history) stays on-device. Signing in is optional and only required for the AI quiz feature.

## Tech stack

| Layer | Technology |
|---|---|
| App | Flutter / Dart (MVVM: `provider` + `ChangeNotifier` ViewModels) |
| Lock mechanic | Native Swift — `FamilyControls`, `ManagedSettings`, `DeviceActivityMonitor`, Shield extensions |
| Backend | Supabase (Postgres + Row Level Security + Storage + Edge Functions) |
| Auth | Sign in with Apple / Google, native ID-token flow |
| AI | Anthropic Claude API (forced tool-use for reliable structured quiz output) |
| Payments | RevenueCat (subscriptions, paywall, entitlements) |
| Website | Next.js + Tailwind, separate repo ([studlok.vercel.app](https://studlok.vercel.app)) |

## Project structure

```
studlok/
├── lib/               # Flutter app (onboarding, sessions, quiz, progress, settings)
├── ios/
│   ├── Runner/        # Main app target
│   ├── Shared/        # App Group shared state, used by every target below
│   ├── monitor/        DeviceActivityMonitor extension
│   ├── shieldconfig/    Shield appearance extension
│   └── shieldaction/    Shield button-tap extension
├── supabase/
│   ├── schema.sql      # Postgres tables + RLS policies
│   ├── storage.sql     # Storage bucket + policies
│   └── functions/       generate-quiz, delete-account (Edge Functions)
└── assets/            # Fonts (Clash Display), app icon
```

## Running it locally

```bash
cd studlok
flutter pub get
flutter run
```

The core lock/session/quiz-pack experience runs with no setup beyond that.
The optional sign-in and AI quiz features need their own Supabase project,
RevenueCat project, and Anthropic API key (the schema and Edge Functions in
`supabase/` are included; the actual secrets are not, since they're
per-developer credentials, not part of the app itself).

## License

GPL-3.0 (see [LICENSE](LICENSE)). Anyone who forks and redistributes a
modified version has to release their source too.

## Links

- [Website](https://studlok.vercel.app)
- [Privacy Policy](https://studlok.vercel.app/privacy)
- [Terms of Use](https://studlok.vercel.app/terms)
