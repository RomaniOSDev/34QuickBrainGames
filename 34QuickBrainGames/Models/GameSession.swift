//
//  GameSession.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation

struct GameSession: Identifiable, Codable {
    let id: UUID
    var gameId: UUID
    var difficultyId: UUID
    var startTime: Date
    var endTime: Date
    var score: Int
    var maxScore: Int
    var correctAnswers: Int
    var incorrectAnswers: Int
    var reactionTimes: [TimeInterval]? // ms for reaction games
    var notes: String?
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var accuracy: Double {
        guard correctAnswers + incorrectAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(correctAnswers + incorrectAnswers) * 100
    }
    
    var performanceScore: Double {
        // Composite performance indicator (0-100)
        let accuracyWeight = 0.4
        let speedWeight = 0.3
        let scoreWeight = 0.3
        
        let accuracyComponent = accuracy * accuracyWeight
        let scoreComponent = (Double(score) / Double(maxScore)) * 100 * scoreWeight
        
        var speedComponent = 0.0
        if let reactionTimes = reactionTimes, !reactionTimes.isEmpty {
            let avgReaction = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            // Faster = better (inverted scale)
            speedComponent = max(0, 500 - avgReaction) / 5 * speedWeight
        }
        
        return accuracyComponent + scoreComponent + speedComponent
    }
}

