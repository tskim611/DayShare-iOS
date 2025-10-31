//
//  GroupMembership+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(GroupMembership)
public class GroupMembership: NSManagedObject {
}

extension GroupMembership {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupMembership> {
        return NSFetchRequest<GroupMembership>(entityName: "GroupMembership")
    }

    // Identity
    @NSManaged public var id: UUID?

    // Relationships
    @NSManaged public var userId: UUID?
    @NSManaged public var groupId: UUID?

    // Role
    @NSManaged public var role: String?

    // Display
    @NSManaged public var displayName: String?

    // Status
    @NSManaged public var isActive: Bool
    @NSManaged public var joinedAt: Date?
    @NSManaged public var leftAt: Date?

    // Relationships
    @NSManaged public var user: User?
    @NSManaged public var group: Group?

    // Computed properties
    var isCreator: Bool {
        return role == "creator"
    }
}

extension GroupMembership: Identifiable {
}
