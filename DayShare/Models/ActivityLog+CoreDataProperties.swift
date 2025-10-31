//
//  ActivityLog+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

@objc(ActivityLog)
public class ActivityLog: NSManagedObject {
}

extension ActivityLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityLog> {
        return NSFetchRequest<ActivityLog>(entityName: "ActivityLog")
    }

    // Identity
    @NSManaged public var id: UUID?

    // Who
    @NSManaged public var userId: UUID?

    // What
    @NSManaged public var action: String?
    @NSManaged public var entityType: String?
    @NSManaged public var entityId: UUID?

    // Metadata
    @NSManaged public var timestamp: Date?
    @NSManaged public var ipAddress: String?
    @NSManaged public var deviceInfo: String?

    // Relationships
    @NSManaged public var user: User?
}

extension ActivityLog: Identifiable {
}
