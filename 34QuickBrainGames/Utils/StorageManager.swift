//
//  StorageManager.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let userProgress = "userProgress"
        static let gameSessions = "gameSessions"
        static let achievements = "achievements"
        static let dailyChallenges = "dailyChallenges"
        static let lastPlayDate = "lastPlayDate"
    }
    
    // MARK: - User Progress
    func saveProgress(_ progress: UserProgress) {
        if let encoded = try? JSONEncoder().encode(progress) {
            userDefaults.set(encoded, forKey: Keys.userProgress)
        }
    }
    
    func loadProgress() -> UserProgress? {
        guard let data = userDefaults.data(forKey: Keys.userProgress),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return nil
        }
        return progress
    }
    
    // MARK: - Game Sessions
    func saveSessions(_ sessions: [GameSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: Keys.gameSessions)
        }
    }
    
    func loadSessions() -> [GameSession] {
        guard let data = userDefaults.data(forKey: Keys.gameSessions),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return sessions
    }
    
    func addSession(_ session: GameSession) {
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
    }
    
    // MARK: - Achievements
    func saveAchievements(_ achievements: [Achievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: Keys.achievements)
        }
    }
    
    func loadAchievements() -> [Achievement] {
        guard let data = userDefaults.data(forKey: Keys.achievements),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return GameData.defaultAchievements
        }
        return achievements
    }
    
    // MARK: - Daily Challenges
    func saveDailyChallenges(_ challenges: [DailyChallenge]) {
        if let encoded = try? JSONEncoder().encode(challenges) {
            userDefaults.set(encoded, forKey: Keys.dailyChallenges)
        }
    }
    
    func loadDailyChallenges() -> [DailyChallenge] {
        guard let data = userDefaults.data(forKey: Keys.dailyChallenges),
              let challenges = try? JSONDecoder().decode([DailyChallenge].self, from: data) else {
            return []
        }
        return challenges
    }
    
    // MARK: - Last Play Date
    func saveLastPlayDate(_ date: Date) {
        userDefaults.set(date, forKey: Keys.lastPlayDate)
    }
    
    func loadLastPlayDate() -> Date? {
        return userDefaults.object(forKey: Keys.lastPlayDate) as? Date
    }
}


