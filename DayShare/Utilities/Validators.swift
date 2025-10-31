//
//  Validators.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation

struct Validators {
    // MARK: - Group Validation

    /// Validates group name
    static func validateGroupName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("그룹 이름을 입력해 주세요")
        }

        if trimmed.count < 2 {
            return .invalid("그룹 이름은 2자 이상이어야 합니다")
        }

        if trimmed.count > 30 {
            return .invalid("그룹 이름은 30자 이하여야 합니다")
        }

        return .valid
    }

    /// Validates invite code format
    static func validateInviteCode(_ code: String) -> ValidationResult {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if trimmed.count != 8 {
            return .invalid("초대 코드는 8자리여야 합니다")
        }

        let alphanumeric = CharacterSet.alphanumerics
        if trimmed.rangeOfCharacter(from: alphanumeric.inverted) != nil {
            return .invalid("초대 코드는 영문과 숫자만 포함해야 합니다")
        }

        return .valid
    }

    // MARK: - User Validation

    /// Validates nickname
    static func validateNickname(_ nickname: String) -> ValidationResult {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("닉네임을 입력해 주세요")
        }

        if trimmed.count < 2 {
            return .invalid("닉네임은 2자 이상이어야 합니다")
        }

        if trimmed.count > 15 {
            return .invalid("닉네임은 15자 이하여야 합니다")
        }

        // No special characters except Korean, English, numbers, spaces
        let allowed = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: " "))
            .union(CharacterSet(charactersIn: "가-힣ㄱ-ㅎㅏ-ㅣ"))

        if trimmed.rangeOfCharacter(from: allowed.inverted) != nil {
            return .invalid("닉네임에는 한글, 영문, 숫자만 사용할 수 있습니다")
        }

        return .valid
    }

    // MARK: - Share Validation

    /// Validates share description
    static func validateShareDescription(_ description: String) -> ValidationResult {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("어떤 도움이었는지 입력해 주세요")
        }

        if trimmed.count < 2 {
            return .invalid("최소 2자 이상 입력해 주세요")
        }

        if trimmed.count > 100 {
            return .invalid("100자 이하로 입력해 주세요")
        }

        return .valid
    }

    /// Validates duration (in seconds)
    static func validateDuration(_ duration: TimeInterval) -> ValidationResult {
        if duration <= 0 {
            return .invalid("시간을 입력해 주세요")
        }

        if duration > 86400 { // More than 24 hours
            return .invalid("24시간 이하로 입력해 주세요")
        }

        return .valid
    }

    // MARK: - Help Request Validation

    /// Validates help request description
    static func validateHelpRequestDescription(_ description: String) -> ValidationResult {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("무엇이 필요한지 입력해 주세요")
        }

        if trimmed.count < 5 {
            return .invalid("최소 5자 이상 입력해 주세요")
        }

        if trimmed.count > 200 {
            return .invalid("200자 이하로 입력해 주세요")
        }

        return .valid
    }

    // MARK: - Thank You Note Validation

    /// Validates thank you note (optional field, so more lenient)
    static func validateThankYouNote(_ note: String) -> ValidationResult {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .valid // Optional field
        }

        if trimmed.count > 150 {
            return .invalid("150자 이하로 입력해 주세요")
        }

        return .valid
    }
}

// MARK: - Validation Result

enum ValidationResult {
    case valid
    case invalid(String)

    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }

    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}
