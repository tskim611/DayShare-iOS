//
//  NotificationService.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  Handles local and push notifications with gentle, non-nagging tone from UX Tone Kit

import Foundation
import UserNotifications
import FirebaseMessaging

class NotificationService: NSObject {
    // MARK: - Singleton

    static let shared = NotificationService()

    // MARK: - Properties

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Initialization

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - Request Permission

    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        return try await notificationCenter.requestAuthorization(options: options)
    }

    // MARK: - Register for Push Notifications

    func registerForPushNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - Schedule Local Notification

    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        userInfo: [String: Any] = [:],
        trigger: UNNotificationTrigger? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    // MARK: - Gentle Reminder Notifications (from UX Tone Kit)

    /// When balance is lopsided (User has received more)
    func sendBalanceReminderNotification(for user: User, giver: User) {
        let content = UNMutableNotificationContent()
        content.title = "함께 나눔 제안"
        content.body = "\(giver.nickname ?? "누군가")님께서 최근 많이 도와주셨어요\n이번 주, 함께 나눌 차례는 어떨까요? 💛"
        content.sound = .default
        content.categoryIdentifier = "BALANCE_REMINDER"

        // Schedule for tomorrow at 10 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "balance_reminder_\(user.id?.uuidString ?? "")",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    /// When someone needs help
    func sendHelpRequestNotification(for request: HelpRequest, to user: User) {
        let content = UNMutableNotificationContent()
        content.title = "도움 요청"
        content.body = "\(request.requester?.nickname ?? "누군가")님이 도움이 필요해요\n시간을 나눠볼까요? 🤝"
        content.sound = .default
        content.categoryIdentifier = "HELP_REQUEST"
        content.userInfo = [
            "type": "help_request",
            "requestId": request.id?.uuidString ?? ""
        ]

        let request = UNNotificationRequest(
            identifier: "help_request_\(request.id?.uuidString ?? "")",
            content: content,
            trigger: nil // Immediate
        )

        notificationCenter.add(request)
    }

    /// When someone confirms receiving help
    func sendThankYouNotification(for share: Share, to giver: User) {
        let content = UNMutableNotificationContent()
        content.title = "감사 메시지"

        if let note = share.thankYouNote, !note.isEmpty {
            content.body = "\(share.receiver?.nickname ?? "누군가")님: \(note) 💚"
        } else {
            content.body = "\(share.receiver?.nickname ?? "누군가")님이 나눔을 확인했어요 💚"
        }

        content.sound = .default
        content.categoryIdentifier = "THANK_YOU"
        content.userInfo = [
            "type": "thank_you",
            "shareId": share.id?.uuidString ?? ""
        ]

        let request = UNNotificationRequest(
            identifier: "thank_you_\(share.id?.uuidString ?? "")",
            content: content,
            trigger: nil // Immediate
        )

        notificationCenter.add(request)
    }

    /// Monthly summary (Premium feature)
    func sendMonthlySummaryNotification(for group: Group, totalHours: Int, topCategories: [(category: String, count: Int)]) {
        let content = UNMutableNotificationContent()
        content.title = "이번 달 나눔 요약"

        var bodyText = "이번 달, \(group.name ?? "그룹")이 서로 나눈 시간은 \(totalHours)시간입니다 ✨\n\n"
        bodyText += "가장 많이 도운 순간:\n"

        for (index, item) in topCategories.prefix(3).enumerated() {
            bodyText += "• \(item.category) (\(item.count)회)\n"
        }

        bodyText += "\n함께해 주셔서 고맙습니다 🙏"

        content.body = bodyText
        content.sound = .default
        content.categoryIdentifier = "MONTHLY_SUMMARY"

        // Schedule for first day of next month at 9 AM
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "monthly_summary_\(group.id?.uuidString ?? "")",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    /// Confirmation prompt when someone logs help
    func sendConfirmationRequestNotification(for share: Share, to receiver: User) {
        let content = UNMutableNotificationContent()
        content.title = "나눔 확인 요청"
        content.body = "\(share.giver?.nickname ?? "누군가")님이 도움을 기록했어요. 확인해 주세요"
        content.sound = .default
        content.categoryIdentifier = "SHARE_CONFIRMATION"
        content.userInfo = [
            "type": "share_pending",
            "shareId": share.id?.uuidString ?? ""
        ]

        let request = UNNotificationRequest(
            identifier: "confirmation_\(share.id?.uuidString ?? "")",
            content: content,
            trigger: nil // Immediate
        )

        notificationCenter.add(request)
    }

    // MARK: - Cancel Notifications

    func cancelNotification(withId id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Badge Management

    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }

    func clearBadge() {
        updateBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    // Handle foreground notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Route to appropriate screen based on notification type
        if let type = userInfo["type"] as? String {
            switch type {
            case "help_request":
                // Navigate to help requests tab
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavigateToHelpRequests"),
                    object: nil
                )
            case "share_pending":
                // Navigate to share confirmation
                if let shareId = userInfo["shareId"] as? String {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowShareConfirmation"),
                        object: nil,
                        userInfo: ["shareId": shareId]
                    )
                }
            case "thank_you":
                // Navigate to notifications
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavigateToNotifications"),
                    object: nil
                )
            default:
                break
            }
        }

        completionHandler()
    }
}

// MARK: - Firebase Messaging Delegate

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "nil")")

        // Send token to backend if needed
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "FCMToken")
        }
    }
}
