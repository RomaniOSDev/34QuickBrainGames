//
//  AchievementsView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "035FAF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary
                        summarySection
                        
                        // Achievements grid
                        achievementsGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .onAppear {
                achievementViewModel.checkAchievements()
            }
        }
    }
    
    private var summarySection: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("\(achievementViewModel.getUnlockedCount())")
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "FFD700"))
                
                Text("Unlocked")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("\(achievementViewModel.achievements.count)")
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Total")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("\(achievementViewModel.getTotalRewards())")
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "B0D524"))
                
                Text("XP Earned")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(achievementViewModel.achievements) { achievement in
                AchievementCardView(achievement: achievement)
            }
        }
    }
}

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        Color(hex: "FFD700").opacity(0.2) :
                        Color.white.opacity(0.1)
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(
                        achievement.isUnlocked ?
                        Color(hex: "FFD700") :
                        Color.white.opacity(0.5)
                    )
            }
            
            VStack(spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if achievement.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("+\(achievement.reward) XP")
                            .font(.caption)
                            .foregroundColor(Color(hex: "FFD700"))
                    }
                } else {
                    Text("Locked")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    achievement.isUnlocked ?
                    Color(hex: "FFD700").opacity(0.1) :
                    Color.white.opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            achievement.isUnlocked ?
                            Color(hex: "FFD700") :
                            Color.clear,
                            lineWidth: 2
                        )
                )
        )
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AchievementViewModel())
        .environmentObject(ProgressViewModel.shared)
}


