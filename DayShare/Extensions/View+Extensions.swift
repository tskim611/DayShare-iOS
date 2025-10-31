//
//  View+Extensions.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import SwiftUI

extension View {
    // MARK: - Conditional Modifiers

    /// Applies a transform if condition is true
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Card Style

    /// Applies DayShare card style with rounded corners and shadow
    func cardStyle(backgroundColor: Color = Color(UIColor.secondarySystemBackground)) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Loading Overlay

    /// Shows loading overlay when isLoading is true
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                }
            }
        }
    }

    // MARK: - Empty State

    /// Shows empty state view when condition is true
    func emptyState(
        _ isEmpty: Bool,
        icon: String,
        title: String,
        description: String? = nil
    ) -> some View {
        self.overlay {
            if isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if let description = description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
        }
    }

    // MARK: - Keyboard Dismissal

    /// Adds tap gesture to dismiss keyboard
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }

    // MARK: - Brand Button Style

    /// Applies DayShare primary button style
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.brandPrimary : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(isEnabled ? 1.0 : 0.6)
    }

    /// Applies DayShare secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.brandPrimary.opacity(0.2))
            .foregroundColor(.brandPrimary)
            .cornerRadius(12)
    }
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.brandPrimary : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.brandPrimary.opacity(0.2))
            .foregroundColor(.brandPrimary)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
