//
//  ProgressViewModel.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation
import SwiftUI
import Combine

class ProgressViewModel: ObservableObject {
    static let shared = ProgressViewModel()
    
    @Published var progress: UserProgress
    
    private let storageManager = StorageManager.shared
    
    private init() {
        if let savedProgress = storageManager.loadProgress() {
            self.progress = savedProgress
        } else {
            self.progress = UserProgress(
                totalGamesPlayed: 0,
                totalScore: 0,
                experiencePoints: 0,
                currentLevel: 1,
                levelProgress: 0.0,
                dailyStreak: 0,
                bestStreak: 0,
                skills: [:]
            )
        }
        
        updateStreak()
    }
    
    func recordSession(_ session: GameSession) {
        progress.totalGamesPlayed += 1
        progress.totalScore += session.score
        
        // Update streak
        updateStreak()
        
        // Update skills based on game type
        if let game = GameViewModel().games.first(where: { $0.id == session.gameId }) {
            for skill in game.targetSkills {
                updateSkill(skill, performance: session.performanceScore)
            }
        }
        
        saveProgress()
    }
    
    func addExperience(_ points: Int) {
        progress.addExperience(points)
        saveProgress()
    }
    
    private func updateStreak() {
        let lastPlayDate = storageManager.loadLastPlayDate()
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastPlayDate {
            let lastPlayDay = Calendar.current.startOfDay(for: lastDate)
            let daysSinceLastPlay = Calendar.current.dateComponents([.day], from: lastPlayDay, to: today).day ?? 0
            
            if daysSinceLastPlay == 0 {
                // Already played today
                return
            } else if daysSinceLastPlay == 1 {
                // Consecutive day
                progress.dailyStreak += 1
            } else {
                // Streak broken
                if progress.dailyStreak > progress.bestStreak {
                    progress.bestStreak = progress.dailyStreak
                }
                progress.dailyStreak = 1
            }
        } else {
            // First time playing
            progress.dailyStreak = 1
        }
        
        if progress.dailyStreak > progress.bestStreak {
            progress.bestStreak = progress.dailyStreak
        }
        
        storageManager.saveLastPlayDate(Date())
    }
    
    private func updateSkill(_ skill: CognitiveSkill, performance: Double) {
        if progress.skills[skill] == nil {
            progress.skills[skill] = SkillLevel(level: 1, progress: 0.0, lastImproved: Date())
        }
        
        guard var skillLevel = progress.skills[skill] else { return }
        
        // Increase progress based on performance
        skillLevel.progress += performance / 1000.0
        
        if skillLevel.progress >= 1.0 {
            skillLevel.level += 1
            skillLevel.progress = 0.0
            skillLevel.lastImproved = Date()
        }
        
        progress.skills[skill] = skillLevel
    }
    
    private func saveProgress() {
        storageManager.saveProgress(progress)
    }
}


