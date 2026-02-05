# LESSON ENGINE ARCHITECTURE
========================================

## FOLDER STRUCTURE

```
/Scene/LessonEngine/
├── Core Engine
│   ├── LessonEngine.swift                  # Main class + state
│   ├── PatternProgressionManager.swift     # Pattern selection (extension)
│   ├── BrickOrchestrator.swift             # Brick analysis (extension)
│   ├── ComponentLevelTracker.swift         # Level tracking (extension)
│   ├── LessonEngineModels.swift            # Data models
│   ├── LessonEngineUtilities.swift         # Utilities (DrillFactory, MCQ)
│   └── NeuralValidator.swift               # Semantic validation
│
├── Session Management
│   ├── LessonSessionManager.swift          # Session state
│   └── LessonSessionModels.swift           # Session models
│
├── Drill UI (Display Layer)
│   ├── DrillCardView.swift                 # Main drill container
│   ├── InputDrills.swift                   # Typing, dictation, speaking
│   ├── SelectionDrills.swift               # MCQ, vocab match
│   └── AdvancedDrills.swift                # Reorder, sentence builder
│
└── Documentation
    ├── README.md                           # This file
    └── LEVELS.md                           # Level tracking system
```

## FLOW ARCHITECTURE

### 1. PATTERN PROGRESSION (LessonEngine.swift)
**Entry Point**: `getNextCard()`
- Manages pattern queue
- Tracks pattern progress
- Decides when to show patterns

### 2. BRICK ORCHESTRATOR (LessonEngine.swift)
**Centralized Methods**:
- `analyzeBricksForPattern()` - Determines which bricks needed and at what level
- `scheduleBricksForPattern()` - Schedules bricks before pattern

**Flow**:
```
Pattern Ready
    ↓
Analyze Bricks (what bricks? what level?)
    ↓
Schedule Bricks (Level 0-5)
    ↓
User Completes Bricks
    ↓
Pattern Appears
```

### 3. DRILL TYPES (LessonEngineUtilities.swift)
**DrillFactory.createBrickDrill()**
Maps level → drill mode:
- Level 0: Flashcard
- Level 1: Component MCQ
- Level 2: Component Typing
- Level 3: Voice MCQ
- Level 4: Voice Typing
- Level 5: Mastered

### 4. UI LAYER (LessonSessionManager.swift)
**Responsibilities**:
- Receives drill cards from engine
- Manages UI state
- Submits answers back to engine

## KEY COMPONENTS

### Pattern Progress Tracking
```swift
@Published var patternProgress: [String: PatternProgress]
```

### Brick Level Tracking
```swift
@Published var componentLevels: [String: Int] = [:]  // 0-5
```

### Centralized Brick Analysis
```swift
analyzeBricksForPattern(drill: DrillState) -> [(brickId: String, level: Int)]
```

## DATA FLOW

```
API Response
    ↓
LessonEngine.initialize()
    ↓
Pre-compute brick mappings
    ↓
getNextCard() → Pattern
    ↓
analyzeBricksForPattern() → Determine levels
    ↓
scheduleBricksForPattern() → Queue bricks
    ↓
DrillFactory.createBrickDrill() → Create drill at level
    ↓
LessonSessionManager → Display UI
    ↓
User completes drill
    ↓
submitAnswer() → Update componentLevels
    ↓
Pattern appears (after all bricks)
```

## CENTRALIZED LOGIC

All brick-related decisions happen in **ONE PLACE**:
- `analyzeBricksForPattern()` - What to show
- `scheduleBricksForPattern()` - When to show it
- `componentLevels` - Single source of truth for levels

No scattered logic, no conflicts, no double increments.
