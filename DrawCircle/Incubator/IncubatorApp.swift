//
//  IncubatorApp.swift
//  Incubator
//
//  Created by Alikhan Tangirbergen on 21.04.2023.
//

import SwiftUI

enum AppScreenState {
    case onboarding
    case main
}

@main
struct IncubatorApp: App {
    @State var screenstate : AppScreenState
    var isOnboardingSeen : Bool
    init() {
        self.isOnboardingSeen = UserDefaults.standard.bool(forKey: "isOnboardingSeen")
        switch isOnboardingSeen {
        case true:
            self.screenstate = .main
        case false:
            self.screenstate = .onboarding
        }
    }
    var body: some Scene {
        WindowGroup {
            switch screenstate {
            case .main:
                ContentView()
            case .onboarding:
                WelcomePage(screenState: $screenstate)
            }
        }
    }}
