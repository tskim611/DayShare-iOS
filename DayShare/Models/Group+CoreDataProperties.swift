//
//  Group+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

extension Group {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    // Identity
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var emoji: String?

    // Settings
    @NSManaged public var maxMembers: Int16
    @NSManaged public var isArchived: Bool

    // Metadata
    @NSManaged public var createdBy: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var lastActivityAt: Date?

    // Invite
    @NSManaged public var inviteCode: String?
    @NSManaged public var inviteExpiresAt: Date?

    // Relationships
    @NSManaged public var memberships: NSSet?
    @NSManaged public var shares: NSSet?
    @NSManaged public var helpRequests: NSSet?
}

extension Group: Identifiable {
}
