//
//  ContentView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .transition(.opacity)
            } else {
                MainDashboardView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showOnboarding)
    }
}

#Preview {
    ContentView()
}
