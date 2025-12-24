//
//  AchievementViewModel.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation
import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var recentlyUnlocked: [Achievement] = []
    
    private let storageManager = StorageManager.shared
    private let progressViewModel = ProgressViewModel.shared
    
    init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        achievements = storageManager.loadAchievements()
        recentlyUnlocked = achievements.filter { $0.isUnlocked && $0.unlockedDate != nil }
            .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
            .prefix(5)
            .map { $0 }
    }
    
    func checkAchievements() {
        let sessions = storageManager.loadSessions()
        let progress = progressViewModel.progress
        
        var updatedAchievements = achievements
        var hasNewUnlocks = false
        
        for (index, achievement) in achievements.enumerated() {
            if achievement.isUnlocked { continue }
            
            var shouldUnlock = false
            
            switch achievement.requirement {
            case .totalGames(let count):
                shouldUnlock = progress.totalGamesPlayed >= count
                
            case .perfectScores(let count):
                let perfectCount = sessions.filter { $0.accuracy >= 100.0 }.count
                shouldUnlock = perfectCount >= count
                
            case .streak(let days):
                shouldUnlock = progress.dailyStreak >= days
                
            case .skillMastery(let skill, let level):
                if let skillLevel = progress.skills[skill] {
                    shouldUnlock = skillLevel.level >= level
                }
                
            case .dailyChallengesCompleted(let count):
                let completedChallenges = storageManager.loadDailyChallenges().filter { $0.isCompleted }.count
                shouldUnlock = completedChallenges >= count
            }
            
            if shouldUnlock {
                updatedAchievements[index].isUnlocked = true
                updatedAchievements[index].unlockedDate = Date()
                progressViewModel.addExperience(achievement.reward)
                hasNewUnlocks = true
            }
        }
        
        if hasNewUnlocks {
            achievements = updatedAchievements
            storageManager.saveAchievements(achievements)
            loadAchievements()
        }
    }
    
    func getUnlockedCount() -> Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    func getTotalRewards() -> Int {
        achievements.filter { $0.isUnlocked }.reduce(0) { $0 + $1.reward }
    }
}

