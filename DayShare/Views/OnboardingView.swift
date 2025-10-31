//
//  OnboardingView.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo/Icon placeholder
            Image(systemName: "clock.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(hex: "F6B352")) // Warm Amber from brand

            // App Name
            Text("DayShare")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.primary)

            Text("데이셰어")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.secondary)

            // Tagline (from Brand Identity)
            Text("시간을 함께 나누는 가장 부드러운 방법")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            // Sign In Buttons
            VStack(spacing: 16) {
                // Kakao Sign In (to be implemented)
                Button(action: {
                    Task {
                        await viewModel.signInWithKakao()
                    }
                }) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                        Text("카카오로 시작하기")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }

                // Apple Sign In
                Button(action: {
                    Task {
                        await viewModel.signInWithApple()
                    }
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Apple로 시작하기")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                // Anonymous (for testing)
                Button(action: {
                    Task {
                        await viewModel.signInAnonymously()
                    }
                }) {
                    Text("둘러보기")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)

            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 32)
            }

            // Privacy notice (PIPA compliance)
            Text("가입 시 이용약관 및 개인정보처리방침에 동의하게 됩니다")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
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

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
