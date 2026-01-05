//
//  ChallengeViewModel.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation
import SwiftUI
import Combine

class ChallengeViewModel: ObservableObject {
    @Published var dailyChallenges: [DailyChallenge] = []
    @Published var todayChallenge: DailyChallenge?
    
    private let storageManager = StorageManager.shared
    private let gameViewModel: GameViewModel
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        loadChallenges()
        generateTodayChallengeIfNeeded()
    }
    
    func loadChallenges() {
        dailyChallenges = storageManager.loadDailyChallenges()
        todayChallenge = dailyChallenges.first { $0.isActive }
    }
    
    func generateTodayChallengeIfNeeded() {
        if todayChallenge == nil {
            generateNewChallenge()
        }
    }
    
    private func generateNewChallenge() {
        let games = gameViewModel.games
        guard let randomGame = games.randomElement(),
              let randomDifficulty = randomGame.difficultyLevels.randomElement() else {
            return
        }
        
        let challenge = DailyChallenge(
            id: UUID(),
            date: Date(),
            gameId: randomGame.id,
            difficultyId: randomDifficulty.id,
            targetScore: randomDifficulty.targetScore,
            reward: randomDifficulty.level * 50,
            isCompleted: false,
            completionTime: nil
        )
        
        var challenges = dailyChallenges
        challenges.append(challenge)
        storageManager.saveDailyChallenges(challenges)
        
        dailyChallenges = challenges
        todayChallenge = challenge
    }
    
    func completeChallenge() {
        guard var challenge = todayChallenge else { return }
        
        challenge.isCompleted = true
        challenge.completionTime = Date().timeIntervalSince(challenge.date)
        
        var challenges = dailyChallenges
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = challenge
        }
        
        storageManager.saveDailyChallenges(challenges)
        dailyChallenges = challenges
        todayChallenge = challenge
        
        // Add reward to progress
        ProgressViewModel.shared.addExperience(challenge.reward)
    }
    
    func checkChallengeCompletion(gameId: UUID, score: Int) {
        guard let challenge = todayChallenge,
              challenge.gameId == gameId,
              !challenge.isCompleted,
              score >= challenge.targetScore else {
            return
        }
        
        completeChallenge()
    }
}


