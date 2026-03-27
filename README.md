# Locian — Architecture Overview

> **Context-aware language learning powered by your environment.**  
> Locian senses where you are, what you're doing, and what's around you — then serves language patterns tuned to that exact moment.

---

## Table of Contents

- [System Overview](#system-overview)
- [Front-End (iOS / Swift)](#front-end-ios--swift)
  - [App Boot & Tab Structure](#app-boot--tab-structure)
  - [Discover Moments Pipeline](#discover-moments-pipeline)
  - [Lesson Engine & Stage Machine](#lesson-engine--stage-machine)
  - [Mode Selection](#mode-selection)
  - [Validation System](#validation-system)
  - [Scoring & Mastery Deltas](#scoring--mastery-deltas)
- [Back-End (FastAPI / Python)](#back-end-fastapi--python)
  - [API Endpoints](#api-endpoints)
  - [Cleaning Gate](#cleaning-gate)
  - [Place Prediction Algorithm](#place-prediction-algorithm)
  - [Resolvers (Parallel Rituals)](#resolvers-parallel-rituals)
  - [Physics Reality Pass & Normalization](#physics-reality-pass--normalization)
  - [Patterns Pipeline](#patterns-pipeline)
- [Database Layer (Firestore)](#database-layer-firestore)
- [Cross-System API Calls](#cross-system-api-calls)
- [Data Flow — End to End](#data-flow--end-to-end)

---

## System Overview

Locian is a two-layer system:

| Layer | Stack | Role |
|---|---|---|
| **iOS Client** | Swift, SwiftUI | Sensor fusion, lesson UI, mastery tracking |
| **API Server** | FastAPI (Python) | Context cleaning, intent resolution, pattern recommendation |
| **Database** | Firestore | User state, geo context, pattern catalog, voice clips |

The core loop:

```
Sensors (GPS, mic, light, motion, WiFi, altitude)
    → DiscoverMomentsService (Swift)
        → POST /api/learning/discover-moments
            → Cleaning → Prediction → Resolvers → Physics → Patterns
                → LessonEngine (Swift)
                    → Drills → Mastery updates → POST /api/learning/complete-pattern
```

---

## Front-End (iOS / Swift)

### App Boot & Tab Structure

```
ContentView
  └── MainTabView
        └── LearnTabView  ←→  LearnTabState
```

`LearnTabView` is the entry point for the learning flow. It coordinates with `LearnTabState` to manage session state and trigger the Discover Moments context-gathering pipeline before a lesson starts.

---

### Discover Moments Pipeline

Before any lesson is requested, the app assembles a rich environmental context payload. All data collection is parallel where possible.

#### Location & Place Semantics (`LocationManager.swift`, `SemanticSnappingService.swift`)

1. **Permission & GPS fix** — `ensureLocationAccess` → `getCurrentLocation`
2. **POI discovery** — `MKLocalSearch` scans within 10 km of the current GPS fix, harvesting `name`, `rawCategory`, `url`, and `areasOfInterest` tags
3. **Semantic snapping** (`SemanticSnappingService.resolveSemanticCategory`):
   - `NLTagger` extracts nouns + lemmas from each POI name
   - `EmbeddingService.compare` scores extracted terms against category keyword anchors (`airport`, `cafe`, etc.) using L2 + L1 embeddings with POS multipliers
   - Result: a normalized category string per place
4. **Vector embedding** — `EmbeddingService.getVector(for: place name)` → `NearbyAmbience` struct

#### Ambient Sensors

| Sensor | Service | Output |
|---|---|---|
| Microphone | `AmbientSoundService.fetchDecibels` | dB float |
| Light | `AmbientLightService.fetchLightLevel` | status / lux |
| Motion / velocity | `MotionService.fetchCurrentMotionState` | m/s float |
| Altitude | `AltitudeService.fetchAltitude` | metres |
| WiFi | `WiFiService.currentSSID` | SSID string |
| Camera (optional) | jpeg → base64 data URI | image payload |

#### Time Encoding

Current time is formatted as `HH:mm` and `yyyy-MM-dd`. Both are included in the request so the server can resolve temporal context without relying on its own clock.

#### Request Dispatch

All harvested data is packed into a `DiscoverMomentsRequest` JSON and posted via `BaseAPIManager.performRawRequest` with injected `Authorization` and `session_token` headers to:

```
POST /api/learning/discover-moments
```

---

### Lesson Engine & Stage Machine

After the API responds, `GenerateSentenceLogic.hydrateFromV3` constructs the lesson data. `LessonView` initialises `LessonEngine`, which hands off to `LessonOrchestrator` — a linear stage machine:

```
LessonOrchestrator
  ├── Stage 1 — PatternIntroLogic   (brick reveal queue)
  ├── Stage 2 — PatternPracticeLogic (mistakes + finale queue)
  └── Stage 3 — GhostModeLogic      (history + final target queue)
```

Only one stage is active at a time. Completing all drills in a stage advances to the next.

#### Brick Reveal (Stage 1 deep-dive)

`PatternIntroLogic` selects which vocabulary bricks to surface via a two-step filter:

1. **Laser / JNS scoring** (`ContentAnalyzer.findRelevantBricksWithSimilarity`):
   - Sub-sequence match scans the sentence/meaning for brick phrases
   - Each brick is scored with `WordSimilarityService.calculateDualJointScore` — L2 + L1 embeddings combined with NLTagger POS multipliers via `TokenTaggerService`
   - Output: `(brickId, similarityScore)` pairs

2. **Mastery filter** (`MasteryFilterService.filterBricksBySemanticCliff`):
   - `threshold = 0.65 × (1 − clamp(patternMastery / 0.50, 0, 1))`
   - Guardrail: if fewer than 2 bricks pass the threshold but ≥ 2 candidates exist, the top 2 are revealed regardless

Selected bricks become `DrillState[]` entries fed into mode selection.

---

### Mode Selection

Each drill is independently routed to a UI mode based on current mastery score.

#### Brick Modes (`BrickModeSelector.swift`)

| Score Range | Mode | Logic File |
|---|---|---|
| < 0.20 | `componentMcq` | `BrickMCQLogic.swift` |
| 0.20 – 0.40 | `cloze` | `BrickClozeLogic.swift` |
| 0.40 – 0.65 | `componentTyping` | `BrickTypingLogic.swift` |
| 0.65 – 0.90 | `speaking` | `BrickVoiceLogic.swift` |
| ≥ 0.90 | mastered | victory view |

#### Pattern Modes (`PatternModeSelector.swift`)

| Blended Score | Mode | Logic File |
|---|---|---|
| < 0.25 | `mcq` | `PatternMCQLogic.swift` |
| 0.25 – 0.40 | `sentenceBuilder` | `PatternBuilderLogic.swift` |
| 0.40 – 0.60 | `typing` | `PatternTypingLogic.swift` |
| 0.60 – 0.85 | `speaking` | `PatternVoiceLogic.swift` |
| ≥ 0.85 | mastered | victory view |

---

### Validation System

`checkAnswer()` delegates to a validator chosen by drill type:

#### `MCQValidator.swift`
Exact string match against target or `drillData.meaning` → `.correct` or `.wrong`.

#### `TypingValidator.swift` — 5-gate logic
1. Exact match → `.correct`
2. `EmbeddingService.compare` above strict threshold → `.correct`
3. Adaptive semantic check (mastery-based tolerance) → `.meaningCorrect`
4. Levenshtein normalized typo rescue → `.meaningCorrect`
5. Fall-through → `.wrong`

#### `VoiceValidator.swift`
Levenshtein distance ≤ `tolerance × len(target)` → `.correct`, else `.wrong`.

#### `EmbeddingService`
Provides contextual embeddings where available, static otherwise. Cosine similarity is the final scoring primitive for all semantic comparisons.

#### Correctness Definition
A response is treated as **correct** if the validator returns `.correct` **or** `.meaningCorrect`.

---

### Scoring & Mastery Deltas

#### Per-drill mastery updates

| Event | Brick delta | Pattern delta |
|---|---|---|
| Correct | +0.15 | +0.20 |
| Wrong | −0.05 | −0.05 |

#### Ripple effect (`GranularAnalyzer.swift`)

After a pattern drill, `GranularAnalyzer` propagates the result down to individual bricks:

1. `ContentAnalyzer.findRelevantBricks` identifies which bricks are semantically present in the answer
2. For each brick: `SemanticMatcher.calculatePairSimilarity` finds the best anchor token in the solution, then scores the user's input against it
3. `userSim ≥ 0.65` → brick +0.10; else brick −0.05

#### Pattern completion side-effect

`PatternVoiceLogic` posts to `/api/learning/complete-pattern` when: answer is correct **AND** blended score ≥ 0.85. The server writes the practice event; the client refreshes `practice_dates` in `StatsTabState`.

---

## Back-End (FastAPI / Python)

### API Endpoints

| Method + Path | Handler | Purpose |
|---|---|---|
| `POST /api/learning/discover-moments` | `PatternFlowService.get_pattern_flow_async` | Full context → pattern recommendations |
| `POST /api/learning/complete-pattern` | `DBWriter` + grounding | Record practice, trigger geo grounding |
| `POST /api/user/intent/context` | Intent handler | Read / update geo and routine overrides |

---

### Cleaning Gate

`CleaningEngine.clean_at_the_gate` runs synchronously before any prediction logic. It mutates the payload in place.

#### Temporal Resolver (`temporal_resolver.resolve_temporal_context`)
- Priority chain: `payload.time (HH:MM)` → `payload.timestamp (ISO)` → `payload.hour` → `ValueError` (server clock is never used)
- Cyclic encoding: `radians = (hour / 24) × 2π` → `time_vec = [sin(r), cos(r)]`
- A normalised `ts = Datetime(2000-01-01, hour, minute)` is attached for downstream comparisons

#### Semantic Bridge (`semantic_bridge.resolve_neighborhood_async`)
- Triggered only when a place's category is empty, `"unknown"`, or `"none"`
- Embedding text: `"{name} {cat}"` if category exists, else `"point of interest"`
- Batch embeddings via `embedding_service.get_embeddings_batch`
- Assignment: cosine similarity ≥ 0.35 → use `best_cat`, else keep `"unknown"`

#### Sensor Cleaners

| Cleaner | Input | Logic |
|---|---|---|
| `velocity_cleaner` | velocity string | Strip `m/s` / `km/h` unit suffix → `float` |
| `weather_cleaner` | `"temp*C\|CONDITION"` | Split on `\|`; `temp = float(part0.replace('*C',''))` |
| `audio_cleaner` | dB string | → `float` or `None` |
| `light_cleaner` | light string | → `float` or `None` |
| `altitude_cleaner` | altitude string | → `float` or `None` |

---

### Place Prediction Algorithm

`PlacePredictionAlgorithm.predict_intent` builds a current state vector:

- `time_vec` — from temporal resolver
- `poi_vec` — `aggregate_poi_semantics(payload.places)` (mean of place embeddings)
- `motion`, `weather` — lowercased strings
- `lat`, `lng` — raw GPS

**Continuity & jitter filter:**
1. Loads up to 10 historical prediction states from Firestore
2. `_haversine_meters` computes displacement from last saved location
3. `is_traveling = distance_m > 25.0`
4. Jitter multiplier: `0.1` if stationary AND category not in past predictions, else `1.0`

State is persisted to `users/{uid}/prediction_history/vectors/states/{timestamp}` (max 10 entries retained).

---

### Resolvers (Parallel Rituals)

All four resolvers run concurrently via `asyncio.gather`. Each emits a `{ category: weight, source }` dict that is fused in log-space.

#### User Routine Resolver (`user_location_resolver`)
- Reads all temporal buckets for the user (`users/{uid}/prediction_history/{span_id}`)
- Matches current hour to a time span; looks up `personal_routine` tags for that span
- Match → `weight = 1.0`; no match → `weight = 0.7` (noise)

#### Geo Memory Resolver (`geo_context_resolver`)
- Geohash of current GPS → load `users/{uid}/geo_context/{geo_id}`
- Verification gate: substring-match current POI names vs saved names; needs `min(1 if pinned else 3, len(saved))` overlapping names to pass
- Weights from `read_geo_spatial_metadata` are `tanh`-scaled: `scaled_weight = tanh(raw_weight)`

#### Explicit Intent Resolver (`explicit_resolver`)
- Embeds the user's explicit text → `semantic_bridge.find_closest_category_async`
- Similarity < 0.35 → reject
- `probability_service.score_category` sanity check; score ≤ −5.0 → reject
- Pass → `multiplier = 2.0`; triggers `grounding_service` write

#### Vision Resolver (`image_resolver`)
- `centralized_llm.analyze_image_async(image_base64)` → `place_category` string
- Same semantic bridge + reality score pipeline as explicit resolver
- Pass → `multiplier = 2.0`; triggers `grounding_service` write

#### Log-Space Fusion (`_fuse_signal`)
```
multiplier = max(multiplier, 0.0001)
logit_delta = log(multiplier)
weight += logit_delta
hits++
```

---

### Physics Reality Pass & Normalization

#### `ProbabilityService.score_category`
```
score = log(p_base) + log(max(real_score, 1e-6))
```

#### Softmax + Boost
- Bonus: `log(1.2)` added to categories signalled by more than one resolver (`hits > 1`)
- Softmax normalisation; categories below 1% of total probability are dropped

#### Ecosystem Resolver (`ecosystem_resolver.resolve_invisible_places`)
- Surfaces places not in the immediate GPS radius but implied by context
- Centroid fusion: GPS centroid, DB meta centroid, routine centroid, physics top-3 centroid (kept if `exp(score) > 0.5`, weighted by `ember_rating > 0.1`)

Top 5 categories are forwarded to the Patterns pipeline.

---

### Patterns Pipeline

`PatternsService.get_batch_lessons_async` runs four steps:

1. **Fetch** — `db_reader.read_patterns_by_place` pulls from `catalogs/patterns_v1` keyed by `(user_lang, target_lang, place)`
2. **Reality filter** — `RealityEngine.compose` drops patterns with score ≤ 0
3. **History filter** — `filter_by_history` prioritises review patterns and unpractised content; conversation-type boost: +2.0 / +1.5 / +0.5 (read from `users/{uid}/practiced_patterns/{place_id}`)
4. **Thematic siblings** — `get_thematic_siblings(limit=2)` uses Jaccard-like token overlap; falls back to any positive-score pattern
5. **Audio enrichment** — `db_reader.read_voice_clips_batch` attaches base64 voice data from `global_voice_clips/.../clips/{voice_id}`

---

## Database Layer (Firestore)

| Collection path | Owner | Contents |
|---|---|---|
| `users/{uid}/geo_context/{geo_id}` | Geo resolver | `tag_scores`, `saved_names`, `is_pinned` |
| `users/{uid}/prediction_history/{span_
