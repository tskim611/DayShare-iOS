//
//  FirebaseService.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  NOTE: Currently running in LOCAL-ONLY mode (no Firebase connection)
//  All data is stored in CoreData only.
//

import Foundation

class FirebaseService {
    // MARK: - Singleton

    static let shared = FirebaseService()

    // MARK: - Properties

    // Local-only mode: Firebase disabled for now
    private var localUserId: String = "local-user-\(UUID().uuidString)"
    private var isLocalMode = true

    // MARK: - Initialization

    private init() {
        print("📱 FirebaseService: Running in LOCAL-ONLY mode")
        print("📱 All data stored in CoreData only")
    }

    // MARK: - Authentication

    func getCurrentUserId() -> String? {
        return localUserId
    }

    func isUserAuthenticated() -> Bool {
        return true // Always authenticated in local mode
    }

    // MARK: - Sync Methods (No-op in local mode)

    func syncUser(_ user: User) async throws {
        // Local mode: No sync needed
        print("📱 Local mode: User data stored in CoreData only")
    }

    func syncGroup(_ group: Group) async throws {
        // Local mode: No sync needed
        print("📱 Local mode: Group data stored in CoreData only")
    }

    func syncShare(_ share: Share) async throws {
        // Local mode: No sync needed
        print("📱 Local mode: Share data stored in CoreData only")
    }

    // MARK: - Fetch Methods

    func fetchGroups(for userId: String) async throws -> [String: Any] {
        // Local mode: Data comes from CoreData only
        return [:]
    }

    func fetchShares(for groupId: String) async throws -> [[String: Any]] {
        // Local mode: Data comes from CoreData only
        return []
    }

    // MARK: - Local Mode Info

    func isRunningInLocalMode() -> Bool {
        return isLocalMode
    }
}
