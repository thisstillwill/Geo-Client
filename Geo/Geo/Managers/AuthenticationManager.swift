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

enum AuthenticationError: Error {
    case missingCredentials
    case invalidCredentials
    case badResponse
}

final class AuthenticationManager: ObservableObject {
    
    @ObservedObject var settingsManager: SettingsManager
    @Published var currentUser: User?
    @Published var refreshToken: String?
    @Published var isSignedIn = false
    
    private final let keychainHelper = KeychainHelper()
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }
    
    // Sign up a new user
    func signUp(appleIDCredential: ASAuthorizationAppleIDCredential, restoringUser: Bool) async throws {
        // Set current user and save information to keychain as appropriate
        var user: User
        if restoringUser {
            user = keychainHelper.read(service: "user", account: "geo", type: User.self)!
        } else {
            user = User(id: appleIDCredential.user,
                        email: appleIDCredential.email!,
                        givenName: appleIDCredential.fullName?.givenName ?? "",
                        familyName: appleIDCredential.fullName?.familyName ?? "")
            keychainHelper.save(user, service: "user", account: "geo")
        }
        self.currentUser = user
        
        // Prepare API request
        guard let identityToken = appleIDCredential.identityToken else { throw AuthenticationError.missingCredentials }
        let identityTokenString = String(data: identityToken, encoding: .utf8)
        let encodedUser = try JSONEncoder().encode(user)
        var components = URLComponents()
        components.scheme = settingsManager.scheme
        components.host = settingsManager.host
        components.port = settingsManager.port
        components.path = "/users"
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = encodedUser
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(identityTokenString, forHTTPHeaderField: "Authorization")
        
        // Submit request to server and validate response
        let (data, response) = try await URLSession.shared.data(for: request)
        let refreshToken = try JSONDecoder().decode(TokenResponse.self, from: data)
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw AuthenticationError.invalidCredentials
        }
        
        DispatchQueue.main.async {
            self.isSignedIn = true
            self.refreshToken = refreshToken.token
        }
        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else {
//                print(error?.localizedDescription ?? "No data")
//                return
//            }
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                print(error?.localizedDescription ?? "No data")
//                return
//            }
//            do {
//                let refreshToken = try JSONDecoder().decode(TokenResponse.self, from: data)
//                self.keychainHelper.save(refreshToken.token, service: "refresh-token", account: "geo")
//                DispatchQueue.main.async {
//                    self.refreshToken = refreshToken.token
//                    self.isSignedIn = true
//                }
//            } catch let error {
//                print(error)
//            }
//        }
//
//        task.resume()
    }
    
    // Attempt to restore an existing authentication session
    func signIn() async throws {
        // Retrieve credentials from keychain
        guard let refreshToken = keychainHelper.read(service: "refresh-token", account: "geo", type: String.self) else {
            throw AuthenticationError.missingCredentials
        }
        guard let user = keychainHelper.read(service: "user", account: "geo", type: User.self) else {
            throw AuthenticationError.missingCredentials
        }
        
        // Prepare API request
        let encodedId = try JSONEncoder().encode(["id": user.id])
        var components = URLComponents()
        components.scheme = settingsManager.scheme
        components.host = settingsManager.host
        components.port = settingsManager.port
        components.path = "/session"
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = encodedId
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(refreshToken, forHTTPHeaderField: "Authorization")
        
        // Submit request to server and validate response
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw AuthenticationError.invalidCredentials
        }
        
        DispatchQueue.main.async {
            self.isSignedIn = true
            self.currentUser = user
        }
    }
    
    // Sign in a returning user
    func signIn(appleIDCredential: ASAuthorizationAppleIDCredential) throws {
        // Prepare API request
        guard let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
            throw AuthenticationError.invalidCredentials
        }
        let encodedId = try JSONEncoder().encode(["id": appleIDCredential.user])
        var components = URLComponents()
        components.scheme = settingsManager.scheme
        components.host = settingsManager.host
        components.port = settingsManager.port
        components.path = "/auth"
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = encodedId
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(identityToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            guard (200...299).contains(response.statusCode) else {
                if response.statusCode == 404 {
                    
                        print("Trying to sign up again!!!")
                        Task {
                            do {
                                try await self.signUp(appleIDCredential: appleIDCredential, restoringUser: true)
                            } catch {
                                print("Weird error")
                                return
                            }
                        }
                    
                    
                }
                print("Unknown server error!")
                return
            }
            do {
                let refreshToken = try JSONDecoder().decode(TokenResponse.self, from: data)
                self.keychainHelper.save(refreshToken.token, service: "refresh-token", account: "geo")
                DispatchQueue.main.async {
                    self.refreshToken = refreshToken.token
                    self.isSignedIn = true
                }
            } catch let error {
                print(error)
            }
        }
            task.resume()
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
