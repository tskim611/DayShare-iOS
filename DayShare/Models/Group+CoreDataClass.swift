//
//  Group+CoreDataClass.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(Group)
public class Group: NSManagedObject {
    // Helper to get active members
    var activeMembers: [GroupMembership] {
        let set = memberships as? Set<GroupMembership> ?? []
        return Array(set).filter { $0.isActive }.sorted {
            $0.joinedAt ?? Date.distantPast < $1.joinedAt ?? Date.distantPast
        }
    }

    var confirmedShares: [Share] {
        let set = shares as? Set<Share> ?? []
        return Array(set).filter { $0.status == "confirmed" && !$0.isDeleted }
    }

    // Calculate total time exchanged in this group
    var totalTimeExchanged: TimeInterval {
        return confirmedShares.reduce(0) { $0 + $1.duration }
    }

    // Get balance summary for all members
    func balanceSummary() -> [(user: User, balance: TimeInterval)] {
        return activeMembers.compactMap { membership in
            guard let user = membership.user else { return nil }
            return (user, user.balance(in: self))
        }.sorted { $0.balance > $1.balance }
    }

    // Check if invite is still valid
    var isInviteValid: Bool {
        guard let expiresAt = inviteExpiresAt else { return false }
        return Date() < expiresAt
    }

    // Generate a new invite code
    func generateInviteCode() {
        self.inviteCode = UUID().uuidString.prefix(8).uppercased().description
        self.inviteExpiresAt = Date().addingTimeInterval(24 * 60 * 60) // 24 hours
    }
}
