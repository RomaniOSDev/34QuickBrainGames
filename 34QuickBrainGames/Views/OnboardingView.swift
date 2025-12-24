//
//  OnboardingView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Quick Brain Games",
            description: "Train your brain with fun and challenging mini-games designed to improve your cognitive skills.",
            iconName: "brain.head.profile",
            color: Color(hex: "00CED1")
        ),
        OnboardingPage(
            title: "Daily Challenges",
            description: "Complete daily challenges to earn experience points and maintain your streak. The more you play, the better you get!",
            iconName: "calendar",
            color: Color(hex: "FFD700")
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Monitor your cognitive skills development, unlock achievements, and compete with yourself to beat your best scores.",
            iconName: "chart.bar.fill",
            color: Color(hex: "B0D524")
        )
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "035FAF")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        completeOnboarding()
                    }) {
                        Text("Skip")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicator and buttons
                VStack(spacing: 20) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                Text("Previous")
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
                        
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        }) {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(pages[currentPage].color)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 70))
                    .foregroundColor(page.color)
            }
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

