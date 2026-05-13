---
name: Architecture Map
overview: Compile a complete architecture understanding of the locian app (startup/navigation, Learn discovery->lesson hydration, LessonEngine orchestration+drills, speech/audio, and Stats/streak pipeline) using the key files already inspected.
todos:
  - id: verify-core-entrypoints
    content: Confirm the exact boot + routing sequence (ContentView, MainTabView, LearnTabView navigation) using the already-read files.
    status: completed
  - id: document-learn-discovery-hydration
    content: Write the Learn discovery->selection->startPractice->hydrateFromV3->LessonView call chain, citing `LearnTabState`, `DiscoverMomentsService`, `GenerateSentenceLogic`, and `LessonView`.
    status: completed
  - id: document-lesson-engine-stages
    content: "Explain LessonEngine+Orchestrator+Flow: pattern selection rules, stage transitions, and queue construction from `LessonEngine+Flow`, `LessonOrchestrator`, `PatternIntroLogic`, `PatternPracticeLogic`, `GhostModeLogic`."
    status: completed
  - id: document-drill-validation-mastery
    content: Describe mode dispatch (BrickModeSelector/PatternModeSelector), correctness checks, and mastery updates with `GranularAnalyzer` and the `checkAnswer()` call sites.
    status: completed
  - id: document-ml-and-speech-and-stats
    content: Summarize ML similarity + model loading (`EmbeddingService`/`NeuralValidator`/`ContentAnalyzer`) plus speech/audio stack and the Stats streak pipeline (`GetTargetLanguagesService`/`StatsTabState`).
    status: completed
  - id: flag-found-gaps
    content: Include any architecture gaps/risks found during reading (e.g., SentenceGenerationLoadingModal gating on `isGeneratingSentence` not set in `LearnTabState`).
    status: completed
isProject: false
---

1. Summarize app boot + session logic from `locian/ContentView.swift` + `locian/Endpoints/CheckSession/CheckSessionLogic.swift` + `locian/MainTabView.swift`.
2. Document Learn tab flow: UI entry points (`LearnTabView`, `LearnRecommendationSelector`, `LearnNearbyModule`, `LearnPatternProgression`) calling `LearnTabState.discover(...)` and `LearnTabState.startPractice()`, then hydration via `GenerateSentenceLogic.hydrateFromV3(...)`.
3. Explain the backend bridges:
  - `DiscoverMomentsService.discoverMoments(...)` builds the payload with time/location/telemetry and calls `/api/learning/discover-moments`.
  - `CompletePatternService.completePattern(...)` calls `/api/learning/complete-pattern` with GPS/time.
4. Describe LessonEngine architecture end-to-end:
  - `LessonEngine.initialize(...)` stores `groups` from `GenerateSentenceData`.
  - `LessonEngine.flow.pickNextPattern(...)` selects next pattern based on `getBlendedMastery(for:)` and 0.85 stopping rules.
  - `LessonOrchestrator` manages the stage machine (`vocabIntro` -> `patternPractice` -> `ghostManager`).
  - Stage queue builders: `PatternIntroLogic`, `PatternPracticeLogic`, `GhostModeLogic` and how they lock modes.
  - Mode dispatch: `BrickModeSelector` and `PatternModeSelector` route to specific drill logics/views.
5. Explain validation + mastery updates:
  - Validators (`TypingValidator`, `MCQValidator`, `VoiceValidator` via `ValidationContext`).
  - Ripple effect: `GranularAnalyzer.processGranularMastery(...)` updates brick mastery.
  - Direct updates for bricks/patterns in each `*Logic.checkAnswer()`.
6. Explain ML similarity infrastructure:
  - `EmbeddingService` (vectors, model download).
  - `NeuralValidator` + `SemanticMatcher` + `ContentAnalyzer` + `MasteryFilterService` / `SemanticFilterService`.
7. Explain speech/audio orchestration:
  - `SpeechRecognizer` uses `AudioManager` mic ownership and `WhisperService` final transcription.
  - Lesson voice drills (`BrickVoiceLogic`, `PatternVoiceLogic`) call transcription and then run validators.
8. Explain Stats pipeline:
  - API/source of `practice_dates` via `GetTargetLanguagesService` + `TargetLanguageLogic`.
  - Computation in `StatsTabState` (current/longest streak; chronotype stub).
9. Note any architecture gaps or likely bugs found while reading (e.g., `SentenceGenerationLoadingModal` gating on `isGeneratingSentence` with no observed setter in `LearnTabState`).

Mermaid (high-level):

```mermaid
flowchart TD
  A[App boot: `ContentView` -> `MainTabView`] --> B[Learn: `LearnTabView` + `LearnTabState`]
  B --> C0[`DiscoverMomentsService: context gathering + request build`]
  API_DISC --> D[Start learning: `startPractice` -> `GenerateSentenceLogic.hydrateFromV3`]
  D --> E[Present `LessonView` -> `LessonEngine.initialize`]
  E --> F[`LessonOrchestrator` stage machine (one active stage at a time)]
  F -->|Stage 1| S1[`PatternIntroLogic`: brick queue]
  F -->|Stage 2| S2[`PatternPracticeLogic`: mistakes + finale queue]
  F -->|Stage 3| S3[`GhostModeLogic`: history + final target queue]
  
  SEL[`Mode selection (per drill)`]

  %% ---- Discover Moments context build (before POST) ----
  subgraph DiscoverPrep[DiscoverMomentsService: gather -> normalize -> request -> POST]
    LOC0[`LocationManager.fetchNearbyPlaces (LocationManager.swift)`]
    LOCSEQ0[`ensureLocationAccess + getCurrentLocation`]
    MK0[`MKLocalSearch: POIs within 10km of GPS`]
    HARV0[`Harvest POI fields: name, rawCategory, url, areasOfInterest tags`]
    SNAP0[`SemanticSnappingService.resolveSemanticCategory (SemanticSnappingService.swift)`]
    NLP0[`NLTagger: extract nouns + lemmas from POI name`]
    CATEMB0[`EmbeddingService.compare vs category keyword anchors (airport/cafe/...)`]
    CATRES0[`snap to normalized category string`]
    VEC0[`EmbeddingService.getVector(for: place name)`]
    NEAR0[`NearbyAmbience(category, vector, lat/lon) -> DiscoverPlaceInput[] (name, category)`]
    TIME0[`time/date formatting (HH:mm, yyyy-MM-dd)`]
    MOT0[`MotionService: fetchCurrentMotionState (velocity)`]
    DCSV[`AmbientSoundService: fetchDecibels (mic sample -> dB)`]
    LIGHT0[`AmbientLightService: fetchLightLevel (light status/value)`]
    ALT0[`AltitudeService: fetchAltitude`]
    WIFI0[`WiFiService: currentSSID`]
    IMG0[`Optional image: jpeg -> base64 data URI`]
    REQ0[`Build DiscoverMomentsRequest JSON`]
    API_DISC[`BaseAPIManager.performRawRequest<br/>inject ` + "`Authorization`" + ` + ` + "`session_token`" + ` + POST `/api/learning/discover-moments``]

    C0 --> TIME0
    C0 --> LOC0
    LOC0 --> LOCSEQ0
    LOCSEQ0 --> MK0
    MK0 --> HARV0
    HARV0 --> SNAP0
    SNAP0 --> NLP0
    SNAP0 --> CATEMB0
    CATEMB0 --> CATRES0
    CATRES0 --> VEC0
    VEC0 --> NEAR0
    C0 --> MOT0
    C0 --> DCSV
    C0 --> LIGHT0
    C0 --> ALT0
    C0 --> WIFI0
    C0 --> IMG0
    NEAR0 --> REQ0
    TIME0 --> REQ0
    MOT0 --> REQ0
    DCSV --> REQ0
    LIGHT0 --> REQ0
    ALT0 --> REQ0
    WIFI0 --> REQ0
    IMG0 --> REQ0
    REQ0 --> API_DISC
  end

  %% ---- Pattern Intro brick reveal pipeline (similarity -> semantic cliff) ----
  S1 --> CA0[`Laser / JNS scoring:<br/>ContentAnalyzer.findRelevantBricksWithSimilarity<br/>- scans sentence/meaning for brick phrases (sub-sequence match)<br/>- scores each brick using WordSimilarityService.calculateDualJointScore<br/>  (L2 + L1 embeddings + NLTagger POS multipliers via TokenTaggerService)<br/>outputs: (brickId, similarityScore)`]
  CA0 --> MFS0[`Mastery filter:<br/>MasteryFilterService.filterBricksBySemanticCliff<br/>inputs: (brick scores) + patternMastery`]
  MFS0 --> TH0[`threshold = 0.65*(1 - clamp(patternMastery/0.50,0,1))`]
  TH0 --> GU0[`guardrail: if reveal<2 and candidates>=2 -> reveal top 2`]
  GU0 --> BRSET0[`selected brick IDs (reveal set)`]
  BRSET0 --> DRGEN0[`PatternIntroLogic creates DrillState[]<br/>from selected bricks`]
  DRGEN0 --> SEL

  S2 --> SEL
  S3 --> SEL

  %% ---- Mode selection ----
  subgraph ModeSelection[Mode Selection & Thresholds]
    BMS[`BrickModeSelector.resolveMode`<br/>`BrickModeSelector.swift`]
    PMS[`PatternModeSelector.resolveMode`<br/>`PatternModeSelector.swift`]

    BMS -->|score < 0.20| BC1[componentMcq<br/>`BrickMCQLogic.swift`]
    BMS -->|0.20-0.40| BC2[cloze<br/>`BrickClozeLogic.swift`]
    BMS -->|0.40-0.65| BC3[componentTyping<br/>`BrickTypingLogic.swift`]
    BMS -->|0.65-0.90| BC4[speaking<br/>`BrickVoiceLogic.swift`]
    BMS -->|score >= 0.90| BC5[mastered<br/>(victory view)]

    PMS -->|blended < 0.25| PC1[mcq<br/>`PatternMCQLogic.swift`]
    PMS -->|0.25-0.40| PC2[sentenceBuilder<br/>`PatternBuilderLogic.swift`]
    PMS -->|0.40-0.60| PC3[typing<br/>`PatternTypingLogic.swift`]
    PMS -->|0.60-0.85| PC4[speaking<br/>`PatternVoiceLogic.swift`]
    PMS -->|blended >= 0.85| PC5[mastered<br/>(victory view)]
  end

  %% ---- Scoring ----
  subgraph Scoring[Correct/Wrong Mastery Deltas]
    BRICKD[Brick mastery update<br/>correct: +0.15<br/>wrong: -0.05]
    PATTERND[Pattern mastery update<br/>correct: +0.20<br/>wrong: -0.05]
    RIPPLE[GranularAnalyzer ripple (pattern -> bricks)<br/>userSim >= 0.65 => brick +0.10<br/>else => brick -0.05<br/>`GranularAnalyzer.swift`]
    COMP[Speaking completion side-effect<br/>PatternVoiceLogic: if correct AND blended >= 0.85 => CompletePatternLogic -> `/api/learning/complete-pattern`]
    STATS[Server updates `practice_dates` => StatsTabState refresh]
  end

  %% ---- Validation internals (validators + embeddings + semantic matching) ----
  subgraph ValidationSystem[Validation system: validator selection + embeddings]
    VSEL[`Drill checkAnswer chooses validator`]
    MCQVAL[`MCQValidator.swift<br/>MCQ: exact input == target OR == drillData.meaning => .correct<br/>else .wrong`]
    TYPVAL[`TypingValidator.swift<br/>5-gate logic:<br/>1 exact => .correct<br/>2 EmbeddingService.compare > strict => .correct<br/>3 adaptive semantic (mastery-based tolerance) => .meaningCorrect<br/>4 typo rescue (Levenshtein normalized) => .meaningCorrect<br/>5 else .wrong`]
    VOICVAL[`VoiceValidator.swift<br/>Levenshtein distance <= tolerance*len => .correct<br/>else .wrong`]
    EMB[`EmbeddingService.compare -> EmbeddingService.getVector<br/>(contextual if available; else static)<br/>cosine similarity => semantic similarity`]

    GCAND[`GranularAnalyzer: ContentAnalyzer.findRelevantBricks<br/>target/meaning + engine.allBricks -> brickIds`]
    RESBR[`MasteryFilterService.resolveBricks<br/>brickIds -> BrickItem[]`]
    TOKSOL[`parseTextTokens(solutionText)<br/>(type decides: target vs meaning)`]
    TOKIN[`parseTextTokens(userInput)<br/>tokens for the answer`]
    BRSTEP[`For each brick:<br/>brickSearchTerm = (MCQ ? brick.meaning : brick.word)`]
    ANCHSEL[`BestAnchorToken:<br/>SemanticMatcher.calculatePairSimilarity<br/>brickSearchTerm vs each solution token (max)`]
    USERMAX[`userSim:<br/>SemanticMatcher.calculatePairSimilarity<br/>bestAnchorToken vs each input token (max)`]
    VERDICT[`Verdict: isCorrect = userSim >= 0.65`]
    DELTA2[`Brick delta: correct +0.10 else -0.05`]
    
    VSEL --> MCQVAL
    VSEL --> TYPVAL
    VSEL --> VOICVAL
    TYPVAL --> EMB
    EMB --> RIPPLE

    GCAND --> RESBR
    RESBR --> TOKSOL
    RESBR --> TOKIN
    TOKSOL --> ANCHSEL
    TOKIN --> USERMAX
    BRSTEP --> ANCHSEL
    ANCHSEL --> USERMAX
    USERMAX --> VERDICT
    VERDICT --> DELTA2
    DELTA2 --> RIPPLE
  end

  %% Route scoring
  SEL --> BMS
  SEL --> PMS
  BC1 --> BRICKD
  BC2 --> BRICKD
  BC3 --> BRICKD
  BC4 --> BRICKD

  PC1 --> PATTERND
  PC2 --> PATTERND
  PC3 --> PATTERND
  PC4 --> PATTERND

  %% ---- Semantic filter for typing/builder “valid bricks” (similarityScore ranking) ----
  PC2 --> SF0[`SemanticFilterService.getFilteredBricks<br/>uses ContentAnalyzer.findRelevantBricksWithSimilarity<br/>then filters by score >= caller threshold<br/>returns FilterResult(similarityScore)`]
  PC3 --> SF0
  SF0 --> EXP0[`PatternBuilder/Typing uses similarityScore<br/>to populate validBrickWords + exploreWords`]

  %% Ripple scoring
  PATTERND --> RIPPLE
  PC4 --> COMP
  COMP --> STATS

  %% ---- Drill execution ----
  SEL --> DRILL[`drill UI`]
  DRILL --> H[`checkAnswer()`]
  H --> I[`updateMastery` + `GranularAnalyzer`]
  I -->|Advance within stage| F
  H --> VSEL

  %% ---- correctness definition ----
  H --> CORR[Correctness definition (all modes)<br/>correct if result == `.correct` OR `.meaningCorrect`]

  %% keep Stats tied to completion path
  STATS --> Q[Stats UI]
```



## Drill Mode Matrix (Brick + Pattern)

### How modes are selected (selection thresholds)

Brick mode selection (used for `vocabIntro` bricks and practice mistakes bricks):

- Selector: `locian/Scene/LessonEngine/BrickDrills/BrickModeSelector.swift` (`resolveMode(for:engine:)`)
- Thresholds based on brick mastery (`engine.getDecayedMastery(for:)`):
  - `< 0.20` -> `.componentMcq`
  - `< 0.40` -> `.cloze`
  - `< 0.65` -> `.componentTyping`
  - `< 0.90` -> `.speaking`
  - `>= 0.90` -> `.mastered`

Pattern mode selection (used for practice finale patterns and ghost patterns):

- Selector: `locian/Scene/LessonEngine/PatternDrills/PatternModeSelector.swift` (`resolveMode(for:engine:)`)
- Thresholds based on blended pattern mastery (`engine.getBlendedMastery(for:)`):
  - `< 0.25` -> `.mcq`
  - `< 0.40` -> `.sentenceBuilder`
  - `< 0.60` -> `.typing`
  - `< 0.85` -> `.speaking`
  - `>= 0.85` -> `.mastered`

Mode locking / stage queue ownership (so modes don’t “flip” mid-stage):

- `locian/Scene/LessonEngine/FlowAlgorithm/OrchestrationLogic/PatternIntroLogic.swift`
  - `resolveCurrentMode(at:)` assigns `brickDrills[index].currentMode` via `BrickModeSelector`.
- `locian/Scene/LessonEngine/FlowAlgorithm/OrchestrationLogic/PatternPracticeLogic.swift`
  - `loadCurrentItem()` assigns:
    - bricks: `BrickModeSelector.resolveMode(...)`
    - patterns: `PatternModeSelector.resolveMode(...)`
- `locian/Scene/LessonEngine/FlowAlgorithm/OrchestrationLogic/GhostModeLogic.swift`
  - builds `historyQueue` once and locks:
    - `ghostDrill.currentMode = PatternModeSelector.resolveMode(...)`
    - `finalTarget.currentMode = PatternModeSelector.resolveMode(...)`

### Correctness definition used by all drills

All drill modes treat correctness as:

- `result == .correct` OR `result == .meaningCorrect`
(so `meaningCorrect` counts as correct for scoring)

### Brick drills: exact mastery deltas (+/−) and files

Brick mastery deltas are applied to the brick’s ID via `LessonEngine.updateMastery(id:delta:)`.

1. `componentMcq` (Brick MCQ)

- File: `locian/Scene/LessonEngine/BrickDrills/Logic/BrickMCQLogic.swift`
- Correct -> `engine.updateMastery(id: brickId, delta: +0.15)`
- Wrong   -> `engine.updateMastery(id: brickId, delta: -0.05)`

1. `cloze` (Brick Cloze)

- File: `locian/Scene/LessonEngine/BrickDrills/Logic/BrickClozeLogic.swift`
- Correct -> `engine.updateMastery(id: brickId, delta: +0.15)`
- Wrong   -> `engine.updateMastery(id: brickId, delta: -0.05)`

1. `componentTyping` (Brick Typing)

- File: `locian/Scene/LessonEngine/BrickDrills/Logic/BrickTypingLogic.swift`
- Correct -> `engine.updateMastery(id: brickId, delta: +0.15)`
- Wrong   -> `engine.updateMastery(id: brickId, delta: -0.05)`

1. `speaking` (Brick Voice)

- File: `locian/Scene/LessonEngine/BrickDrills/Logic/BrickVoiceLogic.swift`
- Correct -> `engine.updateMastery(id: brickId, delta: +0.15)`
- Wrong   -> `engine.updateMastery(id: brickId, delta: -0.05)`

### Pattern drills: exact mastery deltas (+/−) and files

Pattern mastery deltas are applied to the pattern’s ID via `LessonEngine.updateMastery(id:delta:)`.

1. `mcq` (Pattern MCQ)

- File: `locian/Scene/LessonEngine/PatternDrills/Logic/PatternMCQLogic.swift`
- Correct -> `engine.updateMastery(id: state.patternId, delta: +0.20)`
- Wrong   -> `engine.updateMastery(id: state.patternId, delta: -0.05)`

1. `sentenceBuilder` (Pattern Builder)

- File: `locian/Scene/LessonEngine/PatternDrills/Logic/PatternBuilderLogic.swift`
- Correct -> `engine.updateMastery(id: state.patternId, delta: +0.20)`
- Wrong   -> `engine.updateMastery(id: state.patternId, delta: -0.05)`

1. `typing` (Pattern Typing)

- File: `locian/Scene/LessonEngine/PatternDrills/Logic/PatternTypingLogic.swift`
- Correct -> `engine.updateMastery(id: state.patternId, delta: +0.20)`
- Wrong   -> `engine.updateMastery(id: state.patternId, delta: -0.05)`

1. `speaking` (Pattern Voice / Dictation)

- File: `locian/Scene/LessonEngine/PatternDrills/Logic/PatternVoiceLogic.swift`
- Correct -> `engine.updateMastery(id: state.patternId, delta: +0.20)`
- Wrong   -> `engine.updateMastery(id: state.patternId, delta: -0.05)`
- Backend completion trigger:
  - if correct AND `engine.getBlendedMastery(for: state.patternId) >= 0.85`
  - then `CompletePatternLogic.shared.reportCompletion(patternId:, engine:)`

### Pattern -> Brick ripple scoring (GranularAnalyzer)

Every pattern drill also updates brick mastery via granular analysis:

- File: `locian/Scene/LessonEngine/Validation/Granular/GranularAnalyzer.swift`
- Anchor verdict:
  - `isCorrect = userSim >= 0.65`
- Brick mastery delta:
  - correct -> `engine.updateMastery(id: brick.id, delta: +0.10)`
  - wrong   -> `engine.updateMastery(id: brick.id, delta: -0.05)`

