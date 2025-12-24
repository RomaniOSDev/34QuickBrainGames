//
//  SpeedGameView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

// Placeholder for speed game - similar to attention game
struct SpeedGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    var body: some View {
        AttentionGameView()
            .environmentObject(gameViewModel)
            .environmentObject(challengeViewModel)
    }
}

