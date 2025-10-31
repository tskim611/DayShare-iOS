//
//  AddShareView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  Uses copy from DayShare-UX-Tone-Kit.md

import SwiftUI

struct AddShareView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ShareViewModel()

    let group: Group
    let currentUser: User

    @State private var showingSuccess = false

    var body: some View {
        NavigationView {
            Form {
                // Who gave help
                Section {
                    Picker("누가 도움을 주었나요?", selection: $viewModel.selectedGiver) {
                        Text("선택하기").tag(nil as User?)
                        ForEach(group.activeMembers, id: \.id) { membership in
                            if let user = membership.user {
                                Text("\(user.avatarEmoji ?? "👤") \(user.nickname ?? "사용자")")
                                    .tag(user as User?)
                            }
                        }
                    }
                } header: {
                    Text("도움을 준 사람")
                }

                // Who received help
                Section {
                    Picker("누구를 도와주었나요?", selection: $viewModel.selectedReceiver) {
                        Text("선택하기").tag(nil as User?)
                        ForEach(group.activeMembers, id: \.id) { membership in
                            if let user = membership.user {
                                Text("\(user.avatarEmoji ?? "👤") \(user.nickname ?? "사용자")")
                                    .tag(user as User?)
                            }
                        }
                    }
                } header: {
                    Text("도움을 받은 사람")
                }

                // Description
                Section {
                    TextField(
                        "예: 아이 돌봄, 장보기 대신, 병원 동행, 집안일 등",
                        text: $viewModel.description,
                        axis: .vertical
                    )
                    .lineLimit(2...4)

                    // Category picker (optional)
                    Picker("카테고리 (선택사항)", selection: $viewModel.selectedCategory) {
                        Text("선택 안 함").tag(nil as String?)
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(viewModel.categoryLabels[category] ?? category)
                                .tag(category as String?)
                        }
                    }
                } header: {
                    Text("어떤 도움이었나요?")
                }

                // Duration
                Section {
                    HStack {
                        Picker("시간", selection: $viewModel.hours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("시간")

                        Picker("분", selection: $viewModel.minutes) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("분")
                    }
                } header: {
                    Text("얼마나 걸렸나요?")
                } footer: {
                    if viewModel.hours == 0 && viewModel.minutes == 0 {
                        Text("시간을 입력해 주세요")
                            .foregroundColor(.red)
                    }
                }

                // Date
                Section {
                    DatePicker(
                        "날짜",
                        selection: $viewModel.selectedDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                } header: {
                    Text("언제였나요?")
                }

                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("시간 나눔 기록하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("기록 완료") {
                        viewModel.createShare(in: group, createdBy: currentUser)
                        if viewModel.successMessage != nil {
                            showingSuccess = true
                        }
                    }
                    .disabled(!canSubmit)
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
            .alert("기록되었습니다", isPresented: $showingSuccess) {
                Button("확인") {
                    dismiss()
                }
            } message: {
                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                }
            }
        }
    }

    // MARK: - Validation

    private var canSubmit: Bool {
        viewModel.selectedGiver != nil &&
        viewModel.selectedReceiver != nil &&
        !viewModel.description.isEmpty &&
        (viewModel.hours > 0 || viewModel.minutes > 0)
    }
}

struct AddShareView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let user = User(context: context)
        user.nickname = "나"

        let group = Group(context: context)
        group.name = "우리 가족"

        return AddShareView(group: group, currentUser: user)
    }
}
