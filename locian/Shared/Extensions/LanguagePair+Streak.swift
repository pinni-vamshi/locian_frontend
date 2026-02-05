import Foundation

extension LanguagePair {
    /// Calculates the longest streak of consecutive days from the practice dates.
    var calculatedLongestStreak: Int {
        guard !practice_dates.isEmpty else { return 0 }
        
        // 1. Parse dates using the specific format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let validDates = practice_dates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        
        // 2. Sort dates and remove duplicates (using Set)
        let uniqueDates = Set(validDates)
        let sortedDates = uniqueDates.sorted()
        
        // 3. Calculate streak
        var maxStreak = 1
        var currentStreak = 1
        let calendar = Calendar.current
        
        for i in 0..<(sortedDates.count - 1) {
            let currentDate = sortedDates[i]
            let nextDate = sortedDates[i + 1]
            
            // Check if nextDate is exactly 1 day after currentDate
            if let dayAfter = calendar.date(byAdding: .day, value: 1, to: currentDate),
               calendar.isDate(dayAfter, inSameDayAs: nextDate) {
                currentStreak += 1
            } else {
                // Streak broken
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
        }
        
        // Final check
        maxStreak = max(maxStreak, currentStreak)
        
        return maxStreak
    }
    
    /// Calculates the current active streak.
    /// Streak is valid if the last practice was Today or Yesterday.
    var calculatedCurrentStreak: Int {
        guard !practice_dates.isEmpty else { return 0 }
        
        // 1. Parse dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let validDates = practice_dates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        
        let uniqueDates = Set(validDates)
        let sortedDates = uniqueDates.sorted(by: >) // Descending (Newest first)
        
        let calendar = Calendar.current
        let today = Date()
        
        guard let latestDate = sortedDates.first else { return 0 }
        
        // 2. Check if streak is alive (Last practice must be Today or Yesterday)
        let isToday = calendar.isDateInToday(latestDate)
        let isYesterday = calendar.isDate(latestDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        
        if !isToday && !isYesterday {
            return 0
        }
        
        // 3. Count backwards
        var currentStreak = 1
        var previousDate = latestDate
        
        for i in 1..<sortedDates.count {
            let date = sortedDates[i]
            
            if let expectedPrevDay = calendar.date(byAdding: .day, value: -1, to: previousDate),
               calendar.isDate(date, inSameDayAs: expectedPrevDay) {
                currentStreak += 1
                previousDate = date
            } else {
                break
            }
        }
        
        return currentStreak
    }
}
