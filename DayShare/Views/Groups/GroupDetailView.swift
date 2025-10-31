//
//  GroupDetailView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct GroupDetailView: View {
    let group: Group
    @StateObject private var viewModel = ShareViewModel()
    @State private var showingInviteSheet = false
    @State private var showingAddShare = false

    var body: some View {
        List {
            // Group Header
            Section {
                VStack(spacing: 16) {
                    Text(group.emoji ?? "👥")
                        .font(.system(size: 60))

                    Text(group.name ?? "그룹")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("멤버 \(group.activeMembers.count)명")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }

            // Members Section
            Section {
                ForEach(group.activeMembers, id: \.id) { membership in
                    if let user = membership.user {
                        HStack {
                            Text(user.avatarEmoji ?? "👤")
                                .font(.title3)

                            VStack(alignment: .leading) {
                                Text(user.nickname ?? "사용자")
                                    .font(.body)

                                if membership.isCreator {
                                    Text("그룹장")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Balance indicator
                            let balance = user.balance(in: group)
                            if balance != 0 {
                                Text(formatBalance(balance))
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(balanceColor(balance).opacity(0.2))
                                    .foregroundColor(balanceColor(balance))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("멤버")
            }

            // Recent Shares
            Section {
                if group.confirmedShares.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("아직 기록된 나눔이 없어요")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("도움을 주고받으면 여기에 표시됩니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(group.confirmedShares.prefix(5), id: \.id) { share in
                        ShareRowView(share: share)
                    }
                }
            } header: {
                Text("최근 나눔 기록")
            }

            // Group Actions
            Section {
                Button(action: {
                    showingInviteSheet = true
                }) {
                    Label("멤버 초대하기", systemImage: "person.badge.plus")
                }

                Button(action: {
                    // Navigate to full balance view
                }) {
                    Label("나눔 현황 보기", systemImage: "chart.pie")
                }

                Button(action: {
                    // Navigate to all shares
                }) {
                    Label("전체 기록 보기", systemImage: "list.bullet")
                }
            }
        }
        .navigationTitle("그룹 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddShare = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "F6B352"))
                }
            }
        }
        .sheet(isPresented: $showingInviteSheet) {
            InviteView(group: group)
        }
        .sheet(isPresented: $showingAddShare) {
            // AddShareView(group: group)
            // Will be implemented next
            Text("나눔 기록하기")
        }
    }

    // MARK: - Helper Functions

    private func formatBalance(_ balance: TimeInterval) -> String {
        let hours = Int(balance / 3600)
        if hours > 0 {
            return "+\(hours)시간"
        } else if hours < 0 {
            return "\(hours)시간"
        } else {
            return "0시간"
        }
    }

    private func balanceColor(_ balance: TimeInterval) -> Color {
        if balance > 0 {
            return Color(hex: "81C784") // Balance Green
        } else if balance < 0 {
            return Color(hex: "FF8A80") // Gentle Reminder Coral
        } else {
            return .gray
        }
    }
}

// MARK: - Share Row View

struct ShareRowView: View {
    let share: Share

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(share.shareDescription ?? "도움")
                    .font(.body)

                Spacer()

                Text("\(Int(share.duration / 3600))시간")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                if let giver = share.giver, let receiver = share.receiver {
                    Text("\(giver.nickname ?? "누군가")님 → \(receiver.nickname ?? "누군가")님")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let date = share.occurredAt {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Invite View

struct InviteView: View {
    @Environment(\.dismiss) private var dismiss
    let group: Group
    @State private var copied = false

    var inviteCode: String {
        group.inviteCode ?? "없음"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Text(group.emoji ?? "👥")
                    .font(.system(size: 80))

                Text("\(group.name ?? "그룹")에 초대")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("초대 코드를 공유하세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Invite Code Display
                VStack(spacing: 16) {
                    Text(inviteCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .tracking(4)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                    Button(action: {
                        UIPasteboard.general.string = inviteCode
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    }) {
                        HStack {
                            Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                            Text(copied ? "복사되었습니다" : "초대 코드 복사")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "F6B352"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)

                VStack(spacing: 8) {
                    Text("💡 이 코드는 24시간 동안 유효합니다")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let expiresAt = group.inviteExpiresAt {
                        Text("만료: \(expiresAt, style: .date) \(expiresAt, style: .time)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .navigationTitle("멤버 초대")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let group = Group(context: context)
        group.name = "우리 가족"
        group.emoji = "👨‍👩‍👧‍👦"

        return NavigationView {
            GroupDetailView(group: group)
        }
    }
}
