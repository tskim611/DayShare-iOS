//
//  User+CoreDataClass.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    // Computed property for balance in a specific group
    func balance(in group: Group) -> TimeInterval {
        guard let groupId = group.id else { return 0 }

        let sharesGiven = sharesGivenArray.filter {
            $0.groupId == groupId && $0.status == "confirmed" && !$0.isDeleted
        }
        let sharesReceived = sharesReceivedArray.filter {
            $0.groupId == groupId && $0.status == "confirmed" && !$0.isDeleted
        }

        let totalGiven = sharesGiven.reduce(0) { $0 + $1.duration }
        let totalReceived = sharesReceived.reduce(0) { $0 + $1.duration }

        return totalGiven - totalReceived
    }

    // Helper to convert NSSet to Array
    var sharesGivenArray: [Share] {
        let set = sharesGiven as? Set<Share> ?? []
        return Array(set)
    }

    var sharesReceivedArray: [Share] {
        let set = sharesReceived as? Set<Share> ?? []
        return Array(set)
    }

    var membershipsArray: [GroupMembership] {
        let set = memberships as? Set<GroupMembership> ?? []
        return Array(set).sorted { $0.joinedAt ?? Date.distantPast > $1.joinedAt ?? Date.distantPast }
    }

    var activeGroups: [Group] {
        return membershipsArray
            .filter { $0.isActive }
            .compactMap { $0.group }
    }
}
