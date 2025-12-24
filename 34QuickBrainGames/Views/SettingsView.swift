//
//  SettingsView.swift
//  34QuickBrainGames
//
//  Created by Роман Главацкий on 22.12.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showPrivacy = false
    @State private var showTerms = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "035FAF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App info section
                        appInfoSection
                        
                        // Settings options
                        settingsSection
                        
                        // Legal section
                        legalSection
                        
                        // Version info
                        versionSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .sheet(isPresented: $showPrivacy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTerms) {
                TermsOfServiceView()
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "B0D524"))
            
            Text("Quick Brain Games")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Train your brain, improve your skills")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            SettingsRowView(
                icon: "star.fill",
                title: "Rate Us",
                iconColor: Color(hex: "FFD700"),
                action: {
                    rateApp()
                }
            )
        }
    }
    
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Legal")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            SettingsRowView(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                iconColor: Color(hex: "00CED1"),
                action: {
                    if let url = URL(string: "https://www.termsfeed.com/live/6a21e31a-82b1-4034-bd4e-90ec03f619c6") {
                        UIApplication.shared.open(url)
                    }
                }
            )
            
            SettingsRowView(
                icon: "doc.text.fill",
                title: "Terms of Service",
                iconColor: Color(hex: "8A2BE2"),
                action: {
                    if let url = URL(string: "https://www.termsfeed.com/live/a72f6579-553c-43eb-a23e-b6cf9f501f31") {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }
    
    private var versionSection: some View {
        VStack(spacing: 8) {
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.6))
            
            Text("© 2025 Quick Brain Games")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.top)
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.white.opacity(0.5))
                    .font(.system(size: 14))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "035FAF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                        Text("Last updated: December 2025")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom)
                        
                        Text("""
                        Quick Brain Games ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.
                        
                        Information We Collect
                        
                        We may collect information that you provide directly to us, including:
                        - Game progress and statistics
                        - Achievement data
                        - Performance metrics
                        
                        How We Use Your Information
                        
                        We use the information we collect to:
                        - Provide and improve our services
                        - Track your progress and achievements
                        - Personalize your gaming experience
                        
                        Data Storage
                        
                        All data is stored locally on your device. We do not transmit your personal information to external servers without your explicit consent.
                        
                        Your Rights
                        
                        You have the right to:
                        - Access your personal data
                        - Request deletion of your data
                        - Opt-out of data collection
                        
                        Contact Us
                        
                        If you have questions about this Privacy Policy, please contact us through the app settings.
                        """)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "035FAF")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Terms of Service")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                        Text("Last updated: December 2025")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom)
                        
                        Text("""
                        Please read these Terms of Service ("Terms") carefully before using Quick Brain Games.
                        
                        Acceptance of Terms
                        
                        By accessing or using Quick Brain Games, you agree to be bound by these Terms. If you disagree with any part of these terms, you may not access the service.
                        
                        Use License
                        
                        Permission is granted to temporarily use Quick Brain Games for personal, non-commercial purposes only. This is the grant of a license, not a transfer of title.
                        
                        Restrictions
                        
                        You may not:
                        - Modify or copy the materials
                        - Use the materials for any commercial purpose
                        - Attempt to reverse engineer any software
                        - Remove any copyright or proprietary notations
                        
                        Disclaimer
                        
                        The materials in Quick Brain Games are provided on an 'as is' basis. We make no warranties, expressed or implied, and hereby disclaim all other warranties including implied warranties of merchantability or fitness for a particular purpose.
                        
                        Limitations
                        
                        In no event shall Quick Brain Games or its suppliers be liable for any damages arising out of the use or inability to use the app.
                        
                        Accuracy of Materials
                        
                        The materials appearing in Quick Brain Games could include technical, typographical, or photographic errors. We do not warrant that any of the materials are accurate, complete, or current.
                        
                        Modifications
                        
                        We may revise these Terms at any time without notice. By using Quick Brain Games you are agreeing to be bound by the current version of these Terms.
                        
                        Contact Information
                        
                        If you have any questions about these Terms, please contact us through the app settings.
                        """)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

