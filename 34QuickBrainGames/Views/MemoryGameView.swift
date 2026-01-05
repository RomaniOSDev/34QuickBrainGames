//
//  MemoryGameView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct MemoryGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    @State private var cards: [MemoryCard] = []
    @State private var selectedCards: [Int] = []
    @State private var matchedPairs: Set<Int> = []
    @State private var score: Int = 0
    @State private var attempts: Int = 0
    @State private var timeRemaining: TimeInterval?
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var isPaused = false
    
    private var gridSize: Int {
        guard let difficulty = gameViewModel.currentDifficulty else { return 4 }
        switch difficulty.level {
        case 1: return 4 // 4x4 = 16 cards, 8 pairs
        case 2: return 4 // 4x4 = 16 cards, 8 pairs
        case 3: return 6 // 6x6 = 36 cards, 18 pairs
        default: return 4
        }
    }
    
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
        VStack(spacing: 20) {
            Text("Attempts: \(attempts)")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize), spacing: 8) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    MemoryCardView(
                        card: card,
                        isSelected: selectedCards.contains(index),
                        isMatched: matchedPairs.contains(card.pairId)
                    )
                    .onTapGesture {
                        handleCardTap(at: index)
                    }
                }
            }
            .padding()
        }
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
        attempts = 0
        selectedCards = []
        matchedPairs = []
        
        guard let difficulty = gameViewModel.currentDifficulty else { return }
        timeRemaining = difficulty.timeLimit
        
        // Generate cards
        let pairCount = (gridSize * gridSize) / 2
        var newCards: [MemoryCard] = []
        
        for pairId in 0..<pairCount {
            let emoji = ["🎯", "🎨", "🎭", "🎪", "🎬", "🎮", "🎲", "🎸", "🎺", "🎻", "🥁", "🎤", "🎧", "🎯", "🎨", "🎭", "🎪", "🎬"][pairId]
            newCards.append(MemoryCard(id: UUID(), pairId: pairId, emoji: emoji))
            newCards.append(MemoryCard(id: UUID(), pairId: pairId, emoji: emoji))
        }
        
        cards = newCards.shuffled()
        
        gameViewModel.startSession()
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        if let timeLimit = timeRemaining {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if let time = timeRemaining, time > 0 {
                    timeRemaining = time - 1
                } else {
                    endGame()
                }
            }
        }
    }
    
    private func handleCardTap(at index: Int) {
        guard !isPaused,
              !selectedCards.contains(index),
              !matchedPairs.contains(cards[index].pairId),
              selectedCards.count < 2 else {
            return
        }
        
        selectedCards.append(index)
        
        if selectedCards.count == 2 {
            attempts += 1
            let firstIndex = selectedCards[0]
            let secondIndex = selectedCards[1]
            
            if cards[firstIndex].pairId == cards[secondIndex].pairId {
                // Match found
                matchedPairs.insert(cards[firstIndex].pairId)
                score += 10
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedCards = []
                    checkGameComplete()
                }
            } else {
                // No match
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    selectedCards = []
                }
            }
        }
    }
    
    private func checkGameComplete() {
        if matchedPairs.count == (gridSize * gridSize) / 2 {
            endGame()
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        
        let correctAnswers = matchedPairs.count
        let incorrectAnswers = attempts - correctAnswers
        let maxScore = gameViewModel.currentDifficulty?.targetScore ?? 100
        
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

struct MemoryCard: Identifiable {
    let id: UUID
    let pairId: Int
    let emoji: String
}

struct MemoryCardView: View {
    let card: MemoryCard
    let isSelected: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isMatched ?
                    Color(hex: "B0D524").opacity(0.5) :
                    (isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isMatched ? Color(hex: "B0D524") : Color.white.opacity(0.3),
                            lineWidth: 2
                        )
                )
            
            if isSelected || isMatched {
                Text(card.emoji)
                    .font(.system(size: 40))
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(.spring(response: 0.3), value: isSelected)
        .animation(.spring(response: 0.3), value: isMatched)
    }
}

#Preview {
    MemoryGameView()
        .environmentObject({
            let vm = GameViewModel()
            vm.currentGame = GameData.defaultGames[0]
            vm.currentDifficulty = GameData.defaultGames[0].difficultyLevels[0]
            return vm
        }())
        .environmentObject(ChallengeViewModel(gameViewModel: GameViewModel()))
}


