//
//  BalanceView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  Uses copy from DayShare-UX-Tone-Kit.md
//  NO RANKINGS - Uses donut chart visualization only

import SwiftUI

struct BalanceView: View {
    let group: Group

    var balanceSummary: [(user: User, balance: TimeInterval)] {
        group.balanceSummary()
    }

    var totalTimeShared: TimeInterval {
        group.totalTimeExchanged
    }

    var isBalanced: Bool {
        let balances = balanceSummary.map { $0.balance }
        let maxDiff = (balances.max() ?? 0) - (balances.min() ?? 0)
        return maxDiff < 7200 // Less than 2 hours difference
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(group.emoji ?? "👥")
                        .font(.system(size: 50))

                    Text("우리의 나눔 현황")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(group.name ?? "그룹") - \(group.activeMembers.count)명이 함께하고 있어요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)

                // Donut Chart
                VStack(spacing: 16) {
                    ZStack {
                        // Donut Chart
                        DonutChart(balances: balanceSummary.map {
                            (user: $0.user, value: abs($0.balance))
                        })
                        .frame(width: 200, height: 200)

                        // Center text
                        VStack(spacing: 4) {
                            if isBalanced {
                                Text("서로 잘")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("나누고 있어요")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("👍")
                                    .font(.title)
                            } else {
                                Text("\(Int(totalTimeShared / 3600))")
                                    .font(.system(size: 36, weight: .bold))
                                Text("시간")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Text("최근 한 달간 함께 나눈 시간")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Member Cards
                VStack(spacing: 16) {
                    ForEach(balanceSummary, id: \.user.id) { item in
                        MemberBalanceCard(user: item.user, balance: item.balance, group: group)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
        }
        .navigationTitle("나눔 현황")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Donut Chart

struct DonutChart: View {
    let balances: [(user: User, value: TimeInterval)]

    private var colors: [Color] = [
        Color(hex: "F6B352"), // Warm Amber
        Color(hex: "4ECDC4"), // Soft Teal
        Color(hex: "FFD700"), // Gratitude Gold
        Color(hex: "81C784"), // Balance Green
        Color(hex: "FF8A80")  // Gentle Reminder Coral
    ]

    private var total: TimeInterval {
        balances.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        ZStack {
            if total > 0 {
                ForEach(Array(balances.enumerated()), id: \.element.user.id) { index, item in
                    DonutSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: colors[index % colors.count]
                    )
                }
            } else {
                // Empty state
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 30)
            }

            // Inner circle to create donut
            Circle()
                .fill(Color(UIColor.systemBackground))
                .frame(width: 140, height: 140)
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let previousTotal = balances.prefix(index).reduce(0) { $0 + $1.value }
        return Angle(degrees: (previousTotal / total) * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let currentTotal = balances.prefix(index + 1).reduce(0) { $0 + $1.value }
        return Angle(degrees: (currentTotal / total) * 360 - 90)
    }
}

// MARK: - Donut Slice

struct DonutSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: width / 2, y: width / 2)
                let radius = width / 2

                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
            }
            .stroke(color, lineWidth: 30)
        }
    }
}

// MARK: - Member Balance Card

struct MemberBalanceCard: View {
    let user: User
    let balance: TimeInterval
    let group: Group

    private var timeGiven: TimeInterval {
        user.sharesGivenArray
            .filter { $0.groupId == group.id && $0.isConfirmed }
            .reduce(0) { $0 + $1.duration }
    }

    private var timeReceived: TimeInterval {
        user.sharesReceivedArray
            .filter { $0.groupId == group.id && $0.isConfirmed }
            .reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(user.avatarEmoji ?? "👤")
                    .font(.title2)

                Text("\(user.nickname ?? "사용자")님")
                    .font(.headline)

                Spacer()

                // Balance indicator (subtle)
                if balance != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: balance > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.caption)
                            .foregroundColor(balance > 0 ? Color(hex: "81C784") : Color(hex: "FF8A80"))

                        Text("\(Int(abs(balance) / 3600))시간")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("이번 달 나눈 시간")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(timeGiven / 3600))시간")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("받은 시간")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(timeReceived / 3600))시간")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            // Gentle action suggestion (NO SHAMING)
            if balance < -3600 {
                // User has received more
                Button(action: {
                    // Navigate to help requests
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("도움 줄 기회 보기")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "F6B352").opacity(0.2))
                    .foregroundColor(Color(hex: "F6B352"))
                    .cornerRadius(8)
                }
            } else if balance > 3600 {
                // User has given more
                Button(action: {
                    // Navigate to share history
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("최근 나눔 내역")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "4ECDC4").opacity(0.2))
                    .foregroundColor(Color(hex: "4ECDC4"))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let group = Group(context: context)
        group.name = "우리 가족"
        group.emoji = "👨‍👩‍👧‍👦"

        // Create sample users and memberships
        for i in 0..<3 {
            let user = User(context: context)
            user.id = UUID()
            user.nickname = "사용자\(i + 1)"
            user.avatarEmoji = ["👨", "👩", "👧"][i]

            let membership = GroupMembership(context: context)
            membership.user = user
            membership.group = group
            membership.isActive = true
        }

        return NavigationView {
            BalanceView(group: group)
        }
    }
}
