//
//  LoginView.swift
//  Geo
//
//  Created by William Svoboda on 4/4/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    // Required to adapt Sign in with Apple button to current colorscheme
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        if viewModel.checkingSession {
            ProgressView()
                .task {
                    await viewModel.checkSession()
                }
        }
        else {
            NavigationView {
                VStack {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        switch result {
                        case .success(let auth):
                            switch auth.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                viewModel.handleCredential(appleIDCredential: appleIDCredential)
                            default:
                                break
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    .signInWithAppleButtonStyle(
                        colorScheme == .dark ? .white : .black
                    )
                    .frame(height: 50)
                    .padding()
                    .cornerRadius(8)
                }
                .navigationTitle("Sign In")
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage)
                )
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(authenticationManager: AuthenticationManager(settingsManager: SettingsManager())))
    }
}
