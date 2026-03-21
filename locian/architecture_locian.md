# LOCIAN — Full Architecture & Code Execution Walkthrough

> **Version:** V3.45 Context Intelligence  
> **Stack:** SwiftUI · Combine · AVFoundation · NaturalLanguage · Hume AI · Python (Render)  
> Last updated: 2026-03-04

---

## Table of Contents

1. [App Lifecycle & Boot Sequence](#1-app-lifecycle--boot-sequence)
2. [AppStateManager — Global Brain](#2-appstatemanager--global-brain)
3. [Authentication Flow](#3-authentication-flow)
4. [Loading Screen — Animations Deep Dive](#4-loading-screen--animations-deep-dive)
5. [LearnTab — Discovery → Lesson Pipeline](#5-learntab--discovery--lesson-pipeline)
6. [Lesson Engine — Code Execution System](#6-lesson-engine--code-execution-system)
7. [Voice System — Two-Layer TTS Architecture](#7-voice-system--two-layer-tts-architecture)
8. [Embedding & Semantic Intelligence](#8-embedding--semantic-intelligence)
9. [Location & Context Intelligence](#9-location--context-intelligence)
10. [Stats Tab](#10-stats-tab)
11. [API Layer](#11-api-layer)
12. [Services Directory](#12-services-directory)
13. [Shared UI Components](#13-shared-ui-components)
14. [Data Models Reference](#14-data-models-reference)

---

## 1. App Lifecycle & Boot Sequence

```
locianApp.swift
    └─ ContentView.swift
           └─ AppStateManager.shared (singleton)
                   │
                   ├─ [1] hasCompletedOnboarding == false  → OnboardingContainerView
                   ├─ [2] isLoadingSession == true          → LoadingView (spinner)
                   ├─ [3] isLoggedIn == true                → MainTabView
                   └─ [4] else                              → LoginView
```

**State transitions** use `.easeInOut(duration: 0.5)` crossfades via `ZStack + .transition(.opacity)` in `ContentView`. No hard snaps.

### Boot Order (Happy Path)

| Step | What Happens | File |
|------|-------------|------|
| 1 | `locianApp` creates `ContentView` | `locianApp.swift` |
| 2 | `AppStateManager.init()` loads UserDefaults (token, language pairs, Hume keys, theme) | `AppStateManager.swift:294` |
| 3 | `ContentView.onAppear` → `checkUserSession()` | `AppStateManager+Auth.swift` |
| 4 | `isLoadingSession = true` → `LoadingView` shown | |
| 5 | If token valid → `loadUserData()` → `EmbeddingService.prepareModels()` fires proactively | `AppStateManager.swift:405` |
| 6 | `isLoadingSession = false`, `isLoggedIn = true` → **MainTabView** | |
| 7 | `AppLaunchLoadingView` fires its animation sequence on `.onAppear` | `AppLaunchLoadingView.swift:74` |
| 8 | `NotificationManager.shared.startMonitoring()` starts async | `AppStateManager.swift:342` |

---

## 2. AppStateManager — Global Brain

**File:** `AppStateManager/AppStateManager.swift` (489 lines)  
**Pattern:** Singleton `ObservableObject` — all views observe via `@StateObject` / `@ObservedObject`

### Key Published State

| Property | Type | Purpose |
|----------|------|---------|
| `isLoggedIn` | `Bool` | Controls root nav |
| `isLoadingSession` | `Bool` | Shows LoadingView |
| `hasCompletedOnboarding` | `Bool` | Persisted to UserDefaults |
| `userLanguagePairs` | `[LanguagePair]` | Native + target language(s) |
| `isHumeVoiceEnabled` | `Bool` | Routes TTS to Hume or local |
| `humeApiKey` | `String?` | Hume AI API key |
| `selectedTheme` | `String` | "Neon Green" default → `ThemeColors` |
| `showDiagnosticBorders` | `Bool` | `DebugConfig` toggle for dev borders |
| `intentTimeline` | `[String: TimeSpanSnapshot]?` | Ephemeral — cleared each session |
| `geoContexts` | `[String: GeoContextData]` | Persisted geo signals |

### Study Points Calculation

```swift
var totalStudyPoints: Int {
    let practiceDaysCount = userLanguagePairs
        .first(where: { $0.is_default })?.practice_dates.count ?? 0
    return practiceDaysCount * 10  // 10 points per practice day
}
```

### Extensions Architecture

| File | Responsibility |
|------|---------------|
| `+Auth.swift` | `checkUserSession()`, `logoutLocalOnly()`, session token validation |
| `+AppleAuth.swift` | Sign in with Apple handler |
| `+GuestLogin.swift` | Guest login flow |
| `+Language.swift` | Language pair management, `hasValidLanguagePair()` |
| `+Profile.swift` | User profile updates |

---

## 3. Authentication Flow

```
LoginView
    ├─ Apple Sign In → AppStateManager+AppleAuth
    ├─ Guest Login   → AppStateManager+GuestLogin
    └─ [Either path]
            └─ authToken stored in UserDefaults
                    └─ isLoggedIn = true → MainTabView
```

**Session expired:** `NotificationCenter` posts `"SessionExpired"` → `ContentView.onReceive` → `appState.logoutLocalOnly()` → back to `LoginView`.

---

## 4. Loading Screen — Animations Deep Dive

**File:** `Shared/AppLaunchLoadingView.swift`  
**Used when:** `AppStateManager.isLoadingSession == true` (inside `MainTabView`)

### State Variables

| Variable | Initial Value | Animates To |
|----------|-------------|------------|
| `logoOpacity` | `0.0` | `1.0` |
| `logoScale` | `0.82` | `1.0` |
| `asteriskOpacity` | `0.0` | `1.0` |
| `asteriskScale` | `0.82` | `1.0` |
| `letterOpacities[6]` | `[0,0,0,0,0,0]` | `[1,1,1,1,1,1]` |
| `letterScales[6]` | `[0.9×6]` | `[1.0×6]` |
| `subtitleOpacity` | `0.0` | `1.0` |
| `dotCount` | `0` | cycles 0→1→2→3→0 every 0.5s |

### Animation Sequence (Timeline)

```
T+0.08s  ████████░░░░  Comma logo fades in (easeOut 0.7s)
T+0.28s  ░░░░████████  Asterisk fades in (easeOut 0.7s, delay 0.2)
T+0.98s  L         (easeOut 0.4s)    ← asyncAfter, NOT .delay()
T+1.06s   O        (easeOut 0.4s)
T+1.14s    C       (easeOut 0.4s)
T+1.22s     I      (easeOut 0.4s)
T+1.30s      A     (easeOut 0.4s)
T+1.38s       N    (easeOut 0.4s)
T+1.58s  ADAPTIVE LANGUAGE ENGINE fades in (easeOut 0.4s)
```

**Key design decision:** Letters use `DispatchQueue.main.asyncAfter` not `withAnimation(.delay())`. This is critical — SwiftUI's `.delay()` can be dropped if the main thread is busy at that exact millisecond. `asyncAfter` fires independently from the run loop, guaranteed.

**Why start at scale 0.82:** Starting from 0.0 causes a jarring "pop from nowhere" effect. 0.82 gives a subtle, professional scale-up without visual shock.

**Why no `.trim()` on CommaShape:** `.trim()` calls `path(in:)` on every animation frame (~96fps). A bezier path with 7 control points × 96 = 672 path recalculations/second. Removed entirely — now static fill called once.

### SemicolonLogoView

The logo is composed of:
- `CommaShape` — white comma with curved tail (bezier, 7 points)
- `Text("*")` — asterisk overlaid at `.topTrailing` with `offset(x: 46, y: -20)`, size 68pt `.black` weight, `ThemeColors.secondaryAccent` (pink) color

### CommaShape Path (7-point bezier)

```
move → (0,0)           top-left
line → (w,0)           top-right
line → (w, blockHeight) right side
curve → (tailTipX, h)  outer tail sweep
line → (tailTipX, h-tipEdgeHeight) blunt tip edge
curve → (indentWidth, blockHeight) inner tail curve
line → (0, blockHeight) inner horizontal
line → (0, 0)           back to start
close
```

---

## 5. LearnTab — Discovery → Lesson Pipeline

**Key Files:**
- `Scene/LearnTabLogic/LearnTabState.swift`
- `Scene/LearnTabLogic/View/LearnTabView.swift`
- `Endpoints/DiscoverMoments/`
- `Endpoints/GenerateSentence/`

### Full V3 Data Pipeline

```
User opens Learn Tab
        │
        ▼
LearnTabState.discover()
        │
        ▼
DiscoverMomentsService.discoverMoments(explicitRequest:, image:)
        │   POST /api/learning/discover-moments
        │   Body: { location, velocity, weather, time, explicit_request?, image? }
        │
        ▼
API Response: [PlaceRecommendation]
        │   Each recommendation has:
        │     - place_id: String
        │     - grounding: String (micro-situation description)
        │     - patterns: [RecommendationPattern]
        │       Each pattern: { target, meaning, phonetic, bricks }
        │         bricks: { constants, variables, structural }
        │
        ▼
LearnTabState.recommendations = filteredRecs
  (filter: remove "unknown" place_id, remove zero-pattern recommendations)
        │
[User taps START PRACTICE]
        │
        ▼
LearnTabState.startPractice()
        │
        ▼
GenerateSentenceLogic.hydrateFromV3(recommendation:)
  [On background queue: .userInitiated]
        │
        ├─ For each RecommendationPattern:
        │     ├─ Create PatternData (with EmbeddingService vector)
        │     ├─ Convert bricks → BrickItem[] (constants/variables/structural, each vectorized)
        │     └─ Create LessonGroup { patterns:[patternData], bricks }
        │
        ▼
GenerateSentenceData assembled:
  { target_language, user_language, place_name, micro_situation,
    lesson_id (v3-UUID), groups:[LessonGroup], patterns:[PatternData] }
        │
[DispatchQueue.main.async]
        │
        ▼
LearnTabState.currentLesson = lessonData
LearnTabState.showLessonView = true
        │
        ▼
LessonView presented (fullScreenCover)
        │
        ▼
LessonEngine.initialize(from: lessonData)
```

### Discovery Triggers

| Trigger | Method |
|---------|--------|
| App open / pull to refresh | `discover()` |
| Text input ("I'm at a cafe") | `discover(explicitText:)` |
| Camera image | `discover(image:)` |
| Nearby place tap | `selectNearbyPlace()` → `discover(explicitText: name)` |
| Deep link (notification) | `handleDeepLink()` → `discover(explicitText: "I am at \(place)")` |

---

## 6. Lesson Engine — Code Execution System

**Location:** `Scene/LessonEngine/`  
**Architecture:** Multi-stage drill system with a 4-stage pipeline per pattern

### Directory Map

```
LessonEngine/
├── Core/              LessonEngine.swift, LessonEngineModels.swift
├── FlowAlgorithm/     LessonEngine+Orchestration.swift, LessonEngine+Flow.swift
├── PatternDrills/     VocabIntro, PatternPractice, PatternIntroView
├── BrickDrills/       BrickVoice, BrickMCQ, BrickBuilder, BrickTyping
├── GhostMode/         Ghost rehearsal (full sentence from memory)
├── Validation/        AnswerValidator, ContentAnalyzer, SimilarityValidator
├── OptionGeneration/  Distractor generation for MCQ
├── Filtering/         Pattern/brick filtering logic
├── Analytics/         Mastery tracking
└── Views/             LessonView, LessonCompleteView
```

### 4-Stage Pattern Lifecycle

Each `PatternData` passes through 4 stages via `LessonOrchestrator`:

```
Stage 1: VOCAB INTRO
  DrillMode.vocabIntro
  → Shows pattern target + meaning
  → Plays TTS (target language + native language pair)
  → User reads/listens, taps to continue

Stage 2: PATTERN PRACTICE  
  DrillMode.patternPractice
  → Brick-level drills (MCQ / voice / builder / typing)
  → Each brick in { constants ∪ variables ∪ structural } gets its own drill
  → Drill type selected based on FlowAlgorithm rules

Stage 3: GHOST MODE
  DrillMode.ghostManager  
  → Full sentence recall from memory (no prompts)
  → User hears the native meaning → must produce target language sentence
  → Semantic similarity checked via EmbeddingService

Stage 4: COMPLETE
  → orchestrator.finishPattern()
  → engine.patternCompleted(id:)
  → Next pattern loads OR LessonComplete shown
```

### LessonOrchestrator State Machine

```swift
class LessonOrchestrator {
    @Published var activeState: DrillState?
    
    func startPattern(_ pattern: PatternData)     // enters Stage 1
    func finishVocabIntro()                       // Stage 1 → Stage 2
    func finishPatternPractice()                  // Stage 2 → Stage 3
    func finishGhostMode(for patternId: String?)  // Stage 3 → Stage 4
    func finishPattern(for patternId: String?)     // Stage 4: cleanup
}
```

**Identity guard ("Late Assassin" protection):** Every `finish*()` call checks `currentPattern.id == patternId`. If a delayed callback fires from a previous pattern after the user moved on, it is silently dismissed:
```swift
if let id = patternId, current.id != id {
    print("⚠️ [GHOST COURT] DISMISSED LATE FINISH SIGNAL")
    return
}
```

### DrillState Model

```swift
struct DrillState {
    let id: String          // Clean pattern ID (no mode suffix)
    let patternId: String
    let drillIndex: Int
    let drillData: DrillItem
    let isBrick: Bool
    let currentMode: DrillMode?  // nil = selector decides
}
```

### Drill Types (DrillMode enum)

| Mode | Description |
|------|-------------|
| `.vocabIntro` | Intro card with TTS playback |
| `.patternPractice` | Contains sub-drills for bricks |
| `.brickVoice` | Mic recording → speech recognition → validation |
| `.brickMCQ` | Multiple choice from 4 distractors |
| `.brickBuilder` | Tap-to-arrange word tiles |
| `.brickTyping` | Free text input with keyboard |
| `.ghostManager` | Full sentence ghost rehearsal |
| `.typing` | Final typing drill |

### Validation System (`Validation/`)

Three validators in cascade:

```
User Answer
    │
    ▼
1. ExactMatchValidator
   "¿Cómo estás?" == "¿cómo estás?" (case-insensitive, trimmed)
    │ fail
    ▼
2. ContentAnalyzer
   Checks key words present, handles contractions, partial credit
    │ fail  
    ▼
3. SimilarityValidator (EmbeddingService)
   cosineSimilarity(userVector, targetVector) > threshold (0.75)
   → CORRECT if similarity high enough
```

---

## 7. Voice System — Two-Layer TTS Architecture

**Files:** `Services/AudioManager.swift`, `Services/HumeTTSService.swift`

### Architecture Overview

```
Any code that needs speech
        │
        ▼
AudioManager.shared.speak(text: "¿Cómo estás?", language: "es-ES")
        │
        ├─ isHumeVoiceEnabled == true?
        │       │ YES
        │       └─ HumeTTSService.shared.speak(fullText)
        │               └─ POST https://api.hume.ai/v0/tts
        │                   Body: { utterances: [{ text }], format: { type: "mp3" } }
        │                   X-Hume-Api-Key: [humeApiKey]
        │                       │ success
        │                       └─ base64 audio → AVAudioPlayer.play()
        │                       │ failure (network/API error)
        │                       └─ FALLBACK → AVSpeechSynthesizer
        │
        └─ isHumeVoiceEnabled == false
                └─ AVSpeechSynthesizer
                    ├─ rate: 0.4 (80% of normal speed 0.5)
                    └─ voice: AVSpeechSynthesisVoice(language: language)
```

### AudioManager Threading Model

```
All audio operations → DispatchQueue("com.locian.audio", qos: .userInitiated)
│
├─ configureSession()     // AVAudioSession setup
├─ internalStop()         // synthesizer.stopSpeaking(.immediate) + HumeTTSService.stop()
└─ speakLocalSegments()   // runs synchronously on audioQueue

Completion callbacks → DispatchQueue.main.async  (always on main thread)
```

### Audio Session Modes

| Mode | Category | Options |
|------|----------|---------|
| `.playback` | `.playback` | `.duckOthers` |
| `.recording` | `.playAndRecord` | `.duckOthers`, `.defaultToSpeaker` |

### HumeTTSService Details

- **Model:** Hume Octave (expressive neural TTS)
- **Endpoint:** `POST https://api.hume.ai/v0/tts`
- **Auth:** `X-Hume-Api-Key` header
- **Format requested:** `{ type: "mp3", container: "mp3" }`
- **Response:** `generations[0].audio` (base64-encoded MP3)
- **Playback rate:** `AVAudioPlayer.rate = 1.6` (fast but clear)
- **Voice selection:** No hardcoded voice ID — lets Hume use default voice

### Hume Failure Recovery

```
HumeTTSService failure
    → onFailure() callback fires
    → AudioManager.audioQueue.async { speakLocalSegments(segments) }
    → Zero gap — fallback starts immediately
```

---

## 8. Embedding & Semantic Intelligence

**File:** `Services/EmbeddingService.swift`  
**Framework:** Apple `NaturalLanguage` framework (on-device, zero latency)

### Two-Tier Model System

```
Text → getVector(for: text, languageCode: code)
        │
        ├─ iOS 17+: NLContextualEmbedding (transformer-based, context-aware)
        │     → embeddingResult(for:) → enumerate token vectors → mean pool → [Double]
        │
        └─ iOS <17 fallback: NLEmbedding (static word/sentence vectors)
              → NLEmbedding.sentenceEmbedding(for:) (preferred)
              → NLEmbedding.wordEmbedding(for:) (fallback)
```

### Vector Cache

All computed vectors are cached in memory:
```swift
private static var vectorCache: [String: [Double]] = [:]
// key: "\(text.lowercased())_\(languageCode)"
```

### Cosine Similarity (Used for Answer Validation)

```swift
static func cosineSimilarity(v1: [Double], v2: [Double]) -> Double {
    dot(v1,v2) / (magnitude(v1) * magnitude(v2))
}
// Output: 0.0 (completely different) → 1.0 (identical meaning)
// Threshold for "correct" answer: ~0.75
```

### Proactive Model Download

On every successful login:
```swift
var proactiveCodes = Set([self.nativeLanguage])
self.userLanguagePairs.forEach { proactiveCodes.insert($0.target_language) }
EmbeddingService.prepareModels(for: proactiveCodes)
```
This runs in the background via `NLContextualEmbedding.requestAssets()` so models are warm by the time the user starts a lesson.

### Enrichment Pipeline (GenerateSentenceLogic)

Every API response is enriched with vectors before reaching the LessonEngine:
```
parseResponse():
    For each group.pattern     → vector = getVector(pattern.meaning, langCode)
    For each group.brick       → vector = getVector(brick.meaning,   langCode)
                                 (constants, variables, structural independently)
```

---

## 9. Location & Context Intelligence

**File:** `Services/LocationManager.swift` (13,513 bytes — largest service)  
**File:** `Services/MotionService.swift`  
**File:** `Services/WeatherServiceManager.swift`

### Context Signals Collected

| Signal | Source | Used For |
|--------|--------|---------|
| GPS coordinates | `CLLocationManager` | Place detection |
| Velocity (m/s) | `CLLocation.speed` | Stationary/moving/transit |
| Weather condition | `WeatherServiceManager` | "raining", "sunny" context |
| Time of day | System clock | Morning/afternoon/evening |
| Nearby places | MapKit `MKLocalSearch` | Place name suggestion |

### Velocity Classification

```
< 0.5 m/s  → "stationary"
0.5-4 m/s  → "walking"  
4-15 m/s   → "cycling"
> 15 m/s   → "transit"
```

### Context Bundle → API

All context signals bundled into the `/discover-moments` request:
```json
{
  "location": "37.7749,-122.4194",
  "velocity": "stationary",
  "weather": "clear",
  "time_of_day": "morning",
  "explicit_request": null,
  "image": null
}
```

---

## 10. Stats Tab

**Files:** `Scene/StatsTabLogic/View/StatsTabView.swift`, `StatsTabState.swift`

### Calendar Visualization

Uses `ChamferedShape(chamferSize: 16, cornerRadius: 0)` for each day cell:
- **Today:** White fill + neon pink dot (top-right corner)
- **Practiced:** Neon Green fill + red date number
- **Not practiced:** 5% white fill (nearly invisible) + gray number
- **Shape:** Only bottom-right corner is chamfered at 45°, 16pt depth

### CyberRefreshIndicator

Shown during data loading in both Learn and Stats tabs.

---

## 11. API Layer

**Base URL:** `http://192.168.0.101:8000` (local dev) / `https://locian-main.onrender.com` (prod)  
**File:** `Services/APIConfig.swift`  
**Base Manager:** `Services/BaseAPIManager.swift`

### Endpoints

| Endpoint | Method | File |
|----------|--------|------|
| `POST /api/learning/discover-moments` | POST | `Endpoints/DiscoverMoments/` |
| `POST /api/learning/generate-sentence` | POST | `Endpoints/GenerateSentence/` |
| `GET /api/user/details` | GET | `Endpoints/GetUserDetails/` |
| `POST /auth/login/apple` | POST | `Endpoints/LoginWithApple/` |
| `POST /auth/login/guest` | POST | `Endpoints/GuestLogin/` |
| `POST /auth/logout` | POST | `Endpoints/Logout/` |
| `GET /auth/check-session` | GET | `Endpoints/CheckSession/` |
| `POST /api/user/native-language` | POST | `Endpoints/UpdateNativeLanguage/` |
| `GET /api/languages/target` | GET | `Endpoints/GetTargetLanguages/` |
| `POST /api/context/user-intent` | POST | `Endpoints/UserIntentContext/` |

### BaseAPIManager

Handles:
- Auth token injection (`Authorization: Bearer <token>`)
- Response decoding with `ErrorHandler`
- Session expiry detection → posts `"SessionExpired"` notification
- `isOffline` detection

---

## 12. Services Directory

| File | Purpose |
|------|---------|
| `APIConfig.swift` | `baseURL` constant |
| `AudioManager.swift` | Unified TTS orchestrator (Hume + local) |
| `BaseAPIManager.swift` | HTTP request base class |
| `EmbeddingService.swift` | On-device semantic vector engine |
| `HumeTTSService.swift` | Hume AI TTS (expressive neural voice) |
| `LocationManager.swift` | GPS, velocity, nearby places |
| `MotionService.swift` | Accelerometer for motion detection |
| `PermissionsService.swift` | Location / mic / notification permissions |
| `TimelineContextModels.swift` | `TimeSpanSnapshot`, `GeoContextData` models |
| `WeatherServiceManager.swift` | Weather API wrapper |

---

## 13. Shared UI Components

| File | What It Provides | Used By |
|------|-----------------|---------|
| `AppLaunchLoadingView.swift` | Boot animation: comma logo + letters | `MainTabView` |
| `ButtonAnimationModifier.swift` | `.buttonPressAnimation()` modifier | Buttons throughout |
| `CategoryUI.swift` | `icon(for: place_id)` → SF Symbol mapping (26 place types) | `LearnTabView` |
| `ChamferedShape.swift` | Bottom-right chamfered shape | `StatsTabView`, `CyberComponents` |
| `ColorExtension.swift` | `Color(hex:)` init + utilities | Global |
| `CyberComponents.swift` | `CyberOption`, `LessonPromptHeader`, `CyberProceedButton`, `MCQSelectionGrid`, `TypingInputArea`, `TechFrameBorder` | LessonEngine views |
| `CyberRefreshIndicator.swift` | Loading spinner with cyber aesthetic | `LearnTabView`, `StatsTabView` |
| `DebugConfig.swift` | Dev-only flags (diagnostic borders) | Settings |
| `DoubleArrowButton.swift` | Animated double-arrow proceed button | `LearnTabView` |
| `ErrorHandler.swift` | API error parsing | `BaseAPIManager` |
| `FlowLayout.swift` | Wrapping flow layout for word tiles | `PatternBuilderView`, `PatternTypingView`, `LoginView` |
| `HapticFeedback.swift` | `buttonPress()`, `buttonRelease()`, `correct()`, `wrong()` | `DoubleArrowButton`, `LessonEngine` |
| `HorizontalMasonryLayout.swift` | Horizontal masonry for moment tags | `LearnTabView` |
| `ImagePicker.swift` | Camera + photo library picker | `LearnTabView` |
| `LocianButton.swift` | Primary branded button with shadow offset | `CyberComponents`, modals |
| `PatternProgressDisc.swift` | Progress discs shown in `LessonPromptHeader` | `CyberComponents` |
| `ScaleButtonStyle.swift` | `.scaleEffect` on press | Various |
| `SharedMicButton.swift` | Mic recording button | `PatternDictationView`, `BrickVoiceView` |
| `SharedModels.swift` | Shared lightweight model structs | Global |
| `ThemeColors.swift` | `getColor(for: theme)`, `secondaryAccent` (pink) | Everything |
| `VerticalHeading.swift` | Rotated vertical text label | `LearnTabView`, `SettingsView` |
| `ViewModifiers.swift` | `.locianHardShadow()`, `.cyberpunk()`, etc. | Various |

---

## 14. Data Models Reference

### Core Lesson Models

```swift
struct GenerateSentenceData {
    let target_language: String
    let user_language: String
    let place_name: String
    let micro_situation: String?
    let lesson_id: String
    var groups: [LessonGroup]?
    var bricks: BricksData?
    var patterns: [PatternData]?
}

struct LessonGroup {
    let group_id: String
    var patterns: [PatternData]?
    var bricks: BricksData?
}

struct PatternData {
    let id: String
    let target: String      // Target language sentence ("¿Cómo estás?")
    let meaning: String     // Native language meaning ("How are you?")
    let phonetic: String?   // Pronunciation guide
    var vector: [Double]?   // Semantic embedding (set during enrichment)
    var mastery: Int        // 0-100
}

struct BricksData {
    var constants: [BrickItem]?   // Fixed-form words (articles, prepositions)
    var variables: [BrickItem]?   // Swappable content words
    var structural: [BrickItem]?  // Grammar connectors
}

struct BrickItem {
    let id: String
    let word: String
    let meaning: String
    let phonetic: String?
    let type: String       // "constant" | "variable" | "structural"
    var vector: [Double]?  // Set during enrichment pipeline
}
```

### Discovery Models

```swift
struct PlaceRecommendation {
    let place_id: String       // e.g. "cafe", "airport"
    let grounding: String      // Micro-situation description
    var patterns: [RecommendationPattern]?
}

struct RecommendationPattern {
    let target: String
    let meaning: String
    let phonetic: String?
    var bricks: RecommendationBricks?
}
```

### Language Models

```swift
struct LanguagePair {
    let native_language: String   // e.g. "en"
    let target_language: String   // e.g. "es"
    let is_default: Bool
    var practice_dates: [String]  // ["2026-03-01", "2026-03-04"]
}
```

---

## 15. MainTabView — Navigation Shell

**File:** `MainTabView.swift` (258 lines)  
**Pattern:** Custom tab bar — no SwiftUI `TabView`. Hand-built `HStack` so full design control.

### Tab Architecture

```
MainTabView
 ├─ ZStack
 │    ├─ VStack
 │    │    ├─ [content area] — switch selectedTab
 │    │    │    ├─ .learn    → LearnTabView(appState, learnTabState, $selectedTab)
 │    │    │    ├─ .progress → StatsTabView(appState, statsTabState, $selectedTab)
 │    │    │    └─ .settings → SettingsView(appState, $selectedTab)
 │    │    └─ [customTabBar] — hidden when: isAnalyzingImage OR isLessonActive
 │    │
 │    └─ AppLaunchLoadingView overlay (.zIndex 10) — shown while isInitializing == true
 │                                                   .transition(.opacity)
```

### Tab Colors & Icons

| Tab | SF Symbol | Active Color | Hex |
|-----|-----------|-------------|-----|
| Learn | `book.fill` | Purple | `(0.6, 0.4, 1.0)` |
| Progress | `chart.bar.fill` | Orange | `(1.0, 0.6, 0.4)` |
| Settings | `gearshape.fill` | Gray | `(0.7, 0.7, 0.7)` |

**Selected tab indicator:** Custom `SelectedTabBorder` shape (top + right + bottom edges only, no left) drawn with a white→transparent linear gradient stroke, `lineWidth: 1`.

### Initialization & Safety Timeout

```
MainTabView.onAppear
    │
    ├─ asyncAfter(2.5s): appState.minAnimationIntervalCompleted = true
    │       (guarantees logo animation runs for at least 2.5 seconds)
    │
    └─ asyncAfter(7.0s): SAFETY TIMEOUT
            if isInitializing == true → force withAnimation { isInitializing = false }
            (prevents "stuck loading" bug if API hangs)

onChange(minAnimationIntervalCompleted):
    → performInitialRouting()
    → selectedTab = .learn
    → withAnimation(.easeOut(0.1)) { isInitializing = false }
```

**Why 2.5s minimum:** The animation sequence completes around T+1.9s. The 2.5s gives a clean buffer so the overlay never dismisses before animations are done, even on slow devices.

### Deep Link Routing

```
AppStateManager.pendingDeepLinkPlace set by NotificationManager
        │
        ▼
MainTabView.onChange(pendingDeepLinkPlace):
    selectedTab = .learn
    learnTabState.handleDeepLink(placeName:, hour:)
    → discover(explicitText: "I am at \(placeName)")
    appState.pendingDeepLinkPlace = nil  (clear to prevent re-trigger)
```

### Tab Switch Animation

```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.48)) {
    selectedTab = tab
}
```
Response 0.4 = medium snappy. DampingFraction 0.48 = slight overshoot bounce for tactility.

### Diagnostic Borders System

All views wrap with `.diagnosticBorder(color, width:)` modifier (from `ViewModifiers.swift`). Controlled by `AppStateManager.showDiagnosticBorders`. In production = invisible. Flip `showDiagnosticBorders = true` in Settings → all view frames light up for layout debugging.

---

## 16. Stats Tab — Full Detail

**Files:** `StatsTabState.swift` (253 lines), `StatsTabView.swift`

### State Model

```swift
class StatsTabState: ObservableObject {
    @Published var practiceDatesSet: Set<Date>   // parsed from practice_dates strings
    @Published var studiedHours: Set<Int>         // V3: unused, kept for future
    @Published var sortedMonths: [Date]           // all months with practice, desc order
    @Published var pullRefreshState: CyberRefreshState
    @Published var scrollOffset: CGFloat
    @Published var isRefreshFinished: Bool
    @Published var chronotype: String             // "NIGHT OWL" (default, V3 static)
}
```

### Reactive Binding Setup

```swift
appState.$userLanguagePairs
    .sink { [weak self] _ in self?.refreshData() }
    .store(in: &cancellables)
```
`StatsTabState` auto-refreshes ANY time `userLanguagePairs` changes (e.g. after a language add or practice recording).

### Streak Algorithm (Exact Code)

**Current Streak:**
```
1. Parse practice_dates ["2026-03-01", "2026-03-04"] → [Date]
2. De-duplicate (Set), sort descending (newest first)
3. Check if latestDate is today OR yesterday
   → if neither → streak = 0 (broken)
4. Count backward: for each date, check if previous date == expectedPrevDay
   → break on first non-consecutive date
5. Return count
```

**Longest Streak:**
```
1. Parse + de-duplicate + sort ascending
2. Iterate pairs: if nextDate == currentDate + 1 day → currentStreak++
   else → maxStreak = max(maxStreak, currentStreak); currentStreak = 1
3. Return max(maxStreak, currentStreak)
```

### Pull-to-Refresh State Machine

```
CyberRefreshState:
    .idle
    .pulling(progress: CGFloat)   // 0.0 → 1.0 as user pulls (trigger at 110pt)
    .loading                      // API call in progress
    .finishing                    // Animate back to idle
```

**Trigger logic:**
```
scrollOffset > 110pts → .loading → UIImpactFeedbackGenerator(.heavy)
    → Task.sleep(500ms) → forceRefreshLanguages() → .finishing
    → when scrollOffset returns < 10pts → back to .idle
```

### Month Calendar Generation

```swift
// Always includes current month even with no practice
monthSet.insert(currentMonth)

// For each practice_date string → parse → extract year/month start
sortedMonths = monthSet.sorted(by: { $0 > $1 })  // newest first (scrollable)
```

---

## 17. Full Codable Models — Every Field

### GenerateSentenceResponse (API top-level)

```swift
struct GenerateSentenceResponse: Codable {
    let success: Bool
    var data: GenerateSentenceData?
    let error: String?
}
```

**Dual-path decoder** — handles both `{ data: {...} }` (direct) and `{ data: { data: {...} } }` (nested) API shapes:
```swift
init(from decoder: Decoder) {
    // Try DIRECT first: response.data → GenerateSentenceData
    if let directData = try? container.decodeIfPresent(GenerateSentenceData.self, forKey: .data) {
        self.data = directData
    } else {
        // Try NESTED: response.data.data → GenerateSentenceData
        if let outerData = try? container.decodeIfPresent(OuterDataWrapper.self, forKey: .data) {
            self.data = outerData.data
        }
    }
}
```

### GenerateSentenceData — All Fields

```swift
struct GenerateSentenceData: Codable {
    let target_language: String?      // "es"
    let user_language: String?        // "en"
    let place_name: String?           // "cafe"
    let micro_situation: String?      // "ordering coffee in a busy morning cafe"
    let conversation_context: String? // optional background context
    let lesson_id: String?            // "v3-<UUID>" or API-generated
    let moment_label: String?         // display label for the lesson
    let sentence: String?             // first pattern target (summary/preview)
    let native_sentence: String?      // first pattern native translation
    var groups: [LessonGroup]?        // NEW LEGO structure (primary)
    var bricks: BricksData?           // legacy top-level bricks
    var patterns: [PatternData]?      // legacy top-level patterns
}
```

### LessonGroup

```swift
struct LessonGroup: Codable, Identifiable {
    let group_id: String        // "v3-cafe-0", "v3-cafe-1"...
    var id: String { group_id }
    var patterns: [PatternData]?
    var bricks: BricksData?
}
```

### PatternData — All Fields

```swift
struct PatternData: Codable, Identifiable {
    let id: String          // "v3-cafe-0" or API pattern ID
    let target: String      // "¿Puedo tener un café, por favor?"
    let meaning: String     // "Can I have a coffee, please?"
    let phonetic: String?   // "¿Pweh-doh TEH-nehr oon kah-FEH, por fah-VOR?"
    var vector: [Double]?   // 512-dim (contextual) or varies (static) — NOT in JSON
    var mastery: Int?       // 0-100, NOT from API — computed locally
}
```

### BrickItem — All Fields

```swift
struct BrickItem: Codable, Identifiable {
    let id: String?         // may be nil — use safeID
    let word: String        // "café"
    let meaning: String     // "coffee"
    let phonetic: String?   // "kah-FEH"
    let type: String?       // "constant" | "variable" | "structural"
    var safeID: String { id ?? word }   // computed, not in JSON
    var vector: [Double]?   // NOT in JSON, filled by EmbeddingService
}
```

### BricksData

```swift
struct BricksData: Codable {
    var constants: [BrickItem]?    // fixed: articles, pronouns ("el", "la", "yo")
    var variables: [BrickItem]?    // swappable: nouns, verbs ("café", "agua")
    var structural: [BrickItem]?   // grammar glue: prepositions, conjunctions ("por", "pero")
}
```

### DrillItem (what the Orchestrator passes to drill views)

```swift
struct DrillItem: Codable {
    let target: String    // target language string to practice
    let meaning: String   // native language meaning
    let phonetic: String? // pronunciation guide
}
```

### GenerateSentenceRequest (sent to API)

```swift
struct GenerateSentenceRequest: Codable {
    let moment_id: String         // ID of the moment being practiced
    let user_language: String     // "en"
    let target_language: String   // "es"
    let latitude: Double          // user GPS
    let longitude: Double
    let time: String              // ISO timestamp
}
```

### SentenceItem (legacy, kept for safety)

```swift
struct SentenceItem: Codable {
    let sentence: String
    let translation: String
    let difficulty: String?   // "beginner" | "intermediate" | "advanced"
    let keywords: [String]?
}
```

---

## 18. BaseAPIManager & Error Handling

**File:** `Services/BaseAPIManager.swift` (10,270 bytes)

### Request Flow

```
makeRequest(endpoint:, method:, body:, headers:)
    │
    ├─ Build URLRequest
    │     ├─ URL = APIConfig.baseURL + endpoint
    │     ├─ HTTPMethod = "GET" | "POST" | "PUT" | "DELETE"
    │     ├─ "Content-Type": "application/json"
    │     └─ "Authorization": "Bearer \(authToken)" (if token exists)
    │
    ├─ URLSession.shared.dataTask
    │
    ├─ HTTP Status Checks:
    │     ├─ 200-299 → decode response
    │     ├─ 401     → post "SessionExpired" notification
    │     │             → ContentView catches → logoutLocalOnly()
    │     ├─ 0 (no connection) → appState.isOffline = true
    │     └─ other   → ErrorHandler.parse(data:, statusCode:) → .failure(error)
    │
    └─ Completion(.success(decoded)) | .failure(error)
```

### ErrorHandler

```swift
// Tries to decode standard API error format:
struct APIError: Codable {
    let error: String?
    let message: String?
    let detail: String?
}
// Falls back to HTTP status code description if JSON unparseable
```

---

## 19. Notification & Deep Link System

**File:** `Notifications/NotificationManager.swift`

### How Notifications Work

```
NotificationManager.startMonitoring()
    │
    ├─ Observes location changes (via LocationManager)
    ├─ Checks: should we fire a learning reminder?
    │     Conditions:
    │     - Location changed to new place type
    │     - Moment not already notified (notifiedMomentIDs check)
    │     - lastNotificationFireDate > cooldown threshold
    │
    └─ UNUserNotificationCenter.add(request)
           │
           [User taps notification]
           │
           ▼
    AppDelegate (or scene delegate) receives userInfo
           │
           ▼
    AppStateManager.pendingDeepLinkPlace = placeName
    AppStateManager.pendingDeepLinkHour = hour
           │
           ▼
    MainTabView.onChange(pendingDeepLinkPlace)
           → selectedTab = .learn
           → learnTabState.handleDeepLink(placeName:, hour:)
           → discover(explicitText: "I am at \(placeName)")
```

### Notification State in AppStateManager

```swift
var lastNotificationFireDate: Date?   // persisted — cooldown check
var notifiedMomentIDs: Set<String>    // persisted — prevents duplicate notifications
var lastOpenedNotificationDate: Date? // persisted — engagement tracking
```

---

## 20. UserIntentContext — Daily Brain Profile

**Endpoint:** `POST /api/context/user-intent`  
**Called by:** `AppStateManager.loadInitialData()` → `UserIntentContextLogic.shared.discoverDailyIntent()`

### Purpose

Updates the server with the user's inferred daily intent (study goals, schedule, place patterns). The server uses this to personalize recommendation quality over time.

### Data Flow

```
AppStateManager.loadInitialData()
        │
        ├─ Phase 1: UserIntentContextLogic.discoverDailyIntent()
        │       POST /api/context/user-intent
        │       Body: { location, time_of_day, user_language, target_language }
        │       Response: intentTimeline ([String: TimeSpanSnapshot])
        │       → stored ephemeral in AppStateManager.intentTimeline
        │
        └─ group.notify → isRefreshingContext = false
```

**`intentTimeline` is ephemeral** — NOT persisted across app restarts on purpose. Each app launch fetches a fresh snapshot from the server so the user always gets today's intent pattern.

---

## 21. CyberComponents — Full Component Inventory

**File:** `Shared/CyberComponents.swift` (729 lines — second largest file)

### Component List

| Struct | Purpose | Used By |
|--------|---------|---------|
| `CyberColors` | Static color palette (neonPink, neonCyan, neonYellow, darkSurface, textGray, success, error, neonBlue, neonGreen) | All lesson views |
| `CyberOption` | MCQ answer button — chamfered shape, index number, checkmark animation | `MCQSelectionGrid` |
| `LessonPromptHeader` | The white-background instruction card at top of every drill (instruction label + prompt text + phonetic + hint + pattern progress discs) | All drill views |
| `CyberProceedButton` | Bottom "PROCEED" button — text label left, arrow button right (uses `LocianButton`) | All drill views |
| `GridPattern` | Background grid lines shape (20pt step) | `CyberGridBackground` |
| `TechFrameBorder` | L-shaped corner brackets at 4 corners | Selection states |
| `CyberGridBackground` | Full-screen grid overlay (10% white opacity) | Lesson backgrounds |
| `MCQSelectionGrid` | Vertical stack of 4 `CyberOption` items with correct/wrong state management | PatternMCQView |
| `TypingInputArea` | Full-width text field with cyan left-border indicator | PatternTypingView |
| `TypingCorrectionView` | Shows correct answer in neon green after wrong typing attempt | PatternTypingView |
| `InlineTypingArea` | Underline-style input field (width = target word width) | BrickTypingView |
| `TypingTextView` | Typewriter-effect text (character-by-character reveal at 0.05s/char) | `ManifestDataRow` |
| `ManifestDataRow` | Terminal-style `[LABEL] VALUE` display row | Lesson debug panels |

### LessonPromptHeader Initializers

Two initializers — the header is smart about what to show:

**Static mode** (for MCQ/voice drills):
```swift
LessonPromptHeader(
    instruction: "TRANSLATE THIS",
    prompt: "¿Cómo estás?",
    targetLanguage: "Spanish",
    meaning: "How are you?",
    phonetic: "¿KOH-moh eh-STAHS?",
    patternIds: [...],
    currentPatternId: "v3-cafe-0",
    engine: lessonEngine
)
```

**Expandable hint mode** (for typing drills):
```swift
LessonPromptHeader(
    instruction: "TYPE IN SPANISH",
    prompt: "How are you?",
    targetLanguage: nil,
    hintText: "Tap for hint",
    meaningText: "¿Cómo estás?",
    contextSentence: "Full context sentence...",
    isHintExpanded: $isExpanded
)
```

### CyberOption State Colors

| State | Background | Border |
|-------|-----------|--------|
| Unselected | `black.opacity(0.4)` | `white.opacity(0.1)` |
| Selected | `black.opacity(0.4)` | `neonPink` |
| Correct | `Color.green` | none (`.clear`) |
| Wrong | `Color.red` | none |
| Correct hint (other option) | unchanged | `Color.green` 3pt stroke |

---

## 22. Theme System

**File:** `Shared/ThemeColors.swift`

### Available Themes

```swift
static func getColor(for theme: String) -> Color {
    switch theme {
    case "Neon Green":  Color(red: 0.0, green: 1.0, blue: 0.2)
    case "Cyber Blue":  Color(red: 0.0, green: 0.6, blue: 1.0)
    case "Hot Pink":    ThemeColors.secondaryAccent
    case "Solar Gold":  Color(red: 1.0, green: 0.8, blue: 0.0)
    default:            Color(red: 0.0, green: 1.0, blue: 0.2)  // Neon Green
    }
}

static let secondaryAccent = Color(red: 1.0, green: 0.18, blue: 0.45) // System Pink
```

**`selectedTheme`** stored in UserDefaults → `AppStateManager.selectedColor` computed property → propagated everywhere via `appState.selectedColor`.

**`secondaryAccent`** (hot pink `#FF2E73`) is used for:
- Asterisk in the logo
- `ADAPTIVE LANGUAGE ENGINE` subtitle text
- Neon pink MCQ borders
- `LessonPromptHeader` left-side accent line
- Tab bar selected icon + text color

---

## 23. Voice System — Brick-Level Detail

### Where TTS Is Called in the Lesson Engine

| Location | What is spoken | Segments |
|----------|---------------|---------|
| `VocabIntroView.onAppear` | Full pattern target + meaning | 2 segments: target lang + native lang |
| `PatternMCQView` — correct answer | Correct option text | 1 segment: target lang |
| `BrickVoiceView` — prompt | Individual brick word | 1 segment: target lang |
| `BrickVoiceView` — after answer | Full pattern sentence | 2 segments |
| `GhostModeView` — intro | Native meaning only (no target) | 1 segment: native lang |
| `LessonCompleteView.onAppear` | Congratulatory phrase | 1 segment |

### Speech Recognition (BrickVoice drills)

```
SharedMicButton (tap to record)
    │
    ├─ Activates AVAudioSession (.recording mode)
    ├─ SFSpeechRecognizer(locale: Locale(identifier: targetLanguage))
    │     .recognitionRequest = SFSpeechAudioBufferRecognitionRequest
    │     (streaming, real-time transcription while speaking)
    │
    └─ On result:
           recognized text → AnswerValidator.validate(userAnswer:, target:, language:)
           → CORRECT | WRONG
           → AudioManager.configureSession(.playback) [switch back]
```

---

*This document covers the full V3.45 codebase as of 2026-03-04.*


| Screen | Animation Type | Easing | Duration |
|--------|--------------|--------|---------|
| Loading: Comma logo | `scaleEffect` + `opacity` | `.easeOut` | 0.7s |
| Loading: Asterisk | `scaleEffect` + `opacity` | `.easeOut` delay(0.2) | 0.7s |
| Loading: Letters | `scaleEffect` + `opacity` per-letter | `.easeOut` asyncAfter | 0.4s each |
| Loading: Subtitle | `opacity` | `.easeOut` asyncAfter(1.5s) | 0.4s |
| ContentView transitions | `.opacity` crossfade | `.easeInOut` | 0.5s |
| Button press | `scaleEffect` (0.95) → restore | `.easeOut` | 0.1s |
| Brick answer feedback | Background color change | `.spring(response: 0.3)` | — |
| Ghost mode toggle | Expand/collapse | `.spring(response: 0.35, dampingFraction: 0.75)` | — |
| Haptic: button press | `UIImpactFeedbackGenerator(.medium)` | — | — |
| Haptic: correct | `UINotificationFeedbackGenerator(.success)` | — | — |
| Haptic: wrong | `UINotificationFeedbackGenerator(.error)` | — | — |

---

## 24. ContentView — Root Navigation Tree

**File:** `ContentView.swift` (120 lines)  
**Pattern:** `Group { if/else }` — SwiftUI picks the branch, no animation between branches by default (intentionally — hard cut on auth changes is correct UX).

### Full Navigation Decision Tree

```
ContentView
    │
    ├─ [1] hasCompletedOnboarding == false
    │       └─ OnboardingContainerView(appState)
    │               → user goes through intro slides
    │               → appState.completeOnboarding() sets flag + persists
    │
    ├─ [2] isLoadingSession == true
    │       └─ LoadingView(appState)
    │               ├─ isOffline == true  → wifi.slash icon + "No Internet" + Retry + Logout
    │               └─ isOffline == false → ProgressView (1.5× scale, white tint) + "Loading..."
    │
    ├─ [3] isLoggedIn == true
    │       └─ MainTabView(appState)
    │
    └─ [4] else (not logged in, session check done)
            └─ LoginView(appState)

.onAppear:
    if hasCompletedOnboarding → appState.checkUserSession()

.onReceive("SessionExpired" notification):
    → appState.logoutLocalOnly()
    → isLoggedIn = false → back to [4] LoginView
```

### Full-Screen Modals (from ContentView)

| Modal | Condition | Dismissible? |
|-------|-----------|-------------|
| `FirstLaunchLanguageSelectionModal` | `appState.showFirstLaunchLanguageModal` | Yes (always) |
| `NativeLanguageSelectionModal` | `appState.shouldShowNativeLanguageModal` | No, if `nativeLanguage.isEmpty` |
| `TargetLanguageSelectionModal` | `appState.shouldShowTargetLanguageModal` | No, if `!hasValidLanguagePair()` |

**Why `interactiveDismissDisabled`:** If the user hasn't set their native / target language, dismissing without completing would leave the app in a broken state — no valid language pair to create lessons for.

### LoadingView — Offline State Detail

```swift
if appState.isOffline {
    Image(systemName: "wifi.slash")   // 50pt icon, white
    Text(localizationManager.string(.noInternetConnection))
    Button("Retry") { appState.checkUserSession() }
        .buttonPressAnimation()        // centralized spring animation
    Button("Logout") { appState.logoutLocalOnly() }
        .underline()                   // secondary destructive action
} else {
    ProgressView().scaleEffect(1.5)   // scale up circular indicator
    Text(localizationManager.string(.loading))
}
```

---

## 25. LessonEngine — The Data Store & Triangle Architecture

**File:** `Scene/LessonEngine/Core/Engine/LessonEngine.swift` (256 lines)

### The Triangle (Three Interdependent Objects)

```
         LessonEngine (Data Store / ObservableObject)
        /              \
       /                \
LessonFlow          LessonOrchestrator
(Pattern Picker)    (Stage State Machine)
       \                /
        \              /
         back-references via weak pointers
```

**Setup (created once per lesson):**
```swift
func initialize(with data: GenerateSentenceData) {
    let newFlow = LessonFlow()
    let newOrch = LessonOrchestrator()
    newFlow.orchestrator = newOrch     // Flow → Orch (strong)
    newOrch.engine = self              // Orch → Engine (weak)
    self.flow = newFlow
    self.orchestrator = newOrch        // Engine → both (strong)
}
```

`LessonOrchestrator.objectWillChange` is piped into `LessonEngine.objectWillChange` via Combine, so any orchestrator state change re-renders all lesson views through the single engine reference.

### Published State

| Property | Type | Purpose |
|----------|------|---------|
| `componentMastery` | `[String: Double]` | Score per brick/pattern ID (0.0–1.0) |
| `recentPatternHistory` | `[String]` | Last 3 pattern IDs (prevents immediate repetition) |
| `isSessionComplete` | `Bool` | Triggers `LessonCompleteView` |
| `patternIntroMistakes` | `[DrillState]` | Bricks/patterns user got wrong this round |
| `currentGroupIndex` | `Int` | Active LessonGroup |
| `visitedPatternIds` | `Set<String>` | Tracking which patterns have been seen |

### Pattern History Buffer

Only the **last 3 pattern IDs** are kept:
```swift
recentPatternHistory.append(id)
if recentPatternHistory.count > 3 { recentPatternHistory.removeFirst() }
```
`LessonFlow.pickNextPattern` receives this history → avoids picking the same pattern twice in a row.

### Group-Aware Brick Lookup

Every pattern belongs to exactly one `LessonGroup`. When the lesson engine needs bricks for a pattern, it does a group lookup instead of using all bricks:

```swift
func getBricks(for patternId: String) -> BricksData? {
    guard let group = groups.first(where: { group in
        group.patterns?.contains(where: { $0.id == patternId }) ?? false
    }) else {
        return activeGroupBricks  // Fallback (safe)
    }
    return group.bricks
}
```

This is critical — without this, a pattern from Group 0 ("café") would get mixed with bricks from Group 1 ("airport"), producing wrong MCQ options.

### allBricks — Deduplicated Cross-Group Pool

Used for MCQ distractor generation only (needs diverse pool):
```swift
var allBricks: BricksData? {
    var seenIDs: Set<String> = []
    // iterate all groups, skip any brick.safeID already seen
    // returns combined constants/variables/structural with no duplicates
}
```

### Mastery Update — Global Brick Sync

When you answer "café" correctly in Group 0, the same "café" brick in Group 1 also advances:
```swift
func updateMastery(id: String, delta: Double) {
    // 1. Update target ID directly
    componentMastery[id] = (current + delta).clamped(to: 0...1)
    
    // 2. GLOBAL BRICK SYNC — find all other bricks with same word text
    let flatList = allBricks.constants + variables + structural
    let sourceWord = flatList.first { $0.safeID == id }?.word.lowercased()
    let duplicates = flatList.filter { $0.word.lowercased() == sourceWord && $0.safeID != id }
    for dup in duplicates {
        componentMastery[dup.safeID] = newValue
    }
    
    // 3. Force SwiftUI re-render on main thread
    DispatchQueue.main.async { self.objectWillChange.send() }
}
```

### Session Completion

```swift
func patternCompleted(id: String) {
    recentPatternHistory.append(id)
    patternIntroMistakes = []  // clear mistake pool ("Ghost Court cleared")
    flow?.pickNextPattern(history:, mastery:, candidates: rawPatterns)
    // When flow determines no more candidates → finishSession() → isSessionComplete = true
}
```

### `getBlendedMastery(for:)` — Used by PatternModeSelector

Defined in Engine extensions. Returns a 0.0–1.0 blended mastery score for a given drill ID, combining the raw `componentMastery[id]` score with any decay or averaging logic from the flow algorithm.

---

## 26. PatternModeSelector — Mastery-Driven Drill Router

**File:** `Scene/LessonEngine/PatternDrills/PatternModeSelector.swift` (89 lines)

### Mastery → Drill Mode Thresholds

```
componentMastery score for patternId:

  0.00 – 0.24  →  .mcq           (Multiple Choice — lowest cognitive load)
  0.25 – 0.39  →  .sentenceBuilder  (Tap-to-arrange word tiles)
  0.40 – 0.59  →  .typing         (Free text keyboard input)
  0.60 – 0.84  →  .speaking       (Voice recording + STT)
  0.85 – 1.00  →  .mastered       (DrillMasteryVictoryView — skip immediately)
```

**Ghost Mode resolution** uses the same thresholds but resolves from `drill.id.hasSuffix("-ghostManager")` detection.

### View Transition Animation

```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing),  // New drill slides in from right
    removal:   .opacity                 // Old drill fades out
))
```

### Forced Mode Override

`forcedMode` parameter lets the orchestrator bypass mastery resolution entirely:
```swift
let mode = forcedMode ?? PatternModeSelector.resolveMode(for: drill, engine: engine)
```
Used when the `LessonOrchestrator` wants to force `.vocabIntro` stage regardless of mastery.

---

## 27. Validation System — 5-Gate Logic in Full Detail

**Location:** `Scene/LessonEngine/Validation/`

### ValidationResult Enum

```swift
enum ValidationResult {
    case correct        // Exact OR near-perfect → GREEN feedback, high mastery delta
    case meaningCorrect // Semantic/typo match   → ORANGE feedback, partial mastery delta
    case wrong          // All gates failed       → RED feedback, negative mastery delta
}
```

### NeuralConfig Constants

```swift
struct NeuralConfig {
    static let semanticStrictThreshold = 0.10   // Gate 2: similarity > (1.0 - 0.10) = 0.90
    static let hardStructureOverlap    = 0.70   // Structural word overlap check
    static let typoTolerance           = 0.25   // Gate 4: normalizedLevenshtein < 0.25
    static let brickSemanticMatch      = 0.20   // Brick-level similarity threshold
    static let brickDebug              = 0.40   // Debug logging threshold
}
```

### TypingValidator — 5 Gate Logic (Exact Code Path)

```
cleanInput  = input.lowercased().trimmed()
cleanTarget = target.lowercased().trimmed()

GATE 1 — EXACT MATCH
    cleanInput == cleanTarget → .correct

GATE 2 — NEAR-PERFECT SEMANTIC (similarity > 0.90)
    similarity = EmbeddingService.compare(cleanInput, cleanTarget, langCode)
    if similarity > (1.0 - 0.10)  → .correct

GATE 3 — MASTERY-ADAPTIVE SEMANTIC
    mastery = engine.getBlendedMastery(for: drill.id)   // 0.0 – 1.0
    tolerance = 0.25 * mastery          // Low mastery = strict, high mastery = lenient
    threshold = 1.0 - tolerance
    
    Examples:
      mastery=0.0 → threshold=1.0  (must be near-perfect)
      mastery=0.5 → threshold=0.875 (some leniency)
      mastery=1.0 → threshold=0.75  (synonyms accepted)
    
    if similarity >= threshold → .meaningCorrect

GATE 4 — TYPO RESCUE (Levenshtein)
    distance = levenshteinDistance(cleanInput, cleanTarget)
    normalized = distance / max(len(input), len(target))
    if normalized <= 0.25 → .meaningCorrect
    
    Examples:
      "hola" vs "hla"   → distance=1, len=4 → 0.25 → passes
      "gracias" vs "grc" → distance=4, len=7 → 0.57 → fails

GATE 5 — FAIL
    return .wrong
```

### Levenshtein Distance Implementation

Full dynamic programming matrix in `ValidationUtils`:
```
matrix[i][j] = matrix[i-1][j-1]              if s1[i] == s2[j]
             = min(matrix[i-1][j] + 1,        (delete)
                   matrix[i][j-1] + 1,        (insert)
                   matrix[i-1][j-1] + 1)      (substitute)
```
O(m×n) time and space where m,n = string lengths.

### Validator Factory (ValidationFactory.swift)

```swift
// Returns the right validator for each DrillMode
switch mode {
case .typing, .brickTyping:  return TypingValidator()
case .speaking, .brickVoice: return VoiceValidator()
case .mcq, .brickMCQ:        return MCQValidator()
case .sentenceBuilder:       return BuilderValidator()
default:                     return TypingValidator()
}
```

### DrillValidator Protocol

All validators conform to a single protocol for clean polymorphism:
```swift
protocol DrillValidator {
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult
}

struct ValidationContext {
    let state: DrillState    // Carries drill ID for mastery lookup
    let locale: Locale       // Language code for embedding service
    let engine: LessonEngine // For getBlendedMastery()
    let neuralEngine: NeuralValidator?
}
```

### MCQValidator Logic

```swift
// MCQ is simple: index-based exact match
// User selected option at index `selectedIndex`
// Correct = selectedIndex matches the option whose text == target
func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
    return input.lowercased().trimmed() == target.lowercased().trimmed()
        ? .correct : .wrong
}
// No typo tolerance for MCQ — it's a tap, not typed text
```

### VoiceValidator Logic

```swift
// 1. Get STT-recognized text
// 2. Run through TypingValidator logic (same 5-gate system)
// Voice inherently has more errors, so same typo tolerance applies
```

### BuilderValidator Logic

```swift
// User dragged word tiles into order → joined as space-separated string
// Exact match only (word order matters in sentence construction)
```

---

## 28. DoubleArrowButton — Interactive Gesture System

**File:** `Shared/DoubleArrowButton.swift` (223 lines)  
**Used in:** `LearnTabView` as the "proceed to lesson" button

### How the "Slide" Animation Works

The button has **two chevron arrows** side by side. Only the **first arrow moves** — it slides towards the second:

```
At rest:     [›]  [›]      (side by side, spacing: -4pt)
On press:     [›][›]       (first arrow moves 4pt towards second)
```

The second arrow slightly **scales up** (1.1×) when pressed to create a "target pull" effect:
```swift
// First arrow — moves
.offset(x: direction == .right ? moveDistance : 0, ...)
// Second arrow — pulsates in scale
.scaleEffect(activeIsPressed ? 1.1 : 1.0)
```
`moveDistance = activeIsPressed ? 4 : 0`

### Gesture Mechanics

Uses `DragGesture(minimumDistance: 0)` — fires immediately even without movement:

```
onChanged:
    distance = sqrt(tx² + ty²)     (euclidean drag distance)
    
    if distance > 30 → CANCEL (user is swiping, not tapping)
        withAnimation(.spring(response:0.3, dampingFraction:0.6)):
            isPressed = false
            HapticFeedback.buttonRelease()
        dragCancelled = true
    
    if !isPressed:
        withAnimation(.easeOut(0.05)): isPressed = true
        HapticFeedback.buttonPress()

onEnded:
    if isPressed (not cancelled):
        HapticFeedback.buttonRelease()
        action()
        withAnimation(.easeOut(0.1)): isPressed = false
    dragCancelled = false  (reset for next gesture)
```

**Why DragGesture instead of Button:** SwiftUI's `Button` has a built-in ~100ms tap delay for disambiguation. `DragGesture(minimumDistance: 0)` gives instant response — `isPressed = true` fires the render frame the user touches the screen.

### Extended Touch Area

The visible arrows are small (~24pt). But the hit area is 3–4× larger:
```swift
// Extended hit target (invisible)
Color.white.opacity(0.001)      // 0.001 = tappable but invisible
    .frame(width: size * 4, height: size * 3)   // vertical
    .frame(width: size * 3, height: size * 4)   // horizontal
```

### Environment Key — `isActionPressed`

`IsActionPressedKey` lets parent views inject "pressed" state down the tree:
```swift
struct IsActionPressedKey: EnvironmentKey { static let defaultValue = false }

// Parent wraps button in ActionPressStyle:
Button { } label: { DoubleArrowButton(...) }
    .buttonStyle(ActionPressStyle())

// ActionPressStyle injects via environment:
.environment(\.isActionPressed, configuration.isPressed)

// DoubleArrowButton reads:
var activeIsPressed: Bool { isPressed || isActionPressed }
```
This lets BOTH the internal DragGesture AND an external ButtonStyle control the pressed visual.

### Dual Color Initializer

```swift
// Single color (both arrows same)
DoubleArrowButton(direction: .right, color: .white, action: { })

// Dual color (arrow1 = first/movable, arrow2 = second/fixed)
DoubleArrowButton(direction: .right, arrow1: .white, arrow2: .pink, action: { })
```

### Direction System

```
.right → [Movable ›] [Fixed ›]     HStack — movable is first
.left  → [Fixed ‹] [Movable ‹]     HStack — fixed is first
.down  → [Movable ˅]               VStack
         [Fixed   ˅]
.up    → [Fixed   ˄]               VStack
         [Movable ˄]
```

---

## 29. HapticFeedback System

**File:** `Shared/HapticFeedback.swift`

```swift
struct HapticFeedback {
    static func buttonPress() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func buttonRelease() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func correct() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func wrong() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        // Used by Stats pull-to-refresh trigger at 110pt
    }
}
```

### Where Each Haptic Fires

| Haptic | When |
|--------|------|
| `.buttonPress()` | DoubleArrowButton touch down, ActionPressStyle press |
| `.buttonRelease()` | DoubleArrowButton release (confirm/cancel) |
| `.correct()` | Validation returns `.correct` — all drill types |
| `.wrong()` | Validation returns `.wrong` — all drill types |
| `.heavy()` | Pull-to-refresh trigger threshold crossed (Stats tab) |

---

## 30. Onboarding Flow

**File:** `Onboarding/` (7 files)  
**Entry Point:** `OnboardingContainerView`  
**Trigger:** `AppStateManager.hasCompletedOnboarding == false`

### Onboarding Sequence

```
OnboardingContainerView
    │
    ├─ Slide 1: Welcome / Brand intro
    ├─ Slide 2: Location permission request (PermissionsService.requestLocation)
    ├─ Slide 3: Microphone permission request (PermissionsService.requestMicrophone)
    ├─ Slide 4: Notification permission request (PermissionsService.requestNotifications)
    └─ Final: appState.completeOnboarding()
                → hasCompletedOnboarding = true (persisted)
                → appState.showFirstLaunchLanguageModal = true
                        → FirstLaunchLanguageSelectionModal (pick app language)
                                → appState.shouldShowNativeLanguageModal = true
                                        → NativeLanguageSelectionModal
                                                → appState.shouldShowTargetLanguageModal = true
                                                        → TargetLanguageSelectionModal
                                                                → LoginView / MainTabView
```

### Permissions Requested

| Permission | Why | API |
|-----------|-----|-----|
| Location | Context-aware recommendations | `CLLocationManager.requestWhenInUseAuthorization()` |
| Microphone | Voice drills (BrickVoice, GhostMode speaking) | `AVAudioSession.requestRecordPermission()` |
| Notifications | Learning reminders when entering relevant places | `UNUserNotificationCenter.requestAuthorization()` |

---

## 31. LessonFlow — Pattern Picker Algorithm

**File:** `Scene/LessonEngine/FlowAlgorithm/LessonEngine+Flow.swift`

### pickNextPattern Logic

```swift
func pickNextPattern(history: [String], mastery: [String: Double], candidates: [PatternData]) {

    // 1. EXCLUDE recently seen patterns (last 3 history IDs)
    let available = candidates.filter { !history.contains($0.id) }
    
    // 2. If all excluded (small lesson), allow all
    let pool = available.isEmpty ? candidates : available
    
    // 3. PRIORITY SORT: Lowest mastery first
    //    (user should practice what they're worst at)
    let sorted = pool.sorted {
        let m1 = mastery[$0.id] ?? 0.0
        let m2 = mastery[$1.id] ?? 0.0
        return m1 < m2
    }
    
    // 4. Pick TOP (lowest mastery)
    guard let next = sorted.first else {
        orchestrator?.engine?.finishSession()
        return
    }
    
    // 5. CHECK SESSION COMPLETION
    // All patterns mastered (mastery >= 1.0) → finish
    let allMastered = candidates.allSatisfy { (mastery[$0.id] ?? 0.0) >= 1.0 }
    if allMastered {
        orchestrator?.engine?.finishSession()
        return
    }
    
    // 6. KICKSTART Orchestrator for this pattern
    orchestrator?.startPattern(next)
}
```

### Mastery Delta Values (Approximate)

| Event | Delta |
|-------|-------|
| `.correct` on brick | `+0.15` |
| `.meaningCorrect` on brick | `+0.08` |
| `.wrong` on brick | `-0.05` |
| `.correct` on pattern (Ghost Mode) | `+0.20` |
| `.wrong` on pattern (Ghost Mode) | `-0.10` |

---

## 32. LearnTabView — UI Structure

**File:** `Scene/LearnTabLogic/View/LearnTabView.swift` (565+ lines)

### Top-Level Layout

```
LearnTabView
    │
    ZStack
    ├─ ScrollView (main content)
    │    ├─ Header: VerticalHeading("LEARN") + CyberRefreshIndicator
    │    ├─ Moment Cards: HorizontalMasonryLayout
    │    │    └─ ForEach recommendations → MomentCard
    │    │         ├─ place_id label
    │    │         ├─ grounding text
    │    │         └─ pattern preview tiles
    │    │
    │    ├─ Nearby Section (if locationEnabled)
    │    │    └─ NearbyPlaceRow items from LocationManager.fetchNearbyPlaces()
    │    │
    │    └─ DoubleArrowButton (START PRACTICE)
    │
    ├─ Text input overlay (when isTextInputMode == true)
    │    └─ TextField + submit button
    │
    └─ Camera button (ImagePicker trigger)

.fullScreenCover(isPresented: $state.showLessonView):
    → LessonView(engine:, data: state.currentLesson)
```

### CategoryUI — SF Symbol Map (26 place types)

```swift
static func icon(for placeId: String) -> String {
    switch placeId.lowercased() {
    case "cafe", "coffee_shop":   "cup.and.saucer.fill"
    case "airport":               "airplane"
    case "gym", "fitness":        "figure.walk"
    case "restaurant":            "fork.knife"
    case "supermarket", "store":  "cart.fill"
    case "hospital":              "cross.fill"
    case "park":                  "leaf.fill"
    case "office", "workplace":   "building.2.fill"
    case "home":                  "house.fill"
    case "school", "university":  "book.fill"
    case "hotel":                 "bed.double.fill"
    case "bar":                   "wineglass.fill"
    case "beach":                 "water.waves"
    case "museum":                "building.columns.fill"
    case "library":               "books.vertical.fill"
    case "cinema", "theater":     "film.fill"
    case "pharmacy":              "pills.fill"
    case "bank":                  "banknote.fill"
    case "gas_station":           "fuelpump.fill"
    case "salon", "barber":       "scissors"
    case "market":                "bag.fill"
    case "police":                "shield.fill"
    case "church", "temple":      "building.fill"
    case "bus_stop", "transit":   "bus.fill"
    case "train_station":         "tram.fill"
    default:                      "mappin.circle.fill"
    }
}
```

---

## 33. Localization System

**File:** `Localization/` (15 files)  
**Manager:** `LocalizationManager.shared`, `LanguageManager.shared`

### Supported App Languages

```
English, Japanese, Telugu, Tamil, French, German,
Spanish, Chinese, Korean, Russian, Malayalam
```

Stored in `AppStateManager.appLanguage: String`.

### How Localization Works

```swift
// All UI text goes through:
localizationManager.string(.learnTab)    // "LEARN" / "学習" / "నేర్చుకో" etc.
localizationManager.string(.loading)
localizationManager.string(.noInternetConnection)
localizationManager.string(.retry)
```

`LocalizationManager.string(_ key: StringKey)` looks up the current language and returns the localized string. Falls back to English if key missing.

---

## 34. ViewModifiers — All Custom Modifiers

**File:** `Shared/ViewModifiers.swift`

### `.diagnosticBorder(_:width:)`

```swift
extension View {
    func diagnosticBorder(_ color: Color, width: CGFloat = 1) -> some View {
        // Only adds border when AppStateManager.shared.showDiagnosticBorders == true
        // Otherwise returns self unchanged (zero overhead in production)
        self.overlay(
            Rectangle().stroke(color, lineWidth: width)
                .opacity(AppStateManager.shared.showDiagnosticBorders ? 1 : 0)
        )
    }
}
```

### `.buttonPressAnimation()`

```swift
extension View {
    func buttonPressAnimation() -> some View {
        self.buttonStyle(ButtonAnimationModifier())
    }
}

struct ButtonAnimationModifier: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
```
Used on: Retry button in `LoadingView`, `LocianButton`, and any button needing the subtle press effect.

### `.locianHardShadow()`

```swift
// Adds an offset colored shadow effect (neobrutalism style)
// Offset: x+3, y+3, no blur radius
// Used on tag-style UI elements throughout the lesson engine
```

---

## Appendix: Animation System Summary

| Screen | Animation Type | Easing | Duration |
|--------|--------------|--------|---------|
| Loading: Comma logo | `scaleEffect` + `opacity` | `.easeOut` | 0.7s |
| Loading: Asterisk | `scaleEffect` + `opacity` | `.easeOut` delay(0.2) | 0.7s |
| Loading: Letters (L,O,C,I,A,N) | `scaleEffect` + `opacity` per-letter | `.easeOut` asyncAfter | 0.4s each |
| Loading: Subtitle text | `opacity` | `.easeOut` asyncAfter(1.5s) | 0.4s |
| ContentView state transitions | `.opacity` crossfade | `.easeInOut` | 0.5s |
| MainTabView overlay dismiss | `opacity` | `.easeOut` | 0.1s |
| Tab switch | spring | `response:0.4, dampingFraction:0.48` | — |
| Drill mode transition | `.asymmetric(insert:.move(.trailing), remove:.opacity)` | — | — |
| DoubleArrowButton press | `offset +4pt` | `.easeOut` | 0.05s |
| DoubleArrowButton release | `offset 0` | `.easeOut` | 0.10s |
| DoubleArrowButton swipe-cancel | spring back | `response:0.3, dampingFraction:0.6` | — |
| Button press (general) | `scaleEffect 0.95` | `.easeOut` | 0.1s |
| Stats pull-to-refresh | spring back | `.spring()` | — |
| Brick answer feedback | Background color change | `.spring(response:0.3)` | — |
| Ghost mode toggle | Expand/collapse | `.spring(response:0.35, dampingFraction:0.75)` | — |
| Haptic: button touch | `UIImpactFeedbackGenerator(.medium)` | — | — |
| Haptic: button release | `UIImpactFeedbackGenerator(.light)` | — | — |
| Haptic: correct answer | `UINotificationFeedbackGenerator(.success)` | — | — |
| Haptic: wrong answer | `UINotificationFeedbackGenerator(.error)` | — | — |
| Haptic: pull-refresh trigger | `UIImpactFeedbackGenerator(.heavy)` | — | — |

---

*This document covers the full V3.45 codebase as of 2026-03-04. Total sections: 34.*
