//
//  HelpRequestViewModel.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class HelpRequestViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var helpRequests: [HelpRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Form fields
    @Published var requestDescription = ""
    @Published var estimatedHours: Int = 1
    @Published var estimatedMinutes: Int = 0
    @Published var neededByDate: Date?
    @Published var useDeadline = false

    // MARK: - Services

    private let persistenceController = PersistenceController.shared
    private let firebaseService = FirebaseService.shared

    // MARK: - Fetch Help Requests

    func fetchHelpRequests(for group: Group) {
        let context = persistenceController.container.viewContext
        let fetchRequest = HelpRequest.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupId == %@", group.id! as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HelpRequest.createdAt, ascending: false)]

        do {
            helpRequests = try context.fetch(fetchRequest)
        } catch {
            errorMessage = "요청을 불러오는 데 실패했습니다"
            print("Failed to fetch help requests: \(error)")
        }
    }

    // MARK: - Create Help Request

    func createHelpRequest(in group: Group, by user: User) {
        guard !requestDescription.isEmpty else {
            errorMessage = "무엇이 필요한지 입력해 주세요"
            return
        }

        let totalSeconds = TimeInterval((estimatedHours * 3600) + (estimatedMinutes * 60))

        isLoading = true
        errorMessage = nil

        let context = persistenceController.container.viewContext

        let request = HelpRequest(context: context)
        request.id = UUID()
        request.groupId = group.id
        request.requesterId = user.id
        request.requestDescription = requestDescription
        request.estimatedDuration = totalSeconds
        request.neededBy = useDeadline ? neededByDate : nil
        request.status = "open"
        request.createdAt = Date()

        // Relationships
        request.group = group
        request.requester = user

        // Update group activity
        group.lastActivityAt = Date()

        persistenceController.save()

        // Notify all group members
        notifyGroupMembers(for: request, group: group, exceptUser: user)

        // Sync to Firebase
        Task {
            do {
                // Sync request (implementation in FirebaseService)
                // try await firebaseService.syncHelpRequest(request)

                successMessage = "요청을 보냈습니다\n그룹원들이 확인하면 알려드릴게요"
                isLoading = false

                // Reset form
                resetForm()

                // Refresh requests
                fetchHelpRequests(for: group)
            } catch {
                errorMessage = "요청을 저장하는 데 실패했습니다"
                isLoading = false
            }
        }
    }

    // MARK: - Claim Help Request

    func claimHelpRequest(_ request: HelpRequest, by user: User) async {
        guard request.isOpen else {
            errorMessage = "이미 다른 분이 도와주기로 했습니다"
            return
        }

        request.status = "claimed"
        request.claimedBy = user.id
        request.claimedAt = Date()

        persistenceController.save()

        // Notify requester
        if let requester = request.requester {
            notifyRequesterOfClaim(request: request, claimedBy: user, requester: requester)
        }

        // Sync to Firebase
        // try? await firebaseService.syncHelpRequest(request)
    }

    // MARK: - Complete Help Request

    func completeHelpRequest(_ request: HelpRequest, with share: Share) {
        request.status = "completed"
        request.completedAt = Date()
        request.resultingShareId = share.id
        request.resultingShare = share

        persistenceController.save()

        // Sync to Firebase
        Task {
            // try? await firebaseService.syncHelpRequest(request)
        }
    }

    // MARK: - Cancel Help Request

    func cancelHelpRequest(_ request: HelpRequest) {
        request.status = "cancelled"

        persistenceController.save()

        // Notify whoever claimed it (if anyone)
        if let claimedBy = request.claimedBy {
            // Send cancellation notification
        }

        Task {
            // try? await firebaseService.syncHelpRequest(request)
            fetchHelpRequests(for: request.group!)
        }
    }

    // MARK: - Helper Methods

    private func resetForm() {
        requestDescription = ""
        estimatedHours = 1
        estimatedMinutes = 0
        neededByDate = nil
        useDeadline = false
    }

    private func notifyGroupMembers(for request: HelpRequest, group: Group, exceptUser: User) {
        let context = persistenceController.container.viewContext

        for membership in group.activeMembers {
            guard let member = membership.user,
                  member.id != exceptUser.id else { continue }

            let notification = Notification(context: context)
            notification.id = UUID()
            notification.userId = member.id
            notification.type = "help_request"
            notification.title = "도움 요청"
            notification.body = "\(exceptUser.nickname ?? "누군가")님이 도움이 필요해요\n시간을 나눠볼까요? 🤝"
            notification.relatedEntityType = "HelpRequest"
            notification.relatedEntityId = request.id
            notification.isRead = false
            notification.createdAt = Date()
            notification.user = member
        }

        persistenceController.save()
    }

    private func notifyRequesterOfClaim(request: HelpRequest, claimedBy: User, requester: User) {
        let context = persistenceController.container.viewContext

        let notification = Notification(context: context)
        notification.id = UUID()
        notification.userId = requester.id
        notification.type = "help_claimed"
        notification.title = "도움 확정"
        notification.body = "\(claimedBy.nickname ?? "누군가")님이 도와주기로 했어요 💛"
        notification.relatedEntityType = "HelpRequest"
        notification.relatedEntityId = request.id
        notification.isRead = false
        notification.createdAt = Date()
        notification.user = requester

        persistenceController.save()
    }
}
