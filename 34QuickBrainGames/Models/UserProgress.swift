//
//  UserProgress.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation

struct UserProgress: Codable {
    var totalGamesPlayed: Int
    var totalScore: Int
    var experiencePoints: Int
    var currentLevel: Int
    var levelProgress: Double // 0.0-1.0
    var dailyStreak: Int
    var bestStreak: Int
    var skills: [CognitiveSkill: SkillLevel]
    
    var levelUpThreshold: Int {
        // Experience threshold for next level
        currentLevel * 1000
    }
    
    mutating func addExperience(_ points: Int) {
        experiencePoints += points
        if experiencePoints >= levelUpThreshold {
            currentLevel += 1
            experiencePoints = experiencePoints % levelUpThreshold
        }
        levelProgress = Double(experiencePoints) / Double(levelUpThreshold)
    }
}

struct SkillLevel: Codable {
    var level: Int
    var progress: Double // 0.0-1.0
    var lastImproved: Date
}


