//
//  Share+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(Share)
public class Share: NSManagedObject {
}

extension Share {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Share> {
        return NSFetchRequest<Share>(entityName: "Share")
    }

    // Identity
    @NSManaged public var id: UUID?

    // Who and Where
    @NSManaged public var groupId: UUID?
    @NSManaged public var giverUserId: UUID?
    @NSManaged public var receiverUserId: UUID?

    // What
    @NSManaged public var shareDescription: String?
    @NSManaged public var category: String?

    // When
    @NSManaged public var occurredAt: Date?
    @NSManaged public var duration: TimeInterval

    // Status
    @NSManaged public var status: String?
    @NSManaged public var confirmedAt: Date?
    @NSManaged public var confirmedBy: UUID?

    // Thank you note
    @NSManaged public var thankYouNote: String?

    // Metadata
    @NSManaged public var createdAt: Date?
    @NSManaged public var createdBy: UUID?
    @NSManaged public var updatedAt: Date?

    // Soft delete
    @NSManaged public var isDeleted: Bool
    @NSManaged public var deletedAt: Date?

    // Relationships
    @NSManaged public var group: Group?
    @NSManaged public var giver: User?
    @NSManaged public var receiver: User?

    // Computed properties
    var isPending: Bool {
        return status == "pending"
    }

    var isConfirmed: Bool {
        return status == "confirmed"
    }

    var durationInHours: Double {
        return duration / 3600.0
    }
}

extension Share: Identifiable {
}
