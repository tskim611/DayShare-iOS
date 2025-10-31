//
//  PrivacyPolicyView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("개인정보처리방침")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                Text("DayShare는 개인정보보호법(PIPA)을 준수하며, 이용자의 개인정보를 중요하게 보호합니다.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Placeholder content - would be replaced with actual policy
                Group {
                    PolicySection(
                        title: "1. 수집하는 개인정보",
                        content: "• 닉네임 (선택)\n• 아바타 이모지 (선택)\n• 그룹 멤버십 정보\n• 시간 나눔 기록"
                    )

                    PolicySection(
                        title: "2. 수집하지 않는 정보",
                        content: "• 실명\n• 전화번호 (초대 후 즉시 삭제)\n• 위치 정보\n• 사진"
                    )

                    PolicySection(
                        title: "3. 개인정보의 보유 및 이용 기간",
                        content: "이용자가 계정을 삭제할 때까지 보관하며, 삭제 요청 시 30일의 유예 기간 후 완전히 삭제됩니다."
                    )

                    PolicySection(
                        title: "4. 이용자의 권리",
                        content: "• 개인정보 열람 및 다운로드\n• 개인정보 정정\n• 개인정보 삭제\n• 처리 정지 요구"
                    )
                }

                Text("전체 개인정보처리방침은 DayShare-PIPA-Compliance.md를 참고하세요.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle("개인정보처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("이용약관")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                PolicySection(
                    title: "제1조 (목적)",
                    content: "이 약관은 DayShare가 제공하는 시간 나눔 기록 서비스의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다."
                )

                PolicySection(
                    title: "제2조 (서비스의 내용)",
                    content: "DayShare는 이용자 간의 시간 나눔을 기록하고 관리하는 서비스를 제공합니다. 모든 기록은 비공개 그룹 내에서만 공유됩니다."
                )

                Text("전체 이용약관은 DayShare-TOS-and-Privacy-Templates.md를 참고하세요.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle("이용약관")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("버전")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Text("DayShare는 시간을 함께 나누는 가장 부드러운 방법입니다.")
                    .font(.subheadline)

                Text("가족, 친구, 가까운 이웃과 주고받은 도움을 기록하고, 서로의 마음을 확인하세요.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("앱 소개")
            }

            Section {
                HStack {
                    Text("개발")
                    Spacer()
                    Text("DayShare Team")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("문의")
                    Spacer()
                    Text("support@dayshare.app")
                        .font(.caption)
                        .foregroundColor(.brandAccent)
                }
            } header: {
                Text("정보")
            }
        }
        .navigationTitle("앱 정보")
    }
}

struct PolicySection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyView()
        }
    }
}
