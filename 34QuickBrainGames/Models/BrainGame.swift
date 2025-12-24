//
//  BrainGame.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct BrainGame: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: GameType
    var description: String
    var difficultyLevels: [Difficulty]
    var iconName: String
    var colorHex: String
    var instructions: [String]
    var targetSkills: [CognitiveSkill]
    
    var color: Color {
        Color(hex: colorHex)
    }
}

enum GameType: String, CaseIterable, Codable {
    case memory = "Memory"
    case reaction = "Reaction"
    case logic = "Logic"
    case attention = "Attention"
    case speed = "Speed"
}

struct Difficulty: Identifiable, Codable {
    let id: UUID
    var name: String
    var level: Int // 1-5
    var timeLimit: TimeInterval? // seconds
    var targetScore: Int
    
    var color: Color {
        switch level {
        case 1: return Color(hex: "00CED1") // turquoise
        case 2: return Color(hex: "B0D524") // green
        case 3: return Color(hex: "FFD700") // gold
        case 4: return Color(hex: "FF6B35") // orange
        case 5: return Color(hex: "D80002") // red
        default: return Color(hex: "035FAF")
        }
    }
}

enum CognitiveSkill: String, CaseIterable, Codable {
    case workingMemory = "Working Memory"
    case processingSpeed = "Processing Speed"
    case visualAttention = "Visual Attention"
    case logicalThinking = "Logical Thinking"
    case patternRecognition = "Pattern Recognition"
}

