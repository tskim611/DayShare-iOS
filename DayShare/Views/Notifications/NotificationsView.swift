//
//  NotificationsView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI
import CoreData

struct NotificationsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var authViewModel: AuthenticationViewModel

    @FetchRequest private var notifications: FetchedResults<Notification>

    @State private var showingUnreadOnly = false

    init(currentUser: User?) {
        let userId = currentUser?.id ?? UUID()
        let predicate: NSPredicate

        _fetchRequest = FetchRequest<Notification>(
            entity: Notification.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Notification.createdAt, ascending: false)],
            predicate: NSPredicate(format: "userId == %@", userId as CVarArg)
        )
    }

    var displayedNotifications: [Notification] {
        if showingUnreadOnly {
            return notifications.filter { !$0.isRead }
        }
        return Array(notifications)
    }

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationView {
            Group {
                if notifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .navigationTitle("알림")
            .toolbar {
                if !notifications.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(action: {
                                markAllAsRead()
                            }) {
                                Label("모두 읽음으로 표시", systemImage: "checkmark.circle")
                            }

                            Toggle(isOn: $showingUnreadOnly) {
                                Label("읽지 않은 알림만", systemImage: "line.3.horizontal.decrease.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))

            Text("알림이 없어요")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("도움 요청이나 나눔 확인이 있으면\n여기에 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Notifications List

    private var notificationsList: some View {
        List {
            if unreadCount > 0 {
                Section {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .foregroundColor(.brandPrimary)
                        Text("읽지 않은 알림 \(unreadCount)개")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            ForEach(displayedNotifications, id: \.id) { notification in
                NotificationRowView(notification: notification)
                    .onTapGesture {
                        markAsRead(notification)
                        handleNotificationTap(notification)
                    }
            }
            .onDelete(perform: deleteNotifications)
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Actions

    private func markAsRead(_ notification: Notification) {
        guard !notification.isRead else { return }

        notification.isRead = true
        notification.readAt = Date()

        PersistenceController.shared.save()
        NotificationService.shared.updateBadgeCount(unreadCount - 1)
    }

    private func markAllAsRead() {
        for notification in notifications where !notification.isRead {
            notification.isRead = true
            notification.readAt = Date()
        }

        PersistenceController.shared.save()
        NotificationService.shared.clearBadge()
    }

    private func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            let notification = displayedNotifications[index]
            viewContext.delete(notification)
        }

        PersistenceController.shared.save()
    }

    private func handleNotificationTap(_ notification: Notification) {
        // Handle navigation based on notification type
        guard let type = notification.type else { return }

        switch type {
        case "share_pending":
            // Navigate to share confirmation
            if let shareId = notification.relatedEntityId {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ShowShareConfirmation"),
                    object: nil,
                    userInfo: ["shareId": shareId.uuidString]
                )
            }

        case "help_request":
            // Navigate to help requests
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToHelpRequests"),
                object: nil
            )

        case "thank_you", "help_claimed":
            // Just mark as read (already done)
            break

        default:
            break
        }
    }
}

// MARK: - Notification Row View

struct NotificationRowView: View {
    let notification: Notification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(notification.title ?? "알림")
                    .font(.subheadline)
                    .fontWeight(notification.isRead ? .regular : .semibold)

                // Body
                Text(notification.body ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                // Time
                if let createdAt = notification.createdAt {
                    Text(TimeFormatters.formatRelativeDate(createdAt))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Unread indicator
            if !notification.isRead {
                Circle()
                    .fill(Color.brandPrimary)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.6 : 1.0)
    }

    private var iconName: String {
        switch notification.type {
        case "share_pending":
            return "clock.arrow.circlepath"
        case "help_request":
            return "hand.raised.fill"
        case "thank_you":
            return "heart.fill"
        case "help_claimed":
            return "checkmark.circle.fill"
        case "balance_reminder":
            return "chart.pie.fill"
        default:
            return "bell.fill"
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case "share_pending":
            return .brandPrimary
        case "help_request":
            return .brandAccent
        case "thank_you":
            return .gratitudeGold
        case "help_claimed":
            return .balanceGreen
        case "balance_reminder":
            return .gentleReminder
        default:
            return .gray
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let user = User(context: context)
        user.id = UUID()
        user.nickname = "테스트"

        // Create sample notifications
        let notification1 = Notification(context: context)
        notification1.id = UUID()
        notification1.userId = user.id
        notification1.type = "share_pending"
        notification1.title = "나눔 확인 요청"
        notification1.body = "민수님이 도움을 기록했어요. 확인해 주세요"
        notification1.isRead = false
        notification1.createdAt = Date()

        return NotificationsView(currentUser: user)
            .environment(\.managedObjectContext, context)
            .environmentObject(AuthenticationViewModel())
    }
}
