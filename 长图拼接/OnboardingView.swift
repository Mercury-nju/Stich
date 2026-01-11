//
//  OnboardingView.swift
//  长图拼接
//
//  Created by Mercury on 2026/1/11.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let accentGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    icon: "photo.stack.fill",
                    title: "Stitch Photos",
                    description: "Combine multiple photos into a single long image, perfect for screenshots, comics, or chat histories.",
                    gradient: accentGradient
                )
                .tag(0)
                
                OnboardingPage(
                    icon: "hand.draw.fill",
                    title: "Easy to Reorder",
                    description: "Simply drag and drop to arrange your photos in any order you want.",
                    gradient: accentGradient
                )
                .tag(1)
                
                OnboardingPage(
                    icon: "lock.shield.fill",
                    title: "Privacy First",
                    description: "All processing happens on your device. Your photos never leave your phone.",
                    gradient: accentGradient
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Page indicator & button
            VStack(spacing: 30) {
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(currentPage == index ? Color(hex: "667eea") : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                
                Button {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isPresented = false
                    }
                } label: {
                    Text(currentPage < 2 ? "Continue" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                
                if currentPage < 2 {
                    Button("Skip") {
                        isPresented = false
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 50)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(gradient.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(gradient)
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
