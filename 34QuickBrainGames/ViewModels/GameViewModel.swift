//
//  GameViewModel.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var games: [BrainGame] = GameData.defaultGames
    @Published var currentGame: BrainGame?
    @Published var currentDifficulty: Difficulty?
    @Published var currentSession: GameSession?
    @Published var isGameActive: Bool = false
    
    private let storageManager = StorageManager.shared
    
    init() {
        loadGames()
    }
    
    func loadGames() {
        // Games are static for now, loaded from GameData
        games = GameData.defaultGames
    }
    
    func selectGame(_ game: BrainGame) {
        currentGame = game
    }
    
    func selectDifficulty(_ difficulty: Difficulty) {
        currentDifficulty = difficulty
    }
    
    func startSession() {
        guard let game = currentGame, let difficulty = currentDifficulty else { return }
        
        let session = GameSession(
            id: UUID(),
            gameId: game.id,
            difficultyId: difficulty.id,
            startTime: Date(),
            endTime: Date(),
            score: 0,
            maxScore: difficulty.targetScore,
            correctAnswers: 0,
            incorrectAnswers: 0,
            reactionTimes: nil,
            notes: nil
        )
        
        currentSession = session
        isGameActive = true
    }
    
    func endSession(score: Int, correct: Int, incorrect: Int, reactionTimes: [TimeInterval]? = nil) {
        guard var session = currentSession else { return }
        
        session.endTime = Date()
        session.score = score
        session.correctAnswers = correct
        session.incorrectAnswers = incorrect
        session.reactionTimes = reactionTimes
        
        storageManager.addSession(session)
        
        // Update progress
        ProgressViewModel.shared.recordSession(session)
        
        currentSession = nil
        isGameActive = false
    }
    
    func getBestScore(for gameId: UUID) -> Int {
        let sessions = storageManager.loadSessions()
        return sessions
            .filter { $0.gameId == gameId }
            .map { $0.score }
            .max() ?? 0
    }
    
    func getSessions(for gameId: UUID) -> [GameSession] {
        let sessions = storageManager.loadSessions()
        return sessions.filter { $0.gameId == gameId }
    }
}

