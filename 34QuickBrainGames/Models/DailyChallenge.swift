//
//  DailyChallenge.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation

struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    var date: Date
    var gameId: UUID
    var difficultyId: UUID
    var targetScore: Int
    var reward: Int // experience points
    var isCompleted: Bool
    var completionTime: TimeInterval? // if completed
    
    var isActive: Bool {
        Calendar.current.isDateInToday(date)
    }
}

