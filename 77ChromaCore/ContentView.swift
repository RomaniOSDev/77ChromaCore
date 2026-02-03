//
//  ContentView.swift
//  77ChromaCore
//
//  Created by Роман Главацкий on 03.02.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            MainMenuView()
        } else {
            OnboardingView {
                hasSeenOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}
