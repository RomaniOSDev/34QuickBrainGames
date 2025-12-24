//
//  GameData.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation

struct GameData {
    static let defaultGames: [BrainGame] = [
        BrainGame(
            id: UUID(),
            name: "Photo Memory",
            type: .memory,
            description: "Remember the location of paired cards",
            difficultyLevels: [
                Difficulty(id: UUID(), name: "Easy", level: 1, timeLimit: nil, targetScore: 100),
                Difficulty(id: UUID(), name: "Medium", level: 2, timeLimit: 90, targetScore: 200),
                Difficulty(id: UUID(), name: "Hard", level: 3, timeLimit: 60, targetScore: 300)
            ],
            iconName: "square.grid.3x3.fill",
            colorHex: "00CED1", // turquoise
            instructions: ["Remember card positions", "Find pairs", "Fewer attempts = better"],
            targetSkills: [.workingMemory, .visualAttention]
        ),
        
        BrainGame(
            id: UUID(),
            name: "Lightning Reaction",
            type: .reaction,
            description: "Tap appearing targets as fast as possible",
            difficultyLevels: [
                Difficulty(id: UUID(), name: "Beginner", level: 1, timeLimit: 30, targetScore: 50),
                Difficulty(id: UUID(), name: "Advanced", level: 2, timeLimit: 45, targetScore: 100),
                Difficulty(id: UUID(), name: "Expert", level: 3, timeLimit: 60, targetScore: 200)
            ],
            iconName: "bolt.fill",
            colorHex: "B0D524", // green
            instructions: ["React instantly", "Don't miss targets", "Avoid false targets"],
            targetSkills: [.processingSpeed, .visualAttention]
        ),
        
        BrainGame(
            id: UUID(),
            name: "Logic Chain",
            type: .logic,
            description: "Determine the next element in the sequence",
            difficultyLevels: [
                Difficulty(id: UUID(), name: "Simple", level: 1, timeLimit: 20, targetScore: 10),
                Difficulty(id: UUID(), name: "Medium", level: 2, timeLimit: 15, targetScore: 20),
                Difficulty(id: UUID(), name: "Complex", level: 3, timeLimit: 10, targetScore: 30)
            ],
            iconName: "brain.head.profile",
            colorHex: "8A2BE2", // purple
            instructions: ["Find the pattern", "Choose next element", "Act quickly"],
            targetSkills: [.logicalThinking, .patternRecognition]
        ),
        
        BrainGame(
            id: UUID(),
            name: "Speed Attention",
            type: .attention,
            description: "Find differences or track moving objects",
            difficultyLevels: [
                Difficulty(id: UUID(), name: "Basic", level: 1, timeLimit: 40, targetScore: 80),
                Difficulty(id: UUID(), name: "Advanced", level: 2, timeLimit: 50, targetScore: 150),
                Difficulty(id: UUID(), name: "Expert", level: 3, timeLimit: 60, targetScore: 250)
            ],
            iconName: "eye.fill",
            colorHex: "FF6B35", // orange
            instructions: ["Stay focused", "Don't get distracted", "Be accurate"],
            targetSkills: [.visualAttention, .patternRecognition]
        )
    ]
    
    static let defaultAchievements: [Achievement] = [
        Achievement(
            id: UUID(),
            name: "First Step",
            description: "Play your first game",
            iconName: "star.fill",
            requirement: .totalGames(count: 1),
            reward: 100,
            isUnlocked: false,
            unlockedDate: nil
        ),
        Achievement(
            id: UUID(),
            name: "Week of Discipline",
            description: "7 days in a row",
            iconName: "flame.fill",
            requirement: .streak(days: 7),
            reward: 500,
            isUnlocked: false,
            unlockedDate: nil
        ),
        Achievement(
            id: UUID(),
            name: "Perfect Memory",
            description: "10 perfect memory scores",
            iconName: "brain.head.profile",
            requirement: .perfectScores(count: 10),
            reward: 300,
            isUnlocked: false,
            unlockedDate: nil
        ),
        Achievement(
            id: UUID(),
            name: "Reaction Master",
            description: "Reach level 5 in reaction",
            iconName: "bolt.fill",
            requirement: .skillMastery(skill: .processingSpeed, level: 5),
            reward: 400,
            isUnlocked: false,
            unlockedDate: nil
        )
    ]
}

