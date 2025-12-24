//
//  AttentionGameView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct AttentionGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    @State private var score: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var incorrectAnswers: Int = 0
    @State private var timeRemaining: TimeInterval = 40
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var isPaused = false
    
    // Simple attention game: find the different color
    @State private var colors: [Color] = []
    @State private var differentIndex: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "035FAF")
                .ignoresSafeArea()
            
            if showResult, let session = gameViewModel.currentSession {
                GameResultView(
                    session: session,
                    onRestart: {
                        startNewGame()
                    },
                    onHome: {
                        gameViewModel.isGameActive = false
                    }
                )
            } else {
                VStack(spacing: 0) {
                    GameSessionHeader(
                        score: score,
                        timeRemaining: timeRemaining,
                        onPause: {
                            isPaused.toggle()
                            if isPaused {
                                timer?.invalidate()
                            } else {
                                startTimer()
                            }
                        }
                    )
                    
                    if isPaused {
                        pauseOverlay
                    } else {
                        gameContent
                    }
                }
            }
        }
        .onAppear {
            startNewGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var gameContent: some View {
        VStack(spacing: 24) {
            Text("Find the Different Color")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    Button(action: {
                        handleTap(index)
                    }) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                }
            }
            .padding()
        }
        .padding()
    }
    
    private var pauseOverlay: some View {
        VStack(spacing: 20) {
            Text("Paused")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Button(action: {
                isPaused = false
                startTimer()
            }) {
                Text("Resume")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "B0D524"))
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
    }
    
    private func startNewGame() {
        showResult = false
        score = 0
        correctAnswers = 0
        incorrectAnswers = 0
        
        guard let difficulty = gameViewModel.currentDifficulty else { return }
        timeRemaining = difficulty.timeLimit ?? 40
        
        gameViewModel.startSession()
        generateColors()
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func generateColors() {
        let baseColors: [Color] = [
            Color(hex: "B0D524"),
            Color(hex: "FF6B35"),
            Color(hex: "8A2BE2"),
            Color(hex: "00CED1"),
            Color(hex: "FFD700")
        ]
        
        let baseColor = baseColors.randomElement() ?? Color(hex: "B0D524")
        let originalDifferentIndex = Int.random(in: 0..<9)
        
        var newColors: [(color: Color, isDifferent: Bool)] = []
        for i in 0..<9 {
            if i == originalDifferentIndex {
                // Slightly different color
                newColors.append((color: baseColor.opacity(0.7), isDifferent: true))
            } else {
                newColors.append((color: baseColor, isDifferent: false))
            }
        }
        
        newColors.shuffle()
        
        // Find the index of the different color after shuffling
        differentIndex = newColors.firstIndex(where: { $0.isDifferent }) ?? 0
        
        // Extract just the colors for display
        colors = newColors.map { $0.color }
    }
    
    private func handleTap(_ index: Int) {
        if index == differentIndex {
            correctAnswers += 1
            score += 10
            generateColors()
        } else {
            incorrectAnswers += 1
        }
        
        if correctAnswers + incorrectAnswers >= (gameViewModel.currentDifficulty?.targetScore ?? 80) / 10 {
            endGame()
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        
        gameViewModel.endSession(
            score: score,
            correct: correctAnswers,
            incorrect: incorrectAnswers
        )
        
        if let challenge = challengeViewModel.todayChallenge,
           challenge.gameId == gameViewModel.currentGame?.id {
            challengeViewModel.checkChallengeCompletion(
                gameId: challenge.gameId,
                score: score
            )
        }
        
        showResult = true
    }
}

#Preview {
    AttentionGameView()
        .environmentObject({
            let vm = GameViewModel()
            vm.currentGame = GameData.defaultGames[3]
            vm.currentDifficulty = GameData.defaultGames[3].difficultyLevels[0]
            return vm
        }())
        .environmentObject(ChallengeViewModel(gameViewModel: GameViewModel()))
}

