//
//  Color+Extensions.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors (from DayShare-Brand-Identity.md)

    /// Primary: Warm Amber - Kindness, not transactional
    static let brandPrimary = Color(hex: "F6B352")

    /// Accent: Soft Teal - Trust, balance
    static let brandAccent = Color(hex: "4ECDC4")

    /// Gratitude Gold - For thank you notes and positive moments
    static let gratitudeGold = Color(hex: "FFD700")

    /// Balance Green - For balanced states
    static let balanceGreen = Color(hex: "81C784")

    /// Gentle Reminder Coral - For soft nudges (never harsh)
    static let gentleReminder = Color(hex: "FF8A80")

    // MARK: - Hex Initializer

    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "F6B352" or "#F6B352")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Adaptive Colors

    /// Returns appropriate color based on balance value
    /// - Parameter balance: Time interval balance
    /// - Returns: Green for positive, coral for negative, gray for neutral
    static func forBalance(_ balance: TimeInterval) -> Color {
        if balance > 3600 {
            return .balanceGreen
        } else if balance < -3600 {
            return .gentleReminder
        } else {
            return .gray
        }
    }
}
