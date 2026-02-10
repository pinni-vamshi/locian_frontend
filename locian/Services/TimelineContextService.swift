//
//  TimelineContextService.swift
//  locian
//
//  Centralized service for extracting contextual information from timeline data
//  Uses historical patterns based on frequency (Most Common) and proximity (Nearest Date)
//

import Foundation
import Combine

class TimelineContextService {
    static let shared = TimelineContextService()
    
    // Config
    private let lookbackDays = 5
    private let timeWindowMinutes = 60
    private let maxPastPlaces = 2
    private let maxFuturePlaces = 1
    
    // Simple Date Formatter reuse
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private init() {}
    
    /// Extract past and future places from timeline data based on current context time
    /// - Parameters:
    ///   - places: Flat list of MicroSituationData
    ///   - inputTime: The anchor time provided by the API (e.g. "3:00 PM")
    ///   - currentTime: Fallback for now if inputTime is missing
    func getContext(places: [MicroSituationData], inputTime: String? = nil, currentTime: Date = Date()) -> TimelineContext {
        guard !places.isEmpty else {
            return .empty
        }
        
        // 1. Determine the Anchor Minutes
        var anchorMinutes = currentTime.minutesFromMidnight
        if let it = inputTime {
             let itMinutes = parseTimeMinutes(from: it)
             if itMinutes > 0 {
                 anchorMinutes = itMinutes
                 print("   ⚓️ [TimelineContextService] Using API inputTime as anchor: '\(it)' (\(anchorMinutes) mins)")
             }
        } else {
             print("   ⚓️ [TimelineContextService] No inputTime provided. Using clock: \(anchorMinutes) mins")
        }
        
        print("\n🧠 [TimelineContextService] Starting Semantic Vibe Analysis")
        print("   - Total Candidates: \(places.count)")
        
        // 2. Split into Past and Future pools based on anchor time
        // Note: This split happens across all days in the input pool!
        let pastPool = places.filter { ($0.timeMinutes ?? 0) < anchorMinutes }
        let futurePool = places.filter { ($0.timeMinutes ?? 0) >= anchorMinutes }
        
        print("   - Past Pool: \(pastPool.count) items")
        print("   - Future Pool: \(futurePool.count) items")
        
        // 3. Rank Pools by "Vibe Score" (Semantic Centrality)
        let rankedPast = rankByVibe(pool: pastPool, label: "PAST").prefix(maxPastPlaces)
        let rankedFuture = rankByVibe(pool: futurePool, label: "FUTURE").prefix(maxFuturePlaces)
        
        let pastLeader = rankedPast.first
        let futureLeader = rankedFuture.first
        
        // 4. Convert ranked results to PlaceAtTime format
        let pastAtTime = rankedPast.compactMap { $0.toPlaceAtTime(currentTime: anchorMinutes) }
        let futureAtTime = rankedFuture.compactMap { $0.toPlaceAtTime(currentTime: anchorMinutes) }
        
        // 5. Build Result
        let result = TimelineContext(
            pastPlaces: Array(pastAtTime),
            futurePlaces: Array(futureAtTime),
            mostCommonPastPlace: pastLeader?.place_name,
            mostCommonFuturePlace: futureLeader?.place_name,
            nearestPastPlace: pastLeader?.toPlaceAtTime(currentTime: anchorMinutes),
            nearestFuturePlace: futureLeader?.toPlaceAtTime(currentTime: anchorMinutes)
        )
        
        print("   📊 [TimelineContext] Final Selection: Past \(result.pastPlaces.count), Future \(result.futurePlaces.count)")
        if let pl = pastLeader { print("   ✅ [Vibe] Selected PAST Leader: '\(pl.place_name ?? "??")' at \(pl.time ?? "??")") }
        if let fl = futureLeader { print("   ✅ [Vibe] Selected FUTURE Leader: '\(fl.place_name ?? "??")' at \(fl.time ?? "??")") }
        
        return result
    }
    
    // MARK: - internal Logic
    
    private func parseTimeMinutes(from t: String) -> Int {
        let parts = t.replacingOccurrences(of: " AM", with: "").replacingOccurrences(of: " PM", with: "").split(separator: ":").compactMap { Int($0) }
        guard parts.count >= 2 else { return 0 }
        var h = parts[0]
        if t.contains("PM") && h < 12 { h += 12 }
        if t.contains("AM") && h == 12 { h = 0 }
        return h * 60 + parts[1]
    }
    
    private func rankByVibe(pool: [MicroSituationData], label: String) -> [MicroSituationData] {
        guard !pool.isEmpty else { return [] }
        if pool.count == 1 { return pool }
        
        print("   🧠 [Vibe] Ranking \(label) pool (\(pool.count) items) by semantic centrality...")
        
        var scores: [(MicroSituationData, Double)] = []
        
        for i in 0..<pool.count {
            let m1 = pool[i]
            guard let v1 = m1.micro_situations?.first?.moments.first?.embedding else {
                scores.append((m1, 0.0))
                continue
            }
            
            var totalSimilarity = 0.0
            var comparisonCount = 0
            
            for j in 0..<pool.count {
                if i == j { continue }
                let m2 = pool[j]
                guard let v2 = m2.micro_situations?.first?.moments.first?.embedding else { continue }
                
                let sim = cosineSimilarity(v1, v2)
                totalSimilarity += sim
                comparisonCount += 1
            }
            
            let avgSim = comparisonCount > 0 ? (totalSimilarity / Double(comparisonCount)) : 0.0
            scores.append((m1, avgSim))
        }
        
        // Sort descending by score
        let ranked = scores.sorted { $0.1 > $1.1 }.map { $0.0 }
        return ranked
    }
    
    private func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0.0 }
        var dotProduct = 0.0
        var magA = 0.0
        var magB = 0.0
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            magA += a[i] * a[i]
            magB += b[i] * b[i]
        }
        let mag = sqrt(magA) * sqrt(magB)
        return mag > 0 ? dotProduct / mag : 0.0
    }
}

// MARK: - Helpers

extension TimelineContext {
    static let empty = TimelineContext(
        pastPlaces: [],
        futurePlaces: [],
        mostCommonPastPlace: nil,
        mostCommonFuturePlace: nil,
        nearestPastPlace: nil,
        nearestFuturePlace: nil
    )
}

fileprivate extension Date {
    var minutesFromMidnight: Int {
        let cal = Calendar.current
        let h = cal.component(.hour, from: self)
        let m = cal.component(.minute, from: self)
        return h * 60 + m
    }
}

fileprivate extension MicroSituationData {
    var timeMinutes: Int? {
        if let h = hour { return h * 60 }
        guard let t = time else { return nil }
        // Handle "HH:mm" or "h:mm a"
        let parts = t.replacingOccurrences(of: " AM", with: "").replacingOccurrences(of: " PM", with: "").split(separator: ":").compactMap { Int($0) }
        guard parts.count >= 2 else { return nil }
        var h = parts[0]
        if t.contains("PM") && h < 12 { h += 12 }
        if t.contains("AM") && h == 12 { h = 0 }
        return h * 60 + parts[1]
    }
    
    func toPlaceAtTime(currentTime: Int) -> PlaceAtTime? {
        guard let name = place_name, let tm = timeMinutes else { return nil }
        return PlaceAtTime(
            placeName: name,
            time: time ?? "00:00",
            date: String(created_at?.prefix(10) ?? "--"),
            timeDifference: abs(tm - currentTime),
            originalHour: hour
        )
    }
}
