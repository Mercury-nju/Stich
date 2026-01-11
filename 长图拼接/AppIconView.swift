//
//  AppIconView.swift
//  长图拼接
//
//  Created by Mercury on 2026/1/11.
//
//  Use this view to generate your App Icon:
//  1. Run the preview in Xcode
//  2. Take a screenshot or use a tool to export at 1024x1024
//  3. Save as AppIcon.png in Assets.xcassets/AppIcon.appiconset/
//

import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    
    private let gradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(gradient)
            
            // Icon design - stacked photos
            VStack(spacing: size * 0.02) {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(.white.opacity(0.9 - Double(index) * 0.15))
                        .frame(
                            width: size * 0.55,
                            height: size * 0.18
                        )
                        .offset(x: CGFloat(index - 1) * size * 0.03)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview("App Icon 1024") {
    AppIconView(size: 1024)
}

#Preview("App Icon 180") {
    AppIconView(size: 180)
}

#Preview("App Icon 60") {
    AppIconView(size: 60)
}
