//
//  ReactionGameView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct ReactionGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    @State private var targets: [ReactionTarget] = []
    @State private var score: Int = 0
    @State private var timeRemaining: TimeInterval = 30
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    @State private var reactionTimes: [TimeInterval] = []
    @State private var showResult = false
    @State private var isPaused = false
    
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
                                spawnTimer?.invalidate()
                            } else {
                                startTimers()
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
            spawnTimer?.invalidate()
        }
    }
    
    private var gameContent: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(targets) { target in
                    ReactionTargetView(target: target)
                        .position(target.position)
                        .onTapGesture {
                            handleTargetTap(target)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                startTimers()
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
        targets = []
        reactionTimes = []
        
        guard let difficulty = gameViewModel.currentDifficulty else { return }
        timeRemaining = difficulty.timeLimit ?? 30
        
        gameViewModel.startSession()
        startTimers()
    }
    
    private func startTimers() {
        timer?.invalidate()
        spawnTimer?.invalidate()
        
        // Game timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
        
        // Spawn timer
        let spawnInterval = gameViewModel.currentDifficulty?.level == 3 ? 0.8 : 1.2
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
            spawnTarget()
        }
        
        // Initial spawn
        spawnTarget()
    }
    
    private func spawnTarget() {
        guard !isPaused else { return }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height - 200 // Account for header
        
        let x = CGFloat.random(in: 50...(screenWidth - 50))
        let y = CGFloat.random(in: 100...(screenHeight - 50))
        
        let target = ReactionTarget(
            id: UUID(),
            position: CGPoint(x: x, y: y),
            spawnTime: Date(),
            isFalseTarget: gameViewModel.currentDifficulty?.level ?? 1 >= 2 && Bool.random()
        )
        
        targets.append(target)
        
        // Remove target after timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let index = targets.firstIndex(where: { $0.id == target.id }) {
                targets.remove(at: index)
            }
        }
    }
    
    private func handleTargetTap(_ target: ReactionTarget) {
        if target.isFalseTarget {
            // Penalty for false target
            score = max(0, score - 5)
            if let index = targets.firstIndex(where: { $0.id == target.id }) {
                targets.remove(at: index)
            }
            return
        }
        
        let reactionTime = Date().timeIntervalSince(target.spawnTime) * 1000 // ms
        reactionTimes.append(reactionTime)
        
        // Score based on reaction time
        let points = max(1, Int(500 - reactionTime) / 10)
        score += points
        
        if let index = targets.firstIndex(where: { $0.id == target.id }) {
            targets.remove(at: index)
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        spawnTimer?.invalidate()
        targets = []
        
        let correctAnswers = reactionTimes.count
        let incorrectAnswers = 0 // No incorrect answers, just missed targets
        
        gameViewModel.endSession(
            score: score,
            correct: correctAnswers,
            incorrect: incorrectAnswers,
            reactionTimes: reactionTimes
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

struct ReactionTarget: Identifiable {
    let id: UUID
    let position: CGPoint
    let spawnTime: Date
    let isFalseTarget: Bool
}

struct ReactionTargetView: View {
    let target: ReactionTarget
    
    var body: some View {
        ZStack {
            Circle()
                .fill(target.isFalseTarget ? Color(hex: "D80002") : Color(hex: "B0D524"))
                .frame(width: 60, height: 60)
            
            Image(systemName: target.isFalseTarget ? "xmark" : "checkmark")
                .font(.title2)
                .foregroundColor(.white)
        }
        .shadow(radius: 10)
    }
}

#Preview {
    ReactionGameView()
        .environmentObject({
            let vm = GameViewModel()
            vm.currentGame = GameData.defaultGames[1]
            vm.currentDifficulty = GameData.defaultGames[1].difficultyLevels[0]
            return vm
        }())
        .environmentObject(ChallengeViewModel(gameViewModel: GameViewModel()))
}


