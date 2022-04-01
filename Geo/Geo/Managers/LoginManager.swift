//
//  LoginManager.swift
//  Geo
//
//  Created by William Svoboda on 3/29/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftUI

final class LoginManager: ObservableObject {
    
    @ObservedObject var settingsManager: SettingsManager
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    
    private var identityToken: String?
    
    private final let keychainHelper = KeychainHelper()
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }
    
    public func handleCredential(appleIDCredential: ASAuthorizationAppleIDCredential) {
        // First time signing in
        if let _ = appleIDCredential.email, let _ = appleIDCredential.fullName {
            do {
                try signUp(appleIDCredential: appleIDCredential)
            } catch {
                print(error)
            }
        } else {
            signIn(appleIDCredential: appleIDCredential)
        }
    }
    
    private func signUp(appleIDCredential: ASAuthorizationAppleIDCredential) throws {
        // Set current user and save information to keychain
        self.currentUser = User(id: appleIDCredential.user,
                           email: appleIDCredential.email!,
                           givenName: appleIDCredential.fullName?.givenName ?? "",
                           familyName: appleIDCredential.fullName?.familyName ?? "")
        cacheUserDetails(user: currentUser!)
        
        self.identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
        
        // Submit user data to server
        let encodedUser = try JSONEncoder().encode(currentUser)
        
        var components = URLComponents()
        components.scheme = settingsManager.scheme
        components.host = settingsManager.host
        components.port = settingsManager.port
        components.path = "/auth"
        
        var request = URLRequest(url: URL(string: "http://Williams-MacBook-Pro.local:6379/users")!)
        request.httpMethod = "POST"
        
        request.httpBody = encodedUser
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(identityToken ?? "ERROR", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print(error?.localizedDescription ?? "No data")
                return
            }
        }
        
        task.resume()
    }
    
    private func signIn(appleIDCredential: ASAuthorizationAppleIDCredential) {
        
    }
    
    private func cacheUserDetails(user: User) {
        keychainHelper.save(user.id, service: "user-id", account: "geo")
        keychainHelper.save(user.email, service: "user-email", account: "geo")
        keychainHelper.save(user.givenName, service: "user-given-name", account: "geo")
        keychainHelper.save(user.familyName, service: "user-family-name", account: "geo")
    }
}

private final class KeychainHelper {
    
    func save(_ data: Data, service: String, account: String) {
        
        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            
            // Update existing item
            SecItemUpdate(query, attributesToUpdate)
        }
    }
    
    func read(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}

extension KeychainHelper {
    
    func save<T>(_ item: T, service: String, account: String) where T : Codable {
        
        do {
            // Encode as JSON data and save in keychain
            let data = try JSONEncoder().encode(item)
            save(data, service: service, account: account)
            
        } catch {
            assertionFailure("Fail to encode item for keychain: \(error)")
        }
    }
    
    func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        
        // Read item data from keychain
        guard let data = read(service: service, account: account) else {
            return nil
        }
        
        // Decode JSON data to object
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }
}
