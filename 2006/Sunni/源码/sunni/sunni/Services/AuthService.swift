//
//  AuthService.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var authState = AuthState()
    
    // We use KeychainHelper.standard because that's what we updated calls to
    // But original file had private keychainHelper = KeychainHelper.shared
    // Let's stick to KeychainHelper.shared or check if .standard exists in KeychainHelper
    // KeychainHelper normally is shared. Let's assume shared based on previous views.
    private let keychainHelper = KeychainHelper.shared
    
    private init() {
        _ = checkAutoLogin()
    }
    
    // MARK: - Auto Login
    func checkAutoLogin() -> Bool {
        guard UserDefaults.standard.bool(forKey: "is_logged_in") else { return false }
        
        if let token = KeychainHelper.shared.loadString(key: "access_token"),
           let userIdString = KeychainHelper.shared.loadString(key: "user_id"),
           let userId = UUID(uuidString: userIdString) {
            
            print("Auto-login found token and userId: \(userId)")
            
            // Find user (mock)
            if let user = MockDataService.shared.mockUsers.first(where: { $0.id == userId }) {
                var updatedUser = user
                // Load saved coin balance
                updatedUser.coinBalance = loadCoinBalance(for: userId)
                self.authState = AuthState(isAuthenticated: true, currentUser: updatedUser, authToken: token)
                return true
            } else {
                // Fallback for demo
                var user = User(
                    id: userId,
                    email: "user@example.com",
                    username: "User",
                    displayName: "Welcome Back",
                    avatarURL: nil,
                    bio: nil,
                    followerCount: 0,
                    followingCount: 0,
                    postCount: 0
                )
                user.coinBalance = loadCoinBalance(for: userId)
                self.authState = AuthState(isAuthenticated: true, currentUser: user, authToken: token)
                return true
            }
        }
        return false
    }
    
    // MARK: - Email Check
    func checkEmailExists(_ email: String) -> Bool {
        return MockDataService.shared.checkEmailExists(email)
    }
    
    // MARK: - Login
    func login(email: String, password: String, rememberMe: Bool = true, completion: @escaping (Bool) -> Void) {
        // Mock login
        if let user = MockDataService.shared.mockUsers.first(where: { $0.email.lowercased() == email.lowercased() }) {
            let token = UUID().uuidString
            var updatedUser = user
            // Load saved coin balance
            updatedUser.coinBalance = loadCoinBalance(for: user.id)
            let newState = AuthState(isAuthenticated: true, currentUser: updatedUser, authToken: token)
            
            DispatchQueue.main.async {
                self.authState = newState
                if rememberMe {
                    self.saveAuthState(token: token, userId: user.id)
                }
                NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("PostsUpdated"), object: nil)
                completion(true)
            }
        } else {
            // Demo fallback
            let hash = abs(email.hashValue)
            let userId = UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", hash % 1000000000000)) ?? UUID()
            
            var user = User(
                id: userId,
                email: email,
                username: email.components(separatedBy: "@").first ?? "user",
                displayName: "User",
                avatarURL: nil,
                bio: "New user",
                followerCount: 0,
                followingCount: 0,
                postCount: 0
            )
             user.coinBalance = loadCoinBalance(for: userId)
             let token = UUID().uuidString
             let newState = AuthState(isAuthenticated: true, currentUser: user, authToken: token)
             
             DispatchQueue.main.async {
                 self.authState = newState
                 if rememberMe {
                     self.saveAuthState(token: token, userId: user.id)
                 }
                 NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
                 NotificationCenter.default.post(name: NSNotification.Name("PostsUpdated"), object: nil)
                 completion(true)
             }
        }
    }
    
    private func saveAuthState(token: String, userId: UUID) {
        print("Saving auth state: token=\(token), userId=\(userId)")
        _ = KeychainHelper.shared.save(key: "access_token", value: token)
        _ = KeychainHelper.shared.save(key: "user_id", value: userId.uuidString)
        UserDefaults.standard.set(true, forKey: "is_logged_in")
    }
    
    // MARK: - Register
    func register(email: String, username: String, displayName: String, password: String, completion: @escaping (Bool) -> Void) {
        let newUser = User(
            id: UUID(),
            email: email,
            username: username,
            displayName: displayName,
             avatarURL: nil, bio: nil, followerCount: 0, followingCount: 0, postCount: 0
        )
        
        let token = UUID().uuidString
        let newState = AuthState(isAuthenticated: true, currentUser: newUser, authToken: token)
        
        DispatchQueue.main.async {
            self.authState = newState
            self.saveAuthState(token: token, userId: newUser.id)
            NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("PostsUpdated"), object: nil)
            completion(true)
        }
    }
    
    // MARK: - Logout
    func logout() {
        authState.isAuthenticated = false
        authState.currentUser = nil
        authState.authToken = nil
        
        _ = KeychainHelper.shared.delete(key: "access_token")
        _ = KeychainHelper.shared.delete(key: "user_id")
        UserDefaults.standard.set(false, forKey: "is_logged_in")
    }
    
    // MARK: - Delete Account
    func deleteAccount() {
        logout()
    }
    
    // MARK: - Coin Balance Persistence
    func saveCoinBalance(_ balance: Int, for userId: UUID) {
        let key = "coin_balance_\(userId.uuidString)"
        UserDefaults.standard.set(balance, forKey: key)
        UserDefaults.standard.synchronize()
        print("💰 Saved coin balance: \(balance) for user: \(userId)")
    }
    
    func loadCoinBalance(for userId: UUID) -> Int {
        let key = "coin_balance_\(userId.uuidString)"
        let balance = UserDefaults.standard.integer(forKey: key)
        print("💰 Loaded coin balance: \(balance) for user: \(userId)")
        return balance
    }
}
