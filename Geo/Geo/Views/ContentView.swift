//
//  ContentView.swift
//  Geo
//
//  Created by William Svoboda on 10/22/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import AuthenticationServices
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authenticationManager: AuthenticationManager
    
    // TODO: Refactor to adapt colorscheme on change?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if (authenticationManager.isSignedIn) {
            MapView()
        } else {
            NavigationView {
                VStack {
                    SignInWithAppleButton(.signIn) { request in
                        
                        request.requestedScopes = [.email, .fullName]
                        
                    } onCompletion: { result in
                        
                        switch result {
                        case .success(let auth):
                            print("Signed in!")
                            switch auth.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                authenticationManager.handleCredential(appleIDCredential: appleIDCredential)
                                print("Submitted to server")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
