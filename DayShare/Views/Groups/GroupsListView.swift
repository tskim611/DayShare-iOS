//
//  GroupsListView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct GroupsListView: View {
    @StateObject private var viewModel = GroupViewModel()
    @EnvironmentObject private var authViewModel: AuthenticationViewModel

    @State private var showingCreateGroup = false
    @State private var showingJoinGroup = false
    @State private var inviteCode = ""

    var body: some View {
        NavigationView {
            Group {
                if viewModel.groups.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Groups list
                    groupsList
                }
            }
            .navigationTitle("내 그룹")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            showingCreateGroup = true
                        }) {
                            Label("그룹 만들기", systemImage: "plus.circle")
                        }

                        Button(action: {
                            showingJoinGroup = true
                        }) {
                            Label("초대 코드로 참여", systemImage: "number")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateGroup) {
                if let currentUser = authViewModel.currentUser {
                    CreateGroupView(viewModel: viewModel, currentUser: currentUser)
                }
            }
            .sheet(isPresented: $showingJoinGroup) {
                joinGroupSheet
            }
            .onAppear {
                viewModel.fetchGroups()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 12) {
                Text("아직 그룹이 없어요")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("가족, 친구, 가까운 이웃과 함께\n도움을 주고받은 시간을 기록해요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                Button(action: {
                    showingCreateGroup = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("그룹 만들기")
                    }
                    .fontWeight(.semibold)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 48)

                Button(action: {
                    showingJoinGroup = true
                }) {
                    HStack {
                        Image(systemName: "number")
                        Text("초대 코드로 참여")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal, 48)
            }

            Spacer()
        }
    }

    // MARK: - Groups List

    private var groupsList: some View {
        List {
            ForEach(viewModel.groups, id: \.id) { group in
                NavigationLink(destination: GroupDetailView(group: group)) {
                    GroupRowView(group: group)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Join Group Sheet

    private var joinGroupSheet: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("초대 코드")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("8자리 코드 입력", text: $inviteCode)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.allCharacters)
                            .onChange(of: inviteCode) { newValue in
                                inviteCode = newValue.uppercased()
                            }
                    }
                } header: {
                    Text("그룹 참여")
                } footer: {
                    Text("친구나 가족에게 받은 8자리 초대 코드를 입력하세요")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("초대 코드로 참여")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        inviteCode = ""
                        showingJoinGroup = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("참여") {
                        if let currentUser = authViewModel.currentUser {
                            Task {
                                await viewModel.joinGroup(withCode: inviteCode, currentUser: currentUser)
                                if viewModel.errorMessage == nil {
                                    inviteCode = ""
                                    showingJoinGroup = false
                                }
                            }
                        }
                    }
                    .disabled(inviteCode.count != 8)
                    .fontWeight(.semibold)
                }
            }
            .loadingOverlay(viewModel.isLoading)
        }
    }
}

// MARK: - Group Row View

struct GroupRowView: View {
    let group: Group

    var body: some View {
        HStack(spacing: 16) {
            // Group emoji
            Text(group.emoji ?? "👥")
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name ?? "그룹")
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                    Text("\(group.activeMembers.count)명")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if group.totalTimeExchanged > 0 {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text("\(Int(group.totalTimeExchanged / 3600))시간")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Activity indicator
            if let lastActivity = group.lastActivityAt {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(TimeFormatters.formatRelativeDate(lastActivity))
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if group.confirmedShares.count > 0 {
                        Text("\(group.confirmedShares.count)건")
                            .font(.caption2)
                            .foregroundColor(.brandAccent)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct GroupsListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsListView()
            .environmentObject(AuthenticationViewModel())
    }
}
