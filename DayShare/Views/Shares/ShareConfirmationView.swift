//
//  ShareConfirmationView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  Confirmation flow for pending shares with thank you notes

import SwiftUI

struct ShareConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ShareViewModel()

    let share: Share
    let currentUser: User

    @State private var thankYouNote = ""
    @State private var showingDispute = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text(share.giver?.avatarEmoji ?? "👤")
                            .font(.system(size: 60))

                        Text("\(share.giver?.nickname ?? "누군가")님께서\n도움을 주셨나요?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    // Share Details
                    VStack(spacing: 16) {
                        DetailRow(label: "일시", value: share.occurredAt != nil ? TimeFormatters.formatDateTime(share.occurredAt!) : "")
                        DetailRow(label: "내용", value: share.shareDescription ?? "")
                        DetailRow(label: "시간", value: TimeFormatters.formatDuration(share.duration))

                        if let category = share.category {
                            DetailRow(label: "카테고리", value: ShareViewModel().categoryLabels[category] ?? category)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Thank You Note
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("감사 메시지 (선택)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(thankYouNote.count)/150")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        TextField("고마운 마음을 전해보세요", text: $thankYouNote, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...5)
                    }
                    .padding(.horizontal)

                    // Quick Thank You Suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(thankYouSuggestions, id: \.self) { suggestion in
                                Button(action: {
                                    thankYouNote = suggestion
                                }) {
                                    Text(suggestion)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.brandPrimary.opacity(0.1))
                                        .foregroundColor(.brandPrimary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 32)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            confirmShare()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("맞아요, 고마워요")
                            }
                            .fontWeight(.semibold)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 48)

                        Button(action: {
                            showingDispute = true
                        }) {
                            Text("내용이 다른 것 같아요")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("나눔 확인")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("나중에") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("내용이 맞지 않나요?", isPresented: $showingDispute) {
                Button("대화로 해결하기") {
                    // Could open a chat or messaging feature
                    dismiss()
                }
                Button("기록 거부", role: .destructive) {
                    disputeShare()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("그룹원과 직접 대화하여 해결하는 것을 권장합니다")
            }
            .loadingOverlay(viewModel.isLoading)
        }
    }

    // MARK: - Suggestions

    private let thankYouSuggestions = [
        "정말 고마워요!",
        "큰 도움이 되었어요",
        "덕분에 편했어요",
        "감사합니다 💛"
    ]

    // MARK: - Actions

    private func confirmShare() {
        viewModel.confirmShare(share, by: currentUser, thankYouNote: thankYouNote.isEmpty ? nil : thankYouNote)
        dismiss()
    }

    private func disputeShare() {
        share.status = "disputed"
        share.updatedAt = Date()
        PersistenceController.shared.save()
        dismiss()
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ShareConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let user1 = User(context: context)
        user1.id = UUID()
        user1.nickname = "민수"
        user1.avatarEmoji = "👨"

        let user2 = User(context: context)
        user2.id = UUID()
        user2.nickname = "지은"
        user2.avatarEmoji = "👩"

        let share = Share(context: context)
        share.id = UUID()
        share.shareDescription = "아이 돌봄"
        share.duration = 7200 // 2 hours
        share.occurredAt = Date()
        share.status = "pending"
        share.giver = user1
        share.receiver = user2

        return ShareConfirmationView(share: share, currentUser: user2)
    }
}
