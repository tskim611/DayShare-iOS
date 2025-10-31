//
//  HelpRequest+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(HelpRequest)
public class HelpRequest: NSManagedObject {
}

extension HelpRequest {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HelpRequest> {
        return NSFetchRequest<HelpRequest>(entityName: "HelpRequest")
    }

    // Identity
    @NSManaged public var id: UUID?

    // Who and Where
    @NSManaged public var groupId: UUID?
    @NSManaged public var requesterId: UUID?

    // What
    @NSManaged public var requestDescription: String?
    @NSManaged public var estimatedDuration: TimeInterval

    // When
    @NSManaged public var neededBy: Date?

    // Status
    @NSManaged public var status: String?
    @NSManaged public var claimedBy: UUID?
    @NSManaged public var claimedAt: Date?
    @NSManaged public var completedAt: Date?

    // Metadata
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    // Linked Share
    @NSManaged public var resultingShareId: UUID?

    // Relationships
    @NSManaged public var group: Group?
    @NSManaged public var requester: User?
    @NSManaged public var resultingShare: Share?

    // Computed properties
    var isOpen: Bool {
        return status == "open"
    }

    var isClaimed: Bool {
        return status == "claimed"
    }

    var isCompleted: Bool {
        return status == "completed"
    }

    var isCancelled: Bool {
        return status == "cancelled"
    }
}

extension HelpRequest: Identifiable {
}
