//
//  MainDashboardView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct MainDashboardView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var challengeViewModel: ChallengeViewModel
    @StateObject private var progressViewModel = ProgressViewModel.shared
    @StateObject private var achievementViewModel = AchievementViewModel()
    
    @State private var selectedTab = 0
    
    init() {
        let gameVM = GameViewModel()
        _gameViewModel = StateObject(wrappedValue: gameVM)
        _challengeViewModel = StateObject(wrappedValue: ChallengeViewModel(gameViewModel: gameVM))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GamesGridView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(0)
            
            UserProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "trophy.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .environmentObject(gameViewModel)
        .environmentObject(challengeViewModel)
        .environmentObject(progressViewModel)
        .environmentObject(achievementViewModel)
    }
}

struct GamesGridView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "035FAF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with level and progress
                        headerSection
                        
                        // Daily challenge card
                        if let challenge = challengeViewModel.todayChallenge {
                            dailyChallengeCard(challenge)
                        }
                        
                        // Games grid
                        gamesGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Quick Brain Games")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
        }
        .onAppear {
            achievementViewModel.checkAchievements()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(progressViewModel.progress.currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(progressViewModel.progress.experiencePoints) XP")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("🔥 \(progressViewModel.progress.dailyStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "FFD700"))
                    
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(hex: "B0D524"))
                        .frame(width: geometry.size.width * CGFloat(progressViewModel.progress.levelProgress), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Games Played: \(progressViewModel.progress.totalGamesPlayed)")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
                
                Spacer()
                
                Text("Total Score: \(progressViewModel.progress.totalScore)")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private func dailyChallengeCard(_ challenge: DailyChallenge) -> some View {
        NavigationLink(destination: GameSelectionView(game: gameViewModel.games.first(where: { $0.id == challenge.gameId }) ?? gameViewModel.games[0])) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("Daily Challenge")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    if let game = gameViewModel.games.first(where: { $0.id == challenge.gameId }) {
                        Text(game.name)
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                    
                    Text("Target: \(challenge.targetScore) points")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    if challenge.isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "B0D524"))
                            Text("Completed!")
                                .font(.caption)
                                .foregroundColor(Color(hex: "B0D524"))
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("+\(challenge.reward)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "FFD700"))
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        challenge.isCompleted ?
                        Color(hex: "B0D524").opacity(0.2) :
                        Color(hex: "FFD700").opacity(0.2)
                    )
            )
        }
    }
    
    private var gamesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(gameViewModel.games) { game in
                NavigationLink(destination: GameSelectionView(game: game)) {
                    GameCardView(game: game, bestScore: gameViewModel.getBestScore(for: game.id))
                }
            }
        }
    }
}

struct GameCardView: View {
    let game: BrainGame
    let bestScore: Int
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(game.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: game.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(game.color)
            }
            
            Text(game.name)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(game.type.rawValue)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
            
            if bestScore > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(Color(hex: "FFD700"))
                    Text("\(bestScore)")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    MainDashboardView()
}

