//
//  GroupViewModel.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class GroupViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var groups: [Group] = []
    @Published var selectedGroup: Group?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateGroup = false

    // Form fields for creating group
    @Published var newGroupName = ""
    @Published var newGroupEmoji = "👥"

    // MARK: - Services

    private let persistenceController = PersistenceController.shared
    private let firebaseService = FirebaseService.shared

    // MARK: - Initialization

    init() {
        fetchGroups()
    }

    // MARK: - Fetch Groups

    func fetchGroups() {
        let context = persistenceController.container.viewContext
        let fetchRequest = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isArchived == NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Group.lastActivityAt, ascending: false)]

        do {
            groups = try context.fetch(fetchRequest)
        } catch {
            errorMessage = "그룹을 불러오는 데 실패했습니다"
            print("Failed to fetch groups: \(error)")
        }
    }

    // MARK: - Create Group

    func createGroup(currentUser: User) {
        guard !newGroupName.isEmpty else {
            errorMessage = "그룹 이름을 입력해 주세요"
            return
        }

        isLoading = true
        errorMessage = nil

        let context = persistenceController.container.viewContext

        // Create Group
        let group = Group(context: context)
        group.id = UUID()
        group.name = newGroupName
        group.emoji = newGroupEmoji
        group.maxMembers = 5 // Default for free tier
        group.isArchived = false
        group.createdBy = currentUser.id
        group.createdAt = Date()
        group.lastActivityAt = Date()
        group.generateInviteCode()

        // Create Membership for creator
        let membership = GroupMembership(context: context)
        membership.id = UUID()
        membership.userId = currentUser.id
        membership.groupId = group.id
        membership.role = "creator"
        membership.isActive = true
        membership.joinedAt = Date()
        membership.user = currentUser
        membership.group = group

        // Save
        persistenceController.save()

        // Sync to Firebase
        Task {
            do {
                try await firebaseService.syncGroup(group)
                isLoading = false

                // Reset form
                newGroupName = ""
                newGroupEmoji = "👥"
                showingCreateGroup = false

                // Refresh groups
                fetchGroups()
            } catch {
                errorMessage = "그룹을 저장하는 데 실패했습니다"
                isLoading = false
            }
        }
    }

    // MARK: - Join Group with Invite Code

    func joinGroup(withCode code: String, currentUser: User) async {
        isLoading = true
        errorMessage = nil

        let context = persistenceController.container.viewContext
        let fetchRequest = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "inviteCode == %@", code)

        do {
            let groups = try context.fetch(fetchRequest)

            guard let group = groups.first else {
                errorMessage = "유효하지 않은 초대 코드입니다"
                isLoading = false
                return
            }

            guard group.isInviteValid else {
                errorMessage = "초대 코드가 만료되었습니다"
                isLoading = false
                return
            }

            // Check if already a member
            let membershipFetch = GroupMembership.fetchRequest()
            membershipFetch.predicate = NSPredicate(
                format: "groupId == %@ AND userId == %@",
                group.id! as CVarArg,
                currentUser.id! as CVarArg
            )
            let existingMemberships = try context.fetch(membershipFetch)

            if !existingMemberships.isEmpty {
                errorMessage = "이미 이 그룹의 멤버입니다"
                isLoading = false
                return
            }

            // Create membership
            let membership = GroupMembership(context: context)
            membership.id = UUID()
            membership.userId = currentUser.id
            membership.groupId = group.id
            membership.role = "member"
            membership.isActive = true
            membership.joinedAt = Date()
            membership.user = currentUser
            membership.group = group

            // Update group activity
            group.lastActivityAt = Date()

            persistenceController.save()

            // Sync to Firebase
            try await firebaseService.syncGroup(group)

            isLoading = false
            fetchGroups()

        } catch {
            errorMessage = "그룹 참여에 실패했습니다"
            isLoading = false
        }
    }

    // MARK: - Archive Group

    func archiveGroup(_ group: Group) {
        group.isArchived = true
        persistenceController.save()

        Task {
            try? await firebaseService.syncGroup(group)
            fetchGroups()
        }
    }

    // MARK: - Regenerate Invite Code

    func regenerateInviteCode(for group: Group) {
        group.generateInviteCode()
        persistenceController.save()

        Task {
            try? await firebaseService.syncGroup(group)
        }
    }
}
