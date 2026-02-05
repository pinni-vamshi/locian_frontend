//
//  StatsCalculator.swift
//  locian
//
//  Pure Flow Stats Calculator
//  Simplified to work with stateless DrillState architecture
//

import Foundation
import SwiftUI

// MARK: - Data Models for Visualization

struct SkillRadarPoint {
    let reading: Double
    let writing: Double
    let listening: Double
    let speaking: Double
}

struct FluencyDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let masteryScore: Double // Simplified to just show mastery progression
}

struct ChronotypeData {
    let type: String
    let description: String
    let peakHour: Int
    let hourCounts: [Int]
}

struct TimelineDistribution {
    let past: Int
    let present: Int
    let future: Int
    
    var total: Int { past + present + future }
}

class StatsCalculator {
    static let shared = StatsCalculator()
    
    private init() {}
    
    // MARK: - 1. Skill Radar (Mode Balance)
    func calculateSkillRadar(drills: [DrillState]) -> SkillRadarPoint {
        var readingCount = 0.0
        var writingCount = 0.0
        var listeningCount = 0.0
        var speakingCount = 0.0
        
        // Count by mode (simplified - no tracking, just current mode)
        for drill in drills {
            let score = drill.masteryScore
            guard score > 0, let mode = drill.currentMode else { continue }
            
            switch mode {
            case .mcq, .cloze, .componentMcq, .vocabMatch:
                readingCount += score
            case .sentenceBuilder, .typing, .componentTyping:
                writingCount += score
            case .voiceMcq, .voiceNativeTyping:
                listeningCount += score
            case .voiceTyping:
                listeningCount += score
                writingCount += (score * 0.5)
            case .speaking:
                speakingCount += score
            default:
                break
            }
        }
        
        let maxVal = max(readingCount, max(writingCount, max(listeningCount, speakingCount)))
        
        if maxVal == 0 { return SkillRadarPoint(reading: 0, writing: 0, listening: 0, speaking: 0) }
        
        return SkillRadarPoint(
            reading: readingCount / maxVal,
            writing: writingCount / maxVal,
            listening: listeningCount / maxVal,
            speaking: speakingCount / maxVal
        )
    }
    
    // MARK: - 2. Fluency Trend (Mastery Progression)
    func calculateFluencyTrend(drills: [DrillState]) -> [FluencyDataPoint] {
        // Pure flow: just show mastery scores in order
        let activeDrills = drills.filter { $0.masteryScore > 0 }
        let recent = activeDrills.suffix(30)
        
        return recent.enumerated().map { (index, drill) in
            FluencyDataPoint(index: index, masteryScore: drill.masteryScore)
        }
    }
    
    // MARK: - 3. Vocabulary Size (Simplified)
    func calculateVocabularySize(componentMastery: [String: Double]) -> Int {
        // Count components with mastery >= 0.95
        return componentMastery.filter { $0.value >= 0.95 }.count
    }
    
    // MARK: - 4. Chronotype (Time Analysis)
    func determineChronotype(practiceDates: [String]) -> ChronotypeData {
        var hourCounts = [Int](repeating: 0, count: 24)
        
        for dateStr in practiceDates {
            if let date = DateFormatter.yyyyMMddHHmm.date(from: dateStr) {
                let hour = Calendar.current.component(.hour, from: date)
                hourCounts[hour] += 1
            }
        }
        
        var maxWindowCount = 0
        var bestWindowStart = 0
        
        for h in 0..<24 {
            let c1 = hourCounts[h]
            let c2 = hourCounts[(h+1)%24]
            let c3 = hourCounts[(h+2)%24]
            let total = c1 + c2 + c3
            if total > maxWindowCount {
                maxWindowCount = total
                bestWindowStart = h
            }
        }
        
        let peakCenter = (bestWindowStart + 1) % 24
        
        let type: StringKey
        let desc: StringKey
        
        switch peakCenter {
        case 5..<12:
            type = .earlyBird
            desc = .earlyBirdDesc
        case 12..<17:
            type = .dayWalker
            desc = .dayWalkerDesc
        default:
            type = .nightOwl
            desc = .nightOwlDesc
        }
        
        return ChronotypeData(
            type: LocalizationManager.shared.string(type),
            description: LocalizationManager.shared.string(desc),
            peakHour: peakCenter,
            hourCounts: hourCounts
        )
    }
    
    // MARK: - 5. Helper: Extract Hours from Studied Places
    func getStudiedPlaceHours(places: [MicroSituationData]) -> [Int] {
        var hours: [Int] = []
        
        let formats = [
            // SQL / DB Formats (Often UTC)
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            
            // ISO 8601 Variants
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            
            // Simple Date
            "yyyy-MM-dd"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        for place in places {
            // 1. Prefer explicit hour if available
            if let h = place.hour {
                hours.append(h)
                continue
            }
            
            // 2. Fallback to parsing created_at or time
            var date: Date?
            
            if let createdAt = place.created_at {
                // Try ISO8601 first
                if let d = isoFormatter.date(from: createdAt) {
                    date = d
                } else {
                    // Try various formats
                    for format in formats {
                        formatter.dateFormat = format
                        if let d = formatter.date(from: createdAt) {
                            date = d
                            break
                        }
                    }
                }
            }
            
            // Fallback to time string if created_at failed
            if date == nil {
                if let timeStr = place.time {
                    let verboseF = DateFormatter()
                    verboseF.dateFormat = "EEEE, MMMM d, h:mm a"
                    verboseF.locale = Locale(identifier: "en_US_POSIX")
                    if let vDate = verboseF.date(from: timeStr) {
                        date = vDate
                    } else {
                        let timeF = DateFormatter()
                        timeF.dateFormat = "h:mm a"
                        timeF.locale = Locale(identifier: "en_US_POSIX")
                        if let tDate = timeF.date(from: timeStr) {
                            date = tDate
                        }
                    }
                }
            }
            
            if let validDate = date {
                let hour = Calendar.current.component(.hour, from: validDate)
                hours.append(hour)
            }
        }
        return hours
    }
}

// Helpers
extension DateFormatter {
    static let yyyyMMddHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
}
