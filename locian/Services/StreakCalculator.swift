//
//  StreakCalculator.swift
//  locian
//
//  Created for streak calculation logic
//

import Foundation

class StreakCalculator {
    static let shared = StreakCalculator()
    
    private init() {}
    
    // Calculate continuous streak from today backwards (resets at 11:59 PM if no practice that day)
    func calculateStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else {
            return 0
        }
        
        let calendar = Calendar.current
        let now = Date()
        // Use calendar's start of day to ensure correct timezone handling
        let today = calendar.startOfDay(for: now)
        
        // Check current time - if it's before 11:59 PM, we can still count today
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let isBefore1159PM = hour < 23 || (hour == 23 && minute < 59)
        
        // Parse dates and get unique days
        // API returns dates in "yyyy-MM-dd" format (e.g., "2025-12-13")
        // Also support old format "EEEE, MMMM d, h:mm a" for backward compatibility
        let apiDateFormatter = DateFormatter()
        apiDateFormatter.dateFormat = "yyyy-MM-dd"
        apiDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let oldDateFormatter = DateFormatter()
        oldDateFormatter.dateFormat = "EEEE, MMMM d, h:mm a"
        oldDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var parsedDates: [Date] = []
        let currentYear = calendar.component(.year, from: now)
        
        for dateString in practiceDates {
            var date: Date?
            
            // Try API format first (yyyy-MM-dd)
            if let parsedDate = apiDateFormatter.date(from: dateString) {
                date = parsedDate
            } else if let parsedDate = oldDateFormatter.date(from: dateString) {
                // Try old format (EEEE, MMMM d, h:mm a)
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: parsedDate)
                components.year = currentYear
                date = calendar.date(from: components)
            }
            
            if let finalDate = date {
                parsedDates.append(finalDate)
            } else {
            }
        }
        
        // Normalize all dates to start of day for comparison
        let dates = parsedDates.map { calendar.startOfDay(for: $0) }
        
        // Get unique days only
        let uniqueDays = Set(dates)
        
        guard !uniqueDays.isEmpty else {
            return 0
        }
        
        // Determine the reference day for streak calculation
        // If before 11:59 PM, check if practiced today OR yesterday
        // If after 11:59 PM, only count if practiced today
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Determine starting day for streak count
        var startDay: Date
        
        // Check if today or yesterday matches any unique day
        let todayMatches = uniqueDays.contains(today)
        let yesterdayMatches = uniqueDays.contains(yesterday)
        
        if isBefore1159PM {
            // Before 11:59 PM - can count today or yesterday
            if todayMatches {
                startDay = today
            } else if yesterdayMatches {
                startDay = yesterday
            } else {
                // No practice today or yesterday - streak is 0
                return 0
            }
        } else {
            // After 11:59 PM - must have practiced today
            if todayMatches {
                startDay = today
            } else {
                // No practice today - streak is 0
                return 0
            }
        }
        
        // Count consecutive days backwards from start day
        // If any day is missing, streak resets to zero
        var streak = 0
        var currentDay = startDay
        
        // Count backwards day by day
        for _ in 0..<365 { // Check up to 1 year back
            if uniqueDays.contains(currentDay) {
                streak += 1
                // Move to previous day
                currentDay = calendar.date(byAdding: .day, value: -1, to: currentDay)!
            } else {
                // Gap found - streak is broken
                break
            }
        }
        return streak
    }
    
    // Calculate the longest streak from all practice dates (historical maximum)
    func calculateLongestStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else {
            return 0
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // API returns dates in "yyyy-MM-dd" format (e.g., "2025-12-13")
        // Also support old format "EEEE, MMMM d, h:mm a" for backward compatibility
        let apiDateFormatter = DateFormatter()
        apiDateFormatter.dateFormat = "yyyy-MM-dd"
        apiDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let oldDateFormatter = DateFormatter()
        oldDateFormatter.dateFormat = "EEEE, MMMM d, h:mm a"
        oldDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var parsedDates: [Date] = []
        let currentYear = calendar.component(.year, from: now)
        
        for dateString in practiceDates {
            var date: Date?
            
            // Try API format first (yyyy-MM-dd)
            if let parsedDate = apiDateFormatter.date(from: dateString) {
                date = parsedDate
            } else if let parsedDate = oldDateFormatter.date(from: dateString) {
                // Try old format (EEEE, MMMM d, h:mm a)
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: parsedDate)
                components.year = currentYear
                date = calendar.date(from: components)
            }
            
            if let finalDate = date {
                parsedDates.append(finalDate)
            } else {
            }
        }
        
        // Normalize all dates to start of day
        let dates = parsedDates.map { calendar.startOfDay(for: $0) }
        let uniqueDays = Array(Set(dates)).sorted()
        
        guard !uniqueDays.isEmpty else {
            return 0
        }
        
        // Find the longest consecutive sequence
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<uniqueDays.count {
            if let daysBetween = calendar.dateComponents([.day], from: uniqueDays[i-1], to: uniqueDays[i]).day,
               daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                // Gap found, reset current streak
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    // Calculate Consistency Score using logarithmic growth and exponential decay
    // Score = (Alpha * Log(Streak + 1)) + (Beta * Density) + (Gamma * Momentum)
    func calculateConsistencyScore(practiceDates: [String]) -> Double {
        guard !practiceDates.isEmpty else { return 0.0 }
        
        let dates = parseDates(practiceDates).sorted()
        guard let firstDate = dates.first else { return 0.0 }
        
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // 1. Logarithmic term for Current Streak (diminishing returns for massive streaks, high initial boost)
        let currentStreak = Double(calculateStreak(practiceDates: practiceDates))
        // Limit log factor to ~1.0 at 365 days. ln(365) ≈ 5.9.
        let streakFactor = min(log(currentStreak + 1) / log(30.0 + 1), 1.0) // Normalized around 30 days for "full" streak score
        
        // 2. Density (Total Practice / Total Time)
        // Ensure at least 1 day duration
        let totalDays = max(1.0, Double(calendar.dateComponents([.day], from: firstDate, to: today).day ?? 1))
        let practiceCount = Double(dates.count)
        let density = min(practiceCount / totalDays, 1.0)
        
        // 3. Momentum (Exponential Decay Sum)
        // Recent days count more. Sum[e^(-0.3 * days_ago) * (practiced ? 1 : 0)]
        var momentumSum = 0.0
        var maxMomentum = 0.0
        let decayRate = 0.3 // Decays to ~5% impact after 10 days
        
        for i in 0..<14 { // Look back 2 weeks
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let weight = exp(-decayRate * Double(i))
                maxMomentum += weight
                
                // Check if practiced on this date
                if dates.contains(date) {
                    momentumSum += weight
                }
            }
        }
        let momentum = maxMomentum > 0 ? momentumSum / maxMomentum : 0.0
        
        // Weighted Combination
        // Streak: 30%, Density: 30%, Momentum: 40% (Momentum is key for "Consistency")
        let wStreak = 0.3
        let wDensity = 0.3
        let wMomentum = 0.4
        
        let score = (wStreak * streakFactor) + (wDensity * density) + (wMomentum * momentum)
        
        // Return percentage (0-100)
        return min(max(score * 100.0, 0.0), 100.0)
    }
    
    // Suggest next milestone based on current streak
    func getNextMilestone(currentStreak: Int) -> Int {
        let milestones = [3, 5, 7, 10, 14, 21, 30, 45, 60, 90, 100, 150, 200, 300, 365]
        for m in milestones {
            if currentStreak < m {
                return m
            }
        }
        return currentStreak + 30 // Fallback
    }
    
    // Private helper to parse dates consistently
    private func parseDates(_ practiceDates: [String]) -> [Date] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        let apiDateFormatter = DateFormatter()
        apiDateFormatter.dateFormat = "yyyy-MM-dd"
        apiDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let oldDateFormatter = DateFormatter()
        oldDateFormatter.dateFormat = "EEEE, MMMM d, h:mm a"
        oldDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var dates: [Date] = []
        
        for dateString in practiceDates {
            if let date = apiDateFormatter.date(from: dateString) {
                dates.append(calendar.startOfDay(for: date))
            } else if let parsedDate = oldDateFormatter.date(from: dateString) {
                var components = calendar.dateComponents([.year, .month, .day], from: parsedDate)
                components.year = currentYear
                if let date = calendar.date(from: components) {
                    dates.append(calendar.startOfDay(for: date))
                }
            }
        }
        return Array(Set(dates)).sorted() // Unique start-of-day dates
    }
    // Calculate total unique practice days (for Total Time Recorded)
    func calculateUniqueDays(practiceDates: [String]) -> Int {
        let dates = parseDates(practiceDates)
        return dates.count
    }
}

