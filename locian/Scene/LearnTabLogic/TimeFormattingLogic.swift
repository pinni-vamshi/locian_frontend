//
//  TimeFormattingLogic.swift
//  locian
//
//  Centralized logic for parsing and formatting relative time strings
//

import Foundation

struct TimeFormattingLogic {
    static let shared = TimeFormattingLogic()
    private init() {}

    func calculateTimeGap(hour: Int?, time: String?) -> String? {
        // 1. Prefer 'hour' integer if available (0-23)
        if let h = hour {
            let calendar = Calendar.current
            let now = Date()
            
            if let todayTarget = calendar.date(bySettingHour: h, minute: 0, second: 0, of: now) {
                var target = todayTarget
                if target < now {
                    if h < calendar.component(.hour, from: now) {
                        target = calendar.date(byAdding: .day, value: 1, to: target)!
                    }
                }
                
                let diff = target.timeIntervalSince(now)
                if diff > 0 {
                    let hrs = Int(diff) / 3600
                    let mins = (Int(diff) % 3600) / 60
                    return hrs > 0 ? "in \(hrs) hr \(mins) min" : "in \(mins) min"
                }
                return "Now"
            }
        }
        
        // 2. Fallback to parsing 'time' string (e.g., "3:30 PM")
        if let tStr = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = formatter.date(from: tStr) {
                let calendar = Calendar.current
                let now = Date()
                let components = calendar.dateComponents([.hour, .minute], from: date)
                
                if let target = calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: now) {
                    var adjustedTarget = target
                    if adjustedTarget < now {
                        if adjustedTarget.timeIntervalSince(now) < -12 * 3600 {
                            adjustedTarget = calendar.date(byAdding: .day, value: 1, to: adjustedTarget)!
                        }
                    }
                     
                    let diff = adjustedTarget.timeIntervalSince(now)
                    if diff > 0 {
                        let hrs = Int(diff) / 3600
                        let mins = (Int(diff) % 3600) / 60
                        return hrs > 0 ? "in \(hrs) hr \(mins) min" : "in \(mins) min"
                    }
                }
            }
        }
        return nil
    }

    func calculateTimeAgo(hour: Int?, createdAt: String?, time: String?) -> String? {
        let now = Date()
        let calendar = Calendar.current
        
        if let h = hour {
            if let todayTarget = calendar.date(bySettingHour: h, minute: 0, second: 0, of: now) {
                var target = todayTarget
                if target > now {
                    target = calendar.date(byAdding: .day, value: -1, to: target)!
                }
                let diff = now.timeIntervalSince(target)
                if diff > 0 {
                    let hrs = Int(diff) / 3600
                    let mins = (Int(diff) % 3600) / 60
                    if hrs > 24 { return "YESTERDAY" }
                    return hrs > 0 ? "\(hrs)H \(mins)M AGO" : "\(mins)M AGO"
                }
            }
        }
        
        guard let createdAt = createdAt else {
            return fallbackTimeParsing(now: now, time: time)
        }
        
        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSS", "yyyy-MM-dd HH:mm:ss.SSS", "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", "yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd"
        ]
        
        var parsedDate: Date?
        let utcFormatter = DateFormatter()
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        for format in formats {
            utcFormatter.dateFormat = format
            if let date = utcFormatter.date(from: createdAt) {
                parsedDate = date
                break
            }
        }
        
        if let date = parsedDate {
            let diff = now.timeIntervalSince(date)
            if diff > 0 {
                let hrs = Int(diff) / 3600
                let mins = (Int(diff) % 3600) / 60
                if hrs > 48 {
                    let displayF = DateFormatter()
                    displayF.dateFormat = "MMM d"
                    return displayF.string(from: date).uppercased()
                } else if hrs > 24 {
                    return "YESTERDAY"
                } else {
                    return hrs > 0 ? "\(hrs)H \(mins)M AGO" : "\(mins)M AGO"
                }
            }
            return "Just now"
        }
        
        return fallbackTimeParsing(now: now, time: time)
    }
    
    private func fallbackTimeParsing(now: Date, time: String?) -> String? {
        if let tStr = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = formatter.date(from: tStr) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: date)
                if let target = calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: now) {
                    var adjustedTarget = target
                    if adjustedTarget > now {
                        adjustedTarget = calendar.date(byAdding: .day, value: -1, to: adjustedTarget)!
                    }
                    let diff = now.timeIntervalSince(adjustedTarget)
                    if diff > 0 {
                        let hrs = Int(diff) / 3600
                        let mins = (Int(diff) % 3600) / 60
                        return hrs > 0 ? "\(hrs)H \(mins)M AGO" : "\(mins)M AGO"
                    }
                }
            }
            return tStr.uppercased()
        }
        return nil
    }
}
