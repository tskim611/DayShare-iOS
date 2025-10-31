//
//  CreateGroupView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GroupViewModel
    let currentUser: User

    // Emoji picker
    private let emojiOptions = ["👥", "👨‍👩‍👧‍👦", "🏠", "👶", "🍳", "🌱", "❤️", "🌸"]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Group Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("그룹 이름")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("예: 우리 가족, 육아 품앗이", text: $viewModel.newGroupName)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 8)

                    // Emoji Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("그룹 아이콘")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    Button(action: {
                                        viewModel.newGroupEmoji = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                            .padding(8)
                                            .background(
                                                viewModel.newGroupEmoji == emoji
                                                    ? Color(hex: "F6B352").opacity(0.3)
                                                    : Color.gray.opacity(0.1)
                                            )
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)

                } header: {
                    Text("기본 정보")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "4ECDC4"))
                            Text("믿을 수 있는 분들과만 그룹을 만드세요")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "eye.slash.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "4ECDC4"))
                            Text("이 정보는 그룹 멤버에게만 보입니다")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("그룹 만들기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("시작하기") {
                        viewModel.createGroup(currentUser: currentUser)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.newGroupName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let user = User(context: context)
        user.nickname = "테스트"

        return CreateGroupView(
            viewModel: GroupViewModel(),
            currentUser: user
        )
    }
}
