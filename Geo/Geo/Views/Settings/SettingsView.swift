//
//  SettingsView.swift
//  Geo
//
//  Created by William Svoboda on 4/7/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel: SettingsViewModel
    
    var username: String {
        guard let user = viewModel.user else {
            return "Unknown"
        }
        if !user.givenName.isEmpty && !user.familyName.isEmpty {
            return "\(user.givenName) \(user.familyName)"
        } else if !user.givenName.isEmpty {
            return user.givenName
        } else if !user.familyName.isEmpty {
            return user.familyName
        } else {
            return "Anonymous"
        }
    }
    
    var body: some View {
        NavigationView {
            Form(content: {
                HStack {
                    Image(systemName: "person.fill")
                    Text(username)
                }
                Button(action: {
                    viewModel.logout()
                }, label: {
                    HStack {
                        Text("Logout")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                })
                .foregroundColor(.red)
            })
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(authenticationManager: AuthenticationManager(settingsManager: SettingsManager())))
    }
}
