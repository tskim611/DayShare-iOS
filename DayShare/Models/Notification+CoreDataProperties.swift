//
//  Notification+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(Notification)
public class Notification: NSManagedObject {
}

extension Notification {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification")
    }

    // Identity
    @NSManaged public var id: UUID?

    // Who
    @NSManaged public var userId: UUID?

    // What
    @NSManaged public var type: String?
    @NSManaged public var title: String?
    @NSManaged public var body: String?

    // Context
    @NSManaged public var relatedEntityType: String?
    @NSManaged public var relatedEntityId: UUID?

    // Status
    @NSManaged public var isRead: Bool
    @NSManaged public var readAt: Date?

    // Metadata
    @NSManaged public var createdAt: Date?
    @NSManaged public var expiresAt: Date?

    // Relationships
    @NSManaged public var user: User?

    // Computed properties
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
}

extension Notification: Identifiable {
}
