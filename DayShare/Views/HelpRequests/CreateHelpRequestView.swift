//
//  CreateHelpRequestView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  Uses copy from DayShare-UX-Tone-Kit.md

import SwiftUI

struct CreateHelpRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HelpRequestViewModel()

    let group: Group
    let currentUser: User

    @State private var showingSuccess = false

    var body: some View {
        NavigationView {
            Form {
                // Description
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("편하게 요청해 보세요")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField(
                            "예: 퇴근길에 약 좀 가져다줄래요?",
                            text: $viewModel.requestDescription,
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                    }
                } header: {
                    Text("무엇이 필요한가요?")
                }

                // Estimated Duration (optional)
                Section {
                    HStack {
                        Picker("시간", selection: $viewModel.estimatedHours) {
                            ForEach(0..<12) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("시간")

                        Picker("분", selection: $viewModel.estimatedMinutes) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("분")
                    }
                } header: {
                    Text("예상 시간 (선택사항)")
                } footer: {
                    Text("도움을 주실 분이 참고할 수 있어요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Deadline (optional)
                Section {
                    Toggle("마감 시간 설정", isOn: $viewModel.useDeadline)

                    if viewModel.useDeadline {
                        DatePicker(
                            "언제까지",
                            selection: Binding(
                                get: { viewModel.neededByDate ?? Date() },
                                set: { viewModel.neededByDate = $0 }
                            ),
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                } header: {
                    Text("언제까지 필요한가요?")
                }

                // Privacy reminder
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(Color(hex: "4ECDC4"))
                        Text("이 요청은 그룹 멤버에게만 보입니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
            .navigationTitle("도움 요청하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("요청 보내기") {
                        viewModel.createHelpRequest(in: group, by: currentUser)
                        if viewModel.successMessage != nil {
                            showingSuccess = true
                        }
                    }
                    .disabled(viewModel.requestDescription.isEmpty)
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
            .alert("요청 완료", isPresented: $showingSuccess) {
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
}

struct CreateHelpRequestView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let user = User(context: context)
        user.nickname = "나"

        let group = Group(context: context)
        group.name = "우리 가족"

        return CreateHelpRequestView(group: group, currentUser: user)
    }
}
