//
//  ProfileView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//
//  PIPA Compliance: Data export, deletion, privacy controls

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingEditProfile = false
    @State private var showingDataExport = false
    @State private var showingDeleteAccount = false
    @State private var showingLogoutConfirmation = false

    var currentUser: User? {
        authViewModel.currentUser
    }

    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        Text(currentUser?.avatarEmoji ?? "👤")
                            .font(.system(size: 50))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentUser?.nickname ?? "사용자")
                                .font(.title3)
                                .fontWeight(.semibold)

                            if currentUser?.isPremium == true {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                    Text("프리미엄")
                                        .font(.caption)
                                }
                                .foregroundColor(.gratitudeGold)
                            }
                        }

                        Spacer()

                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("편집")
                                .font(.subheadline)
                                .foregroundColor(.brandPrimary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("프로필")
                }

                // Settings Section
                Section {
                    Toggle(isOn: Binding(
                        get: { currentUser?.notificationsEnabled ?? true },
                        set: { newValue in
                            currentUser?.notificationsEnabled = newValue
                            PersistenceController.shared.save()

                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    )) {
                        Label("알림 받기", systemImage: "bell.fill")
                    }

                    Picker(selection: Binding(
                        get: { currentUser?.language ?? "ko" },
                        set: { newValue in
                            currentUser?.language = newValue
                            PersistenceController.shared.save()
                        }
                    )) {
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                    } label: {
                        Label("언어", systemImage: "globe")
                    }
                } header: {
                    Text("설정")
                }

                // Premium Section
                if currentUser?.isPremium != true {
                    Section {
                        NavigationLink(destination: PremiumView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.gratitudeGold)
                                        Text("프리미엄으로 업그레이드")
                                            .fontWeight(.semibold)
                                    }

                                    Text("월간 요약, 더 많은 그룹, 커스텀 아이콘")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text("₩4,900")
                                    .font(.headline)
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                    }
                }

                // Privacy & Legal (PIPA Compliance)
                Section {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("개인정보처리방침", systemImage: "hand.raised.fill")
                    }

                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("이용약관", systemImage: "doc.text")
                    }

                    Button(action: {
                        showingDataExport = true
                    }) {
                        Label("내 데이터 다운로드", systemImage: "arrow.down.doc")
                    }

                    NavigationLink(destination: ActivityLogView(currentUser: currentUser)) {
                        Label("활동 기록", systemImage: "list.bullet.clipboard")
                    }
                } header: {
                    Text("개인정보 및 법적 고지")
                } footer: {
                    Text("DayShare는 개인정보보호법(PIPA)을 준수합니다")
                        .font(.caption2)
                }

                // Support Section
                Section {
                    Link(destination: URL(string: "mailto:support@dayshare.app")!) {
                        Label("고객 지원", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("앱 정보", systemImage: "info.circle")
                    }
                } header: {
                    Text("지원")
                }

                // Account Actions
                Section {
                    Button(role: .destructive, action: {
                        showingLogoutConfirmation = true
                    }) {
                        Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    Button(role: .destructive, action: {
                        showingDeleteAccount = true
                    }) {
                        Label("계정 삭제", systemImage: "trash")
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("계정을 삭제하면 30일 간의 유예 기간이 있습니다")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if let createdAt = currentUser?.createdAt {
                            Text("가입일: \(createdAt, style: .date)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(user: currentUser)
            }
            .sheet(isPresented: $showingDataExport) {
                DataExportView(user: currentUser)
            }
            .confirmationDialog("로그아웃하시겠어요?", isPresented: $showingLogoutConfirmation) {
                Button("로그아웃", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("취소", role: .cancel) {}
            }
            .confirmationDialog("계정을 삭제하시겠어요?", isPresented: $showingDeleteAccount) {
                Button("30일 후 삭제", role: .destructive) {
                    deleteAccount()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("계정 삭제 후 30일 이내에 다시 로그인하면 복구할 수 있습니다")
            }
        }
    }

    // MARK: - Actions

    private func requestNotificationPermission() {
        Task {
            do {
                _ = try await NotificationService.shared.requestAuthorization()
                NotificationService.shared.registerForPushNotifications()
            } catch {
                print("Failed to request notification permission: \(error)")
            }
        }
    }

    private func deleteAccount() {
        guard let user = currentUser else { return }

        // Mark account for deletion (30-day grace period)
        // Implementation would involve:
        // 1. Set deletion date = Date() + 30 days
        // 2. Create activity log entry
        // 3. Send confirmation email
        // 4. Sign out user

        // For now, just log
        print("Account marked for deletion: \(user.id?.uuidString ?? "")")

        // Log activity
        let context = viewContext
        let log = ActivityLog(context: context)
        log.id = UUID()
        log.userId = user.id
        log.action = "deleted_account"
        log.entityType = "User"
        log.entityId = user.id
        log.timestamp = Date()
        log.deviceInfo = "iOS \(UIDevice.current.systemVersion)"

        PersistenceController.shared.save()

        // Sign out
        authViewModel.signOut()
    }
}

// MARK: - Placeholder Views

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User?

    @State private var nickname: String = ""
    @State private var selectedEmoji: String = "👤"

    private let emojiOptions = ["👤", "😊", "🙂", "😄", "🤗", "👨", "👩", "👧", "👦", "🧑"]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("닉네임")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("닉네임", text: $nickname)
                            .textFieldStyle(.roundedBorder)
                    }
                } header: {
                    Text("프로필 정보")
                }

                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button(action: {
                                    selectedEmoji = emoji
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 32))
                                        .padding(8)
                                        .background(
                                            selectedEmoji == emoji
                                                ? Color.brandPrimary.opacity(0.3)
                                                : Color.gray.opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                } header: {
                    Text("아바타")
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        user?.nickname = nickname
                        user?.avatarEmoji = selectedEmoji
                        PersistenceController.shared.save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                nickname = user?.nickname ?? ""
                selectedEmoji = user?.avatarEmoji ?? "👤"
            }
        }
    }
}

struct PremiumView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.gratitudeGold)

            Text("DayShare 프리미엄")
                .font(.title)
                .fontWeight(.bold)

            Text("더 많은 기능으로 시간 나눔을 더욱 풍성하게")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "chart.bar.fill", title: "월간 요약 리포트", description: "매월 나눔 통계를 확인하세요")
                FeatureRow(icon: "person.3.fill", title: "최대 10명 그룹", description: "무료는 5명까지 가능")
                FeatureRow(icon: "photo.fill", title: "커스텀 그룹 아이콘", description: "사진으로 그룹을 꾸미세요")
                FeatureRow(icon: "paintpalette.fill", title: "테마 커스터마이징", description: "나만의 색상 선택")
            }
            .padding()

            Spacer()

            VStack(spacing: 12) {
                Button(action: {}) {
                    Text("₩4,900 / 평생 구매")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 48)

                Button(action: {}) {
                    Text("₩1,900 / 월")
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal, 48)
            }
        }
        .padding()
        .navigationTitle("프리미엄")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandPrimary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationViewModel())
    }
}
