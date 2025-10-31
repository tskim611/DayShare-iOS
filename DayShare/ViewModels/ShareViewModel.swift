//
//  ShareViewModel.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class ShareViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var shares: [Share] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Form fields
    @Published var selectedGiver: User?
    @Published var selectedReceiver: User?
    @Published var description = ""
    @Published var selectedCategory: String?
    @Published var hours: Int = 1
    @Published var minutes: Int = 0
    @Published var selectedDate = Date()

    // Categories
    let categories = ["childcare", "errands", "housework", "cooking", "transport", "other"]
    let categoryLabels = [
        "childcare": "아이 돌봄",
        "errands": "심부름/장보기",
        "housework": "집안일",
        "cooking": "식사 준비",
        "transport": "차량 지원",
        "other": "기타"
    ]

    // MARK: - Services

    private let persistenceController = PersistenceController.shared
    private let firebaseService = FirebaseService.shared

    // MARK: - Create Share

    func createShare(in group: Group, createdBy user: User) {
        guard let giver = selectedGiver,
              let receiver = selectedReceiver else {
            errorMessage = "도움을 주고받은 분을 선택해 주세요"
            return
        }

        guard giver.id != receiver.id else {
            errorMessage = "같은 사람을 선택할 수 없습니다"
            return
        }

        guard !description.isEmpty else {
            errorMessage = "어떤 도움이었는지 입력해 주세요"
            return
        }

        let totalSeconds = TimeInterval((hours * 3600) + (minutes * 60))
        guard totalSeconds > 0 else {
            errorMessage = "시간을 입력해 주세요"
            return
        }

        isLoading = true
        errorMessage = nil

        let context = persistenceController.container.viewContext

        let share = Share(context: context)
        share.id = UUID()
        share.groupId = group.id
        share.giverUserId = giver.id
        share.receiverUserId = receiver.id
        share.shareDescription = description
        share.category = selectedCategory
        share.occurredAt = selectedDate
        share.duration = totalSeconds
        share.status = "pending" // Waiting for receiver confirmation
        share.createdAt = Date()
        share.createdBy = user.id
        share.isDeleted = false

        // Relationships
        share.group = group
        share.giver = giver
        share.receiver = receiver

        // Update group activity
        group.lastActivityAt = Date()

        persistenceController.save()

        // Create notification for receiver
        createConfirmationNotification(for: share, receiver: receiver)

        // Sync to Firebase
        Task {
            do {
                try await firebaseService.syncShare(share)

                // Success message with names
                let giverName = giver.nickname ?? "누군가"
                let receiverName = receiver.nickname ?? "누군가"
                successMessage = "고마운 마음이 기록되었어요 💛\n\(giverName)님이 \(receiverName)님께 나눈 시간이 전달되었습니다"

                isLoading = false

                // Reset form
                resetForm()

                // Refresh shares
                fetchShares(for: group)
            } catch {
                errorMessage = "기록을 저장하는 데 실패했습니다"
                isLoading = false
            }
        }
    }

    // MARK: - Confirm Share

    func confirmShare(_ share: Share, by user: User, thankYouNote: String? = nil) {
        share.status = "confirmed"
        share.confirmedAt = Date()
        share.confirmedBy = user.id
        share.thankYouNote = thankYouNote
        share.updatedAt = Date()

        persistenceController.save()

        Task {
            try? await firebaseService.syncShare(share)

            // Create notification for giver
            if let giver = share.giver {
                createThankYouNotification(for: share, giver: giver, thankYouNote: thankYouNote)
            }
        }
    }

    // MARK: - Fetch Shares

    func fetchShares(for group: Group) {
        let context = persistenceController.container.viewContext
        let fetchRequest = Share.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "groupId == %@ AND isDeleted == NO",
            group.id! as CVarArg
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Share.occurredAt, ascending: false)]

        do {
            shares = try context.fetch(fetchRequest)
        } catch {
            errorMessage = "기록을 불러오는 데 실패했습니다"
            print("Failed to fetch shares: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func resetForm() {
        selectedGiver = nil
        selectedReceiver = nil
        description = ""
        selectedCategory = nil
        hours = 1
        minutes = 0
        selectedDate = Date()
    }

    private func createConfirmationNotification(for share: Share, receiver: User) {
        let context = persistenceController.container.viewContext

        let notification = Notification(context: context)
        notification.id = UUID()
        notification.userId = receiver.id
        notification.type = "share_pending"
        notification.title = "나눔 확인 요청"
        notification.body = "\(share.giver?.nickname ?? "누군가")님이 도움을 기록했어요. 확인해 주세요"
        notification.relatedEntityType = "Share"
        notification.relatedEntityId = share.id
        notification.isRead = false
        notification.createdAt = Date()
        notification.user = receiver

        persistenceController.save()
    }

    private func createThankYouNotification(for share: Share, giver: User, thankYouNote: String?) {
        let context = persistenceController.container.viewContext

        let notification = Notification(context: context)
        notification.id = UUID()
        notification.userId = giver.id
        notification.type = "thank_you"
        notification.title = "감사 메시지"

        if let note = thankYouNote, !note.isEmpty {
            notification.body = "\(share.receiver?.nickname ?? "누군가")님: \(note)"
        } else {
            notification.body = "\(share.receiver?.nickname ?? "누군가")님이 나눔을 확인했어요"
        }

        notification.relatedEntityType = "Share"
        notification.relatedEntityId = share.id
        notification.isRead = false
        notification.createdAt = Date()
        notification.user = giver

        persistenceController.save()
    }
}
