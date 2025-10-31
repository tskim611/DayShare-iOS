//
//  User+CoreDataProperties.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import CoreData

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    // Identity
    @NSManaged public var id: UUID?
    @NSManaged public var nickname: String?
    @NSManaged public var avatarEmoji: String?

    // Authentication
    @NSManaged public var authProvider: String?
    @NSManaged public var authProviderID: String?

    // Preferences
    @NSManaged public var language: String?
    @NSManaged public var notificationsEnabled: Bool

    // Premium
    @NSManaged public var isPremium: Bool
    @NSManaged public var premiumPurchaseDate: Date?

    // Metadata
    @NSManaged public var createdAt: Date?
    @NSManaged public var lastActiveAt: Date?

    // Relationships
    @NSManaged public var memberships: NSSet?
    @NSManaged public var sharesGiven: NSSet?
    @NSManaged public var sharesReceived: NSSet?
    @NSManaged public var requestsCreated: NSSet?
    @NSManaged public var notifications: NSSet?
    @NSManaged public var activityLogs: NSSet?
}

// MARK: Generated accessors for memberships
extension User {
    @objc(addMembershipsObject:)
    @NSManaged public func addToMemberships(_ value: GroupMembership)

    @objc(removeMembershipsObject:)
    @NSManaged public func removeFromMemberships(_ value: GroupMembership)

    @objc(addMemberships:)
    @NSManaged public func addToMemberships(_ values: NSSet)

    @objc(removeMemberships:)
    @NSManaged public func removeFromMemberships(_ values: NSSet)
}

// MARK: Generated accessors for sharesGiven
extension User {
    @objc(addSharesGivenObject:)
    @NSManaged public func addToSharesGiven(_ value: Share)

    @objc(removeSharesGivenObject:)
    @NSManaged public func removeFromSharesGiven(_ value: Share)

    @objc(addSharesGiven:)
    @NSManaged public func addToSharesGiven(_ values: NSSet)

    @objc(removeSharesGiven:)
    @NSManaged public func removeFromSharesGiven(_ values: NSSet)
}

// MARK: Generated accessors for sharesReceived
extension User {
    @objc(addSharesReceivedObject:)
    @NSManaged public func addToSharesReceived(_ value: Share)

    @objc(removeSharesReceivedObject:)
    @NSManaged public func removeFromSharesReceived(_ value: Share)

    @objc(addSharesReceived:)
    @NSManaged public func addToSharesReceived(_ values: NSSet)

    @objc(removeSharesReceived:)
    @NSManaged public func removeFromSharesReceived(_ values: NSSet)
}

extension User: Identifiable {
}
