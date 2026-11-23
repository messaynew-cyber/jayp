# JayP

Jason Peters companion app — Ethiopian technology, offline-first.

**Bundle:** `com.adwa.jayp`

## What it actually does

| Feature | Implementation |
|---|---|
| **Offline library** | SQLite (`sqflite`) — 10 bundled episodes, full-text search, category filters |
| **Progress tracking** | Watched/saved state persisted locally, never lost |
| **Ask JayP** | Q&A powered by a live model endpoint, plain-language tech answers |
| **Network** | Live TON price + 24h change, sparkline, venture cards |
| **Share & save** | Native share sheet, clipboard, external YouTube launch |
| **Offline mode** | One switch kills every network call — app stays fully usable |

## Design

Heritage Noir: obsidian `#0D0E12`, velvet teal `#81D1F0`, liquid amber `#FFB77D`.
Every English label carries an Amharic companion. The `ጄ` sigil is the mark.

## Build

CI builds on push to `main`. Download the APK from the Actions artifact
`jayp-unsigned-apk`.

Unsigned release — sideload only.
