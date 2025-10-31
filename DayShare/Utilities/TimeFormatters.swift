//
//  TimeFormatters.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation

struct TimeFormatters {
    // MARK: - Duration Formatting

    /// Formats time interval into Korean-friendly duration string
    /// Example: 3665 seconds → "1시간 1분"
    static func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "0분"
        }
    }

    /// Formats time interval into short duration string
    /// Example: 3600 seconds → "1h"
    static func formatDurationShort(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    /// Converts duration to hours with decimal
    /// Example: 3600 seconds → 1.0
    static func durationInHours(_ interval: TimeInterval) -> Double {
        return interval / 3600.0
    }

    // MARK: - Date Formatting

    /// Formats date relative to today (Korean-friendly)
    /// Example: Today → "오늘", Yesterday → "어제", Older → "12월 25일"
    static func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "M월 d일"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        }
    }

    /// Formats datetime with time
    /// Example: "12월 25일 오후 2:30"
    static func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    /// Formats time only
    /// Example: "오후 2:30"
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    // MARK: - Balance Formatting

    /// Formats balance with gentle language (no negative connotation)
    static func formatBalance(_ balance: TimeInterval) -> String {
        let hours = Int(abs(balance) / 3600)

        if balance > 0 {
            return "+\(hours)시간"
        } else if balance < 0 {
            return "\(hours)시간" // No minus sign, less confrontational
        } else {
            return "균형"
        }
    }

    /// Descriptive balance text (gentle, non-judgmental)
    static func balanceDescription(_ balance: TimeInterval) -> String {
        let hours = abs(balance) / 3600

        if balance > 3600 {
            return "최근 많이 도와주셨어요"
        } else if balance < -3600 {
            return "도움 줄 차례예요"
        } else {
            return "서로 잘 나누고 있어요"
        }
    }
}
