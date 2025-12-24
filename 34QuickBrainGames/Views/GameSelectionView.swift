//
//  GameSelectionView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct GameSelectionView: View {
    let game: BrainGame
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    @State private var selectedDifficulty: Difficulty?
    
    var body: some View {
        ZStack {
            Color(hex: "035FAF")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Game header
                    gameHeader
                    
                    // Description
                    descriptionSection
                    
                    // Instructions
                    instructionsSection
                    
                    // Difficulty selection
                    difficultySection
                    
                    // Best scores
                    bestScoresSection
                    
                    // Start button
                    startButton
                }
                .padding()
            }
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
    }
    
    private var gameHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(game.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: game.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(game.color)
            }
            
            Text(game.type.rawValue)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.8))
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(game.description)
                .font(.body)
                .foregroundColor(Color.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(Array(game.instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .font(.body)
                        .foregroundColor(game.color)
                        .fontWeight(.bold)
                    
                    Text(instruction)
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.9))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Difficulty")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(game.difficultyLevels) { difficulty in
                Button(action: {
                    selectedDifficulty = difficulty
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(difficulty.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                if let timeLimit = difficulty.timeLimit {
                                    Label("\(Int(timeLimit))s", systemImage: "clock")
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.7))
                                }
                                
                                Label("\(difficulty.targetScore) pts", systemImage: "target")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        if selectedDifficulty?.id == difficulty.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(difficulty.color)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                selectedDifficulty?.id == difficulty.id ?
                                difficulty.color.opacity(0.3) :
                                Color.white.opacity(0.1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedDifficulty?.id == difficulty.id ?
                                        difficulty.color :
                                        Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                }
            }
        }
    }
    
    private var bestScoresSection: some View {
        let sessions = gameViewModel.getSessions(for: game.id)
        
        if !sessions.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text("Best Scores")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(game.difficultyLevels) { difficulty in
                        if let bestSession = sessions
                            .filter({ $0.difficultyId == difficulty.id })
                            .max(by: { $0.score < $1.score }) {
                            
                            HStack {
                                Text(difficulty.name)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white.opacity(0.8))
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(hex: "FFD700"))
                                    Text("\(bestSession.score)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "FFD700"))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var startButton: some View {
        NavigationLink(
            destination: GameSessionView()
                .environmentObject(gameViewModel)
                .environmentObject(challengeViewModel)
                .onAppear {
                    if let difficulty = selectedDifficulty ?? game.difficultyLevels.first {
                        gameViewModel.selectGame(game)
                        gameViewModel.selectDifficulty(difficulty)
                    }
                }
        ) {
            Text("Start Game")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            (selectedDifficulty ?? game.difficultyLevels.first)?.color ?? game.color
                        )
                )
        }
        .disabled(selectedDifficulty == nil && game.difficultyLevels.isEmpty)
    }
}

#Preview {
    NavigationView {
        GameSelectionView(game: GameData.defaultGames[0])
            .environmentObject(GameViewModel())
            .environmentObject(ChallengeViewModel(gameViewModel: GameViewModel()))
    }
}

