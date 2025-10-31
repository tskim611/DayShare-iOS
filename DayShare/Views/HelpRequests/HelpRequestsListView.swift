//
//  HelpRequestsListView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct HelpRequestsListView: View {
    @StateObject private var viewModel = HelpRequestViewModel()
    let group: Group
    let currentUser: User

    @State private var showingCreateRequest = false

    var openRequests: [HelpRequest] {
        viewModel.helpRequests.filter { $0.isOpen || $0.isClaimed }
    }

    var completedRequests: [HelpRequest] {
        viewModel.helpRequests.filter { $0.isCompleted }
    }

    var body: some View {
        List {
            // Open Requests
            Section {
                if openRequests.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("현재 도움 요청이 없어요")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("필요한 도움이 있으면 편하게 요청해 보세요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(openRequests, id: \.id) { request in
                        HelpRequestRow(
                            request: request,
                            currentUser: currentUser,
                            viewModel: viewModel
                        )
                    }
                }
            } header: {
                Text("진행 중인 요청")
            }

            // Completed Requests
            if !completedRequests.isEmpty {
                Section {
                    ForEach(completedRequests.prefix(5), id: \.id) { request in
                        HelpRequestRow(
                            request: request,
                            currentUser: currentUser,
                            viewModel: viewModel
                        )
                    }
                } header: {
                    Text("완료된 요청")
                }
            }
        }
        .navigationTitle("도움 요청")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingCreateRequest = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "F6B352"))
                }
            }
        }
        .sheet(isPresented: $showingCreateRequest) {
            CreateHelpRequestView(group: group, currentUser: currentUser)
        }
        .onAppear {
            viewModel.fetchHelpRequests(for: group)
        }
    }
}

// MARK: - Help Request Row

struct HelpRequestRow: View {
    let request: HelpRequest
    let currentUser: User
    @ObservedObject var viewModel: HelpRequestViewModel

    @State private var showingClaimConfirmation = false

    private var isMyRequest: Bool {
        request.requesterId == currentUser.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Requester info
            HStack {
                Text(request.requester?.avatarEmoji ?? "👤")
                    .font(.title3)

                Text("\(request.requester?.nickname ?? "누군가")님의 요청")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // Status badge
                StatusBadge(status: request.status ?? "unknown")
            }

            // Description
            Text(request.requestDescription ?? "도움 요청")
                .font(.body)

            // Details
            HStack(spacing: 16) {
                // Estimated duration
                if request.estimatedDuration > 0 {
                    Label(
                        "\(Int(request.estimatedDuration / 3600))시간",
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                // Deadline
                if let neededBy = request.neededBy {
                    Label(
                        neededBy,
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            // Action buttons
            if request.isOpen && !isMyRequest {
                Button(action: {
                    showingClaimConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("도와줄게요")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(hex: "F6B352"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if request.isClaimed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "81C784"))
                    if let claimedBy = request.claimedBy {
                        // Get claimer's name
                        Text("도와주기로 했어요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else if request.isCompleted {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: "81C784"))
                    Text("완료")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let completedAt = request.completedAt {
                        Text(completedAt, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Cancel button for requester
            if isMyRequest && request.isOpen {
                Button(role: .destructive, action: {
                    viewModel.cancelHelpRequest(request)
                }) {
                    Text("요청 취소")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
        .alert("도움 확인", isPresented: $showingClaimConfirmation) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                Task {
                    await viewModel.claimHelpRequest(request, by: currentUser)
                }
            }
        } message: {
            Text("이 요청을 도와주시겠어요?")
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(statusText)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }

    private var statusText: String {
        switch status {
        case "open": return "대기 중"
        case "claimed": return "진행 중"
        case "completed": return "완료"
        case "cancelled": return "취소"
        default: return status
        }
    }

    private var statusColor: Color {
        switch status {
        case "open": return Color(hex: "F6B352")
        case "claimed": return Color(hex: "4ECDC4")
        case "completed": return Color(hex: "81C784")
        case "cancelled": return .gray
        default: return .gray
        }
    }
}

struct HelpRequestsListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let user = User(context: context)
        user.nickname = "나"

        let group = Group(context: context)
        group.name = "우리 가족"

        return NavigationView {
            HelpRequestsListView(group: group, currentUser: user)
        }
    }
}
