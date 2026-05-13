//
//  LearnAmbientTagline.swift
//  locian
//
//  Second-line Learn tab copy driven by time-of-day plus rain / velocity / altitude.
//  All strings live here; callers build LearnAmbientInputs from sensors.
//

import Foundation

// MARK: - Inputs

enum LearnTimeBand: Equatable {
    case day
    case night
    case lateNight
}

struct LearnAmbientInputs: Equatable {
    var time: LearnTimeBand
    var rain: Bool
    var velocity: Bool
    var altitude: Bool
}

// MARK: - Resolver + copy

enum LearnAmbientTagline {

    /// Clock buckets (no brightness sensor): late night after midnight, evening/night, daytime.
    static func timeBand(for date: Date = Date()) -> LearnTimeBand {
        let hour = Calendar.current.component(.hour, from: date)
        if hour >= 0 && hour < 5 { return .lateNight }
        if hour >= 19 && hour <= 23 { return .night }
        return .day
    }

    /// Pick one line: strongest combined signal wins (rain+velocity+altitude → triples → pairs → time-only baselines).
    static func line(for inputs: LearnAmbientInputs) -> String {
        let t = inputs.time
        let r = inputs.rain
        let v = inputs.velocity
        let a = inputs.altitude

        if r && v && a {
            return tripleRainVelocityAltitudeAll
        }
        if r && v {
            return pairRainVelocity[t] ?? baseline(t)
        }
        if r && a {
            return pairRainAltitude[t] ?? baseline(t)
        }
        if v && a {
            return pairVelocityAltitude[t] ?? baseline(t)
        }
        if r {
            return pairRain[t] ?? baseline(t)
        }
        if v {
            return pairVelocity[t] ?? baseline(t)
        }
        if a {
            return pairAltitude[t] ?? baseline(t)
        }
        return baseline(t)
    }

    // MARK: Baselines (time only)

    private static func baseline(_ t: LearnTimeBand) -> String {
        switch t {
        case .day: return baselineDay
        case .night: return baselineNight
        case .lateNight: return baselineLateNight
        }
    }

    private static let baselineDay = "Learn the world as you walk it."
    private static let baselineNight = "Night holds words you haven't met."
    private static let baselineLateNight = "Still awake. Still ahead."

    // MARK: Rain · Velocity · Altitude (all three)

    private static let tripleRainVelocityAltitudeAll =
        "Wet, fast, thin air — one word at a time."

    // MARK: Pairs: Rain × time

    private static let pairRain: [LearnTimeBand: String] = [
        .day: "Rain dulls the street — words cut through.",
        .night: "Night rain — listen tighter.",
        .lateNight: "Late rain — whisper-practice weather."
    ]

    // MARK: Pairs: Velocity × time

    private static let pairVelocity: [LearnTimeBand: String] = [
        .day: "Fast pace — more sound slips by.",
        .night: "Night rush — trust what repeats.",
        .lateNight: "Late rush — keep one phrase."
    ]

    // MARK: Pairs: Altitude × time

    private static let pairAltitude: [LearnTimeBand: String] = [
        .day: "High up — thin air, clear words.",
        .night: "Thin cold night — sharp syllables.",
        .lateNight: "High and late — stay sharp."
    ]

    // MARK: Two modifiers + time (rain + velocity)

    private static let pairRainVelocity: [LearnTimeBand: String] = [
        .day: "Wet hurry — hold one line.",
        .night: "Rain and speed — ride the beat.",
        .lateNight: "Wet late sprint — one loop only."
    ]

    // MARK: Rain + altitude

    private static let pairRainAltitude: [LearnTimeBand: String] = [
        .day: "High grey rain — vowels stay clean.",
        .night: "Storm height — sounds strip bare.",
        .lateNight: "Late peak rain — quiet edges."
    ]

    // MARK: Velocity + altitude

    private static let pairVelocityAltitude: [LearnTimeBand: String] = [
        .day: "Uphill hurry — breathe narrow.",
        .night: "Fast climb — rhythm survives.",
        .lateNight: "Thin-air sprint — words linger."
    ]
}
