# LEVEL TRACKING SYSTEM
========================

## BRICK LEVELS (0-5)
Each brick progresses through 5 levels:
- **Level 1**: Component MCQ (Recognition)
- **Level 2**: Voice MCQ (Listening)
- **Level 3**: Cloze (Challenge)
- **Level 4**: Typing (Production)
- **Level 5**: Speaking (Mastery)

## PATTERN LEVELS (0-3)
Each pattern drill progresses through 3 levels:
- **Level 1**: MCQ (Recognition)
- **Level 2**: Voice MCQ (Listening)
- **Level 3**: Typing (Production)

## MOMENT LEVELS (0-2)
Each moment progresses through 2 stages:
- **Level 0**: Not started
- **Level 1**: Word bank (sentence builder) completed
- **Level 2**: Typing completed (mastered)

## TRACKING STORAGE
All stored in `componentLevels: [String: Int]`:
```swift
componentLevels = [
    // Bricks (0-5)
    "por-favor": 3,
    "olvidé": 5,
    
    // Patterns (0-3)
    "p1-d0": 2,
    "p2-d1": 3,
    
    // Moments (0-2)
    "MOMENT-cafe-1": 1,
    "MOMENT-cafe-2": 2
]
```

## USAGE
- **Bricks**: `componentLevels[brickId]` → 0-5 (Mapped from Score 0.0-1.0)
- **Patterns**: `componentLevels[patternDrillId]` → 0-3 (Mapped from Score 0.0-1.0)
- **Moments**: `componentLevels[momentId]` → 0-2
