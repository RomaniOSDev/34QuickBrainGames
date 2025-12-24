//
//  GameSessionView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct GameSessionView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    var body: some View {
        Group {
            if let game = gameViewModel.currentGame {
                switch game.type {
                case .memory:
                    MemoryGameView()
                case .reaction:
                    ReactionGameView()
                case .logic:
                    LogicGameView()
                case .attention:
                    AttentionGameView()
                case .speed:
                    SpeedGameView()
                }
            } else {
                Text("No game selected")
                    .foregroundColor(.white)
            }
        }
    }
}

struct GameSessionHeader: View {
    let score: Int
    let timeRemaining: TimeInterval?
    let onPause: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            if let time = timeRemaining {
                VStack(alignment: .center) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                    Text("\(Int(time))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(time < 10 ? Color(hex: "D80002") : .white)
                }
            }
            
            Spacer()
            
            Button(action: onPause) {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct GameResultView: View {
    let session: GameSession
    let onRestart: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "035FAF")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    ResultStatView(
                        title: "Score",
                        value: "\(session.score)",
                        color: Color(hex: "FFD700")
                    )
                    
                    ResultStatView(
                        title: "Accuracy",
                        value: String(format: "%.1f%%", session.accuracy),
                        color: Color(hex: "B0D524")
                    )
                    
                    ResultStatView(
                        title: "Duration",
                        value: String(format: "%.1fs", session.duration),
                        color: Color(hex: "00CED1")
                    )
                    
                    ResultStatView(
                        title: "Performance",
                        value: String(format: "%.0f", session.performanceScore),
                        color: Color(hex: "8A2BE2")
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                
                HStack(spacing: 16) {
                    Button(action: onRestart) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "B0D524"))
                            )
                    }
                    
                    Button(action: onHome) {
                        Text("Home")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
            }
            .padding()
        }
    }
}

struct ResultStatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    GameSessionView()
        .environmentObject(GameViewModel())
        .environmentObject(ChallengeViewModel(gameViewModel: GameViewModel()))
}

