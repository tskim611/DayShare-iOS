//
//  ActivityLogView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  PIPA Compliance: Activity transparency

import SwiftUI
import CoreData

struct ActivityLogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let currentUser: User?

    @FetchRequest private var logs: FetchedResults<ActivityLog>

    init(currentUser: User?) {
        let userId = currentUser?.id ?? UUID()

        _logs = FetchRequest<ActivityLog>(
            entity: ActivityLog.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ActivityLog.timestamp, ascending: false)],
            predicate: NSPredicate(format: "userId == %@", userId as CVarArg)
        )
    }

    var body: some View {
        List {
            if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("활동 기록이 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(logs, id: \.id) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(actionDescription(log.action ?? ""))
                            .font(.subheadline)

                        HStack {
                            if let timestamp = log.timestamp {
                                Text(timestamp, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text("•")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text(timestamp, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("활동 기록")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func actionDescription(_ action: String) -> String {
        switch action {
        case "created_group":
            return "그룹을 생성했습니다"
        case "joined_group":
            return "그룹에 참여했습니다"
        case "created_share":
            return "나눔을 기록했습니다"
        case "confirmed_share":
            return "나눔을 확인했습니다"
        case "created_help_request":
            return "도움을 요청했습니다"
        case "claimed_help_request":
            return "도움 요청에 응답했습니다"
        case "deleted_account":
            return "계정 삭제를 요청했습니다"
        default:
            return action
        }
    }
}
