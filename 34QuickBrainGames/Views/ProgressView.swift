//
//  ProgressView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct UserProgressView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "035FAF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Level and XP
                        levelSection
                        
                        // Statistics
                        statisticsSection
                        
                        // Skills
                        skillsSection
                        
                        // Recent sessions
                        recentSessionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
        }
    }
    
    private var levelSection: some View {
        VStack(spacing: 16) {
            Text("Level \(progressViewModel.progress.currentLevel)")
                .font(.system(size: 48))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "FFD700"))
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(progressViewModel.progress.experiencePoints) / \(progressViewModel.progress.levelUpThreshold) XP")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(progressViewModel.progress.levelProgress * 100))%")
                        .font(.headline)
                        .foregroundColor(Color(hex: "B0D524"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "B0D524"), Color(hex: "FFD700")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(progressViewModel.progress.levelProgress), height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCardView(
                    title: "Games Played",
                    value: "\(progressViewModel.progress.totalGamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: Color(hex: "00CED1")
                )
                
                StatCardView(
                    title: "Total Score",
                    value: "\(progressViewModel.progress.totalScore)",
                    icon: "star.fill",
                    color: Color(hex: "FFD700")
                )
                
                StatCardView(
                    title: "Daily Streak",
                    value: "\(progressViewModel.progress.dailyStreak)",
                    icon: "flame.fill",
                    color: Color(hex: "FF6B35")
                )
                
                StatCardView(
                    title: "Best Streak",
                    value: "\(progressViewModel.progress.bestStreak)",
                    icon: "trophy.fill",
                    color: Color(hex: "8A2BE2")
                )
            }
        }
    }
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cognitive Skills")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ForEach(CognitiveSkill.allCases, id: \.self) { skill in
                if let skillLevel = progressViewModel.progress.skills[skill] {
                    SkillProgressView(skill: skill, level: skillLevel)
                } else {
                    SkillProgressView(skill: skill, level: SkillLevel(level: 0, progress: 0.0, lastImproved: Date()))
                }
            }
        }
    }
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Sessions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            let sessions = StorageManager.shared.loadSessions().suffix(5).reversed()
            
            if sessions.isEmpty {
                Text("No sessions yet")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(sessions)) { session in
                    SessionRowView(session: session)
                }
            }
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct SkillProgressView: View {
    let skill: CognitiveSkill
    let level: SkillLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Level \(level.level)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "FFD700"))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(hex: "B0D524"))
                        .frame(width: geometry.size.width * CGFloat(level.progress), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct SessionRowView: View {
    let session: GameSession
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let game = gameViewModel.games.first(where: { $0.id == session.gameId }) {
                    Text(game.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text(session.startTime, style: .relative)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.score)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "FFD700"))
                
                Text(String(format: "%.0f%%", session.accuracy))
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    UserProgressView()
        .environmentObject(ProgressViewModel.shared)
        .environmentObject(GameViewModel())
}

