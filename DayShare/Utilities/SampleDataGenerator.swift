//
//  SampleDataGenerator.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  Generates sample data for testing and previews

import Foundation
import CoreData

struct SampleDataGenerator {
    // MARK: - Generate Sample Data

    static func generateSampleData(in context: NSManagedObjectContext) {
        // Create users
        let users = createSampleUsers(in: context)

        // Create group
        let group = createSampleGroup(with: users, in: context)

        // Create shares
        createSampleShares(in: group, users: users, context: context)

        // Create help requests
        createSampleHelpRequests(in: group, users: users, context: context)

        // Create notifications
        createSampleNotifications(for: users[0], in: context)

        // Save
        try? context.save()
    }

    // MARK: - Create Users

    private static func createSampleUsers(in context: NSManagedObjectContext) -> [User] {
        let names = [
            ("민수", "👨"),
            ("지은", "👩"),
            ("서준", "👦"),
            ("하은", "👧")
        ]

        return names.map { name, emoji in
            let user = User(context: context)
            user.id = UUID()
            user.nickname = name
            user.avatarEmoji = emoji
            user.language = "ko"
            user.notificationsEnabled = true
            user.isPremium = false
            user.createdAt = Date().addingTimeInterval(-Double.random(in: 86400...2592000)) // 1-30 days ago
            user.lastActiveAt = Date()
            return user
        }
    }

    // MARK: - Create Group

    private static func createSampleGroup(with users: [User], in context: NSManagedObjectContext) -> Group {
        let group = Group(context: context)
        group.id = UUID()
        group.name = "우리 가족"
        group.emoji = "👨‍👩‍👧‍👦"
        group.maxMembers = 5
        group.isArchived = false
        group.createdBy = users[0].id
        group.createdAt = Date().addingTimeInterval(-2592000) // 30 days ago
        group.lastActivityAt = Date()
        group.generateInviteCode()

        // Create memberships
        for (index, user) in users.enumerated() {
            let membership = GroupMembership(context: context)
            membership.id = UUID()
            membership.userId = user.id
            membership.groupId = group.id
            membership.role = index == 0 ? "creator" : "member"
            membership.isActive = true
            membership.joinedAt = Date().addingTimeInterval(-Double(2592000 - index * 86400)) // Staggered joins
            membership.user = user
            membership.group = group
        }

        return group
    }

    // MARK: - Create Shares

    private static func createSampleShares(in group: Group, users: [User], context: NSManagedObjectContext) {
        let shareTemplates: [(giver: Int, receiver: Int, description: String, category: String, hours: Double)] = [
            (0, 1, "아이 돌봄", "childcare", 2.0),
            (1, 0, "장보기 대신", "errands", 1.0),
            (0, 2, "학교 픽업", "transport", 0.5),
            (2, 3, "숙제 도와주기", "other", 1.5),
            (3, 0, "집안일 도움", "housework", 2.0),
            (1, 3, "저녁 식사 준비", "cooking", 1.5),
            (0, 1, "병원 동행", "transport", 3.0),
            (2, 1, "짐 옮기기", "housework", 1.0)
        ]

        for (index, template) in shareTemplates.enumerated() {
            let share = Share(context: context)
            share.id = UUID()
            share.groupId = group.id
            share.giverUserId = users[template.giver].id
            share.receiverUserId = users[template.receiver].id
            share.shareDescription = template.description
            share.category = template.category
            share.occurredAt = Date().addingTimeInterval(-Double(index * 86400 + Int.random(in: 0...43200)))
            share.duration = template.hours * 3600
            share.status = index < 6 ? "confirmed" : "pending"
            share.createdAt = Date().addingTimeInterval(-Double(index * 86400))
            share.createdBy = users[template.giver].id
            share.isDeleted = false

            if share.isConfirmed {
                share.confirmedAt = Date().addingTimeInterval(-Double(index * 86400 - 3600))
                share.confirmedBy = users[template.receiver].id

                if index % 3 == 0 {
                    let thankYouNotes = ["정말 고마워요!", "큰 도움이 되었어요", "덕분에 편했어요", "감사합니다 💛"]
                    share.thankYouNote = thankYouNotes.randomElement()
                }
            }

            share.group = group
            share.giver = users[template.giver]
            share.receiver = users[template.receiver]
        }
    }

    // MARK: - Create Help Requests

    private static func createSampleHelpRequests(in group: Group, users: [User], context: NSManagedObjectContext) {
        let requestTemplates: [(requester: Int, description: String, status: String, claimedBy: Int?)] = [
            (1, "퇴근길에 약 좀 가져다줄래요?", "open", nil),
            (3, "내일 아침 학교 데려다주실 수 있나요?", "claimed", 0),
            (0, "주말에 짐 좀 옮겨주실 분?", "completed", 2)
        ]

        for (index, template) in requestTemplates.enumerated() {
            let request = HelpRequest(context: context)
            request.id = UUID()
            request.groupId = group.id
            request.requesterId = users[template.requester].id
            request.requestDescription = template.description
            request.estimatedDuration = Double.random(in: 1800...7200) // 0.5-2 hours
            request.status = template.status
            request.createdAt = Date().addingTimeInterval(-Double(index * 43200))

            if let claimedBy = template.claimedBy {
                request.claimedBy = users[claimedBy].id
                request.claimedAt = Date().addingTimeInterval(-Double(index * 43200 - 3600))

                if template.status == "completed" {
                    request.completedAt = Date().addingTimeInterval(-Double(index * 43200 - 7200))
                }
            }

            request.group = group
            request.requester = users[template.requester]
        }
    }

    // MARK: - Create Notifications

    private static func createSampleNotifications(for user: User, in context: NSManagedObjectContext) {
        let notificationTemplates: [(type: String, title: String, body: String, isRead: Bool)] = [
            ("share_pending", "나눔 확인 요청", "민수님이 도움을 기록했어요. 확인해 주세요", false),
            ("help_request", "도움 요청", "지은님이 도움이 필요해요\n시간을 나눠볼까요? 🤝", false),
            ("thank_you", "감사 메시지", "하은님: 정말 고마워요! 💚", true),
            ("help_claimed", "도움 확정", "서준님이 도와주기로 했어요 💛", true)
        ]

        for (index, template) in notificationTemplates.enumerated() {
            let notification = Notification(context: context)
            notification.id = UUID()
            notification.userId = user.id
            notification.type = template.type
            notification.title = template.title
            notification.body = template.body
            notification.isRead = template.isRead
            notification.createdAt = Date().addingTimeInterval(-Double(index * 3600))
            notification.user = user

            if template.isRead {
                notification.readAt = Date().addingTimeInterval(-Double(index * 3600 - 1800))
            }
        }
    }

    // MARK: - Clear Sample Data

    static func clearAllData(in context: NSManagedObjectContext) {
        let entities = ["User", "Group", "GroupMembership", "Share", "HelpRequest", "Notification", "ActivityLog"]

        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
    }
}
