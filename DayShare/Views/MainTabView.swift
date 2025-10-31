//
//  MainTabView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Groups Tab
            GroupsListView()
                .tabItem {
                    Label("그룹", systemImage: "person.3.fill")
                }
                .tag(0)

            // Add Share Tab (center, emphasized)
            AddShareView()
                .tabItem {
                    Label("나눔 기록", systemImage: "plus.circle.fill")
                }
                .tag(1)

            // Help Requests Tab
            HelpRequestsView()
                .tabItem {
                    Label("도움 요청", systemImage: "hand.raised.fill")
                }
                .tag(2)

            // Profile/Settings Tab
            ProfileView()
                .tabItem {
                    Label("설정", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "F6B352")) // Warm Amber
    }
}

// MARK: - Placeholder Views

struct GroupsListView: View {
    var body: some View {
        NavigationView {
            List {
                Text("그룹 목록이 여기에 표시됩니다")
            }
            .navigationTitle("내 그룹")
        }
    }
}

struct AddShareView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("시간 나눔을 기록하세요")
                    .font(.headline)
            }
            .navigationTitle("나눔 기록하기")
        }
    }
}

struct HelpRequestsView: View {
    var body: some View {
        NavigationView {
            List {
                Text("도움 요청이 여기에 표시됩니다")
            }
            .navigationTitle("도움 요청")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section("프로필") {
                    Text("프로필 정보")
                }

                Section("설정") {
                    Text("알림 설정")
                    Text("개인정보처리방침")
                    Text("이용약관")
                }

                Section {
                    Button("로그아웃", role: .destructive) {
                        // Handle logout
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
