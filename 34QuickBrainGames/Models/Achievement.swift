//
//  Achievement.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var iconName: String
    var requirement: AchievementRequirement
    var reward: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    var progress: Double {
        // Progress calculation from 0.0 to 1.0
        // Depends on requirement type
        return 0.0
    }
}

enum AchievementRequirement: Codable {
    case totalGames(count: Int)
    case perfectScores(count: Int)
    case streak(days: Int)
    case skillMastery(skill: CognitiveSkill, level: Int)
    case dailyChallengesCompleted(count: Int)
}

