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
    
    var body: some View {
        if (authenticationManager.isSignedIn) {
            MainView()
        } else {
            LoginView(viewModel: LoginViewModel(authenticationManager: authenticationManager))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
