//
//  DataExportView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  PIPA Compliance: Right to access data

import SwiftUI
import CoreData

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    let user: User?

    @State private var isExporting = false
    @State private var exportComplete = false
    @State private var exportedData: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.brandPrimary)

                        Text("내 데이터 다운로드")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("DayShare에 저장된 모든 정보를 JSON 형식으로 다운로드할 수 있습니다")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 24)

                    // What's included
                    VStack(alignment: .leading, spacing: 16) {
                        Text("포함되는 정보")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            DataItemRow(icon: "person.fill", title: "프로필 정보", description: "닉네임, 아바타, 설정")
                            DataItemRow(icon: "person.3.fill", title: "그룹 멤버십", description: "참여 중인 모든 그룹")
                            DataItemRow(icon: "clock.arrow.circlepath", title: "나눔 기록", description: "주고받은 시간 기록")
                            DataItemRow(icon: "hand.raised.fill", title: "도움 요청", description: "생성한 요청 내역")
                            DataItemRow(icon: "bell.fill", title: "알림", description: "받은 알림 기록")
                            DataItemRow(icon: "list.bullet", title: "활동 로그", description: "계정 활동 내역")
                        }
                        .padding(.horizontal)
                    }

                    // PIPA Notice
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.brandAccent)
                            Text("개인정보보호법 준수")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Text("개인정보보호법(PIPA) 제35조에 따라 이용자는 언제든지 자신의 개인정보를 열람하고 사본을 받을 권리가 있습니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.brandAccent.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Export Button
                    if !exportComplete {
                        Button(action: {
                            exportData()
                        }) {
                            HStack {
                                if isExporting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("데이터 내보내기")
                                }
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 48)
                        .disabled(isExporting)
                    } else {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.balanceGreen)
                                Text("내보내기 완료")
                                    .fontWeight(.semibold)
                            }

                            Button(action: {
                                shareExportedData()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("공유하기")
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .padding(.horizontal, 48)
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("데이터 다운로드")
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

    // MARK: - Export Data

    private func exportData() {
        guard let user = user else { return }

        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            var data: [String: Any] = [:]

            // User info
            data["user"] = [
                "id": user.id?.uuidString ?? "",
                "nickname": user.nickname ?? "",
                "avatarEmoji": user.avatarEmoji ?? "",
                "language": user.language ?? "ko",
                "isPremium": user.isPremium,
                "createdAt": ISO8601DateFormatter().string(from: user.createdAt ?? Date())
            ]

            // Groups
            let groups = user.membershipsArray.compactMap { $0.group }
            data["groups"] = groups.map { group in
                [
                    "id": group.id?.uuidString ?? "",
                    "name": group.name ?? "",
                    "emoji": group.emoji ?? "",
                    "createdAt": ISO8601DateFormatter().string(from: group.createdAt ?? Date()),
                    "memberCount": group.activeMembers.count
                ]
            }

            // Shares
            data["shares"] = user.sharesGivenArray.map { share in
                [
                    "id": share.id?.uuidString ?? "",
                    "description": share.shareDescription ?? "",
                    "duration": share.duration,
                    "occurredAt": ISO8601DateFormatter().string(from: share.occurredAt ?? Date()),
                    "status": share.status ?? "",
                    "giver": share.giver?.nickname ?? "",
                    "receiver": share.receiver?.nickname ?? ""
                ]
            }

            // Convert to JSON
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    exportedData = jsonString
                    isExporting = false
                    exportComplete = true
                }
            }
        }
    }

    private func shareExportedData() {
        let filename = "dayshare_data_\(Date().timeIntervalSince1970).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try exportedData.write(to: tempURL, atomically: true, encoding: .utf8)

            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Failed to export data: \(error)")
        }
    }
}

struct DataItemRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.balanceGreen)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DataExportView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let user = User(context: context)
        user.nickname = "테스트"

        return DataExportView(user: user)
    }
}
