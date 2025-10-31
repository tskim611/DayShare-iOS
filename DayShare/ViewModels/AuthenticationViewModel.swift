//
//  AuthenticationViewModel.swift
//  DayShare
//
//  Created on 2025-10-31
//  Copyright © 2025 DayShare. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false

    // MARK: - Services

    private let firebaseService = FirebaseService.shared
    private let persistenceController = PersistenceController.shared

    // MARK: - Initialization

    init() {
        checkAuthenticationStatus()
    }

    // MARK: - Authentication Methods

    func checkAuthenticationStatus() {
        isAuthenticated = firebaseService.isUserAuthenticated()
        if isAuthenticated {
            loadCurrentUser()
        }
    }

    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await Auth.auth().signInAnonymously()
            await createLocalUser(authProvider: "anonymous", authProviderId: result.user.uid)
            isAuthenticated = true
        } catch {
            errorMessage = "로그인에 실패했습니다. 다시 시도해 주세요."
            print("Anonymous sign-in error: \(error)")
        }

        isLoading = false
    }

    // Sign in with Kakao (to be implemented with KakaoSDK)
    func signInWithKakao() async {
        // Implementation pending KakaoSDK integration
        isLoading = true
        errorMessage = nil
        // TODO: Implement Kakao authentication
        isLoading = false
    }

    // Sign in with Apple
    func signInWithApple() async {
        // Implementation pending Apple Sign-In
        isLoading = true
        errorMessage = nil
        // TODO: Implement Apple Sign-In
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = "로그아웃에 실패했습니다."
            print("Sign out error: \(error)")
        }
    }

    // MARK: - Private Methods

    private func loadCurrentUser() {
        guard let userId = firebaseService.getCurrentUserId() else { return }

        let context = persistenceController.container.viewContext
        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "authProviderID == %@", userId)

        do {
            let users = try context.fetch(fetchRequest)
            currentUser = users.first
        } catch {
            print("Failed to fetch current user: \(error)")
        }
    }

    private func createLocalUser(authProvider: String, authProviderId: String) async {
        let context = persistenceController.container.viewContext

        let user = User(context: context)
        user.id = UUID()
        user.authProvider = authProvider
        user.authProviderID = authProviderId
        user.nickname = "사용자" // Default nickname
        user.language = "ko"
        user.notificationsEnabled = true
        user.isPremium = false
        user.createdAt = Date()
        user.lastActiveAt = Date()

        persistenceController.save()
        currentUser = user
    }
}
