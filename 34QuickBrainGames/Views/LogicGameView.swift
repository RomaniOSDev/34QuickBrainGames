//
//  LogicGameView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct LogicGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    @State private var currentQuestion: LogicQuestion?
    @State private var score: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var incorrectAnswers: Int = 0
    @State private var timeRemaining: TimeInterval = 20
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var isPaused = false
    @State private var selectedAnswer: Int?
    @State private var showFeedback = false
    
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
                    } else if let question = currentQuestion {
                        questionContent(question)
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
    
    private func questionContent(_ question: LogicQuestion) -> some View {
        VStack(spacing: 24) {
            Text("Question \(correctAnswers + incorrectAnswers + 1)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(question.sequence.joined(separator: " → "))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("What comes next?")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        handleAnswer(index)
                    }) {
                        HStack {
                            Text(option)
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if let selected = selectedAnswer {
                                if selected == index {
                                    Image(systemName: question.correctAnswer == index ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(question.correctAnswer == index ? Color(hex: "B0D524") : Color(hex: "D80002"))
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedAnswer == index ?
                                    (question.correctAnswer == index ? Color(hex: "B0D524").opacity(0.3) : Color(hex: "D80002").opacity(0.3)) :
                                    Color.white.opacity(0.1)
                                )
                        )
                    }
                    .disabled(selectedAnswer != nil)
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
        selectedAnswer = nil
        
        guard let difficulty = gameViewModel.currentDifficulty else { return }
        timeRemaining = difficulty.timeLimit ?? 20
        
        gameViewModel.startSession()
        generateQuestion()
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                handleTimeOut()
            }
        }
    }
    
    private func generateQuestion() {
        let level = gameViewModel.currentDifficulty?.level ?? 1
        
        // Simple pattern sequences
        let patterns: [(sequence: [String], correct: String, options: [String])] = [
            (["1", "2", "3", "4"], "5", ["5", "6", "7", "8"]),
            (["A", "B", "C", "D"], "E", ["E", "F", "G", "H"]),
            (["2", "4", "6", "8"], "10", ["10", "12", "14", "16"]),
            (["1", "4", "9", "16"], "25", ["20", "25", "30", "36"]),
            (["A", "C", "E", "G"], "I", ["H", "I", "J", "K"]),
            (["5", "10", "15", "20"], "25", ["22", "25", "28", "30"]),
        ]
        
        let pattern = patterns.randomElement() ?? patterns[0]
        var options = pattern.options.shuffled()
        let correctIndex = options.firstIndex(of: pattern.correct) ?? 0
        
        currentQuestion = LogicQuestion(
            sequence: pattern.sequence,
            correctAnswer: correctIndex,
            options: options
        )
        
        timeRemaining = gameViewModel.currentDifficulty?.timeLimit ?? 20
        selectedAnswer = nil
    }
    
    private func handleAnswer(_ index: Int) {
        guard let question = currentQuestion else { return }
        
        selectedAnswer = index
        
        if index == question.correctAnswer {
            correctAnswers += 1
            score += 10
        } else {
            incorrectAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if correctAnswers + incorrectAnswers >= (gameViewModel.currentDifficulty?.targetScore ?? 10) / 10 {
                endGame()
            } else {
                generateQuestion()
            }
        }
    }
    
    private func handleTimeOut() {
        incorrectAnswers += 1
        
        if correctAnswers + incorrectAnswers >= (gameViewModel.currentDifficulty?.targetScore ?? 10) / 10 {
            endGame()
        } else {
            generateQuestion()
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

struct LogicQuestion {
    let sequence: [String]
    let correctAnswer: Int
    let options: [String]
}

#Preview {
    LogicGameView()
        .environmentObject({
            let vm = GameViewModel()
            vm.currentGame = GameData.defaultGames[2]
            vm.currentDifficulty = GameData.defaultGames[2].difficultyLevels[0]
            return vm
        }())
        .environmentObject(ChallengeViewModel(gameViewModel: GameViewModel()))
}


