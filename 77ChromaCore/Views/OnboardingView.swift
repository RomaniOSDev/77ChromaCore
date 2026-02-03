//
//  OnboardingView.swift
//  77ChromaCore
//

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    
    @State private var currentPage = 0
    
    private let pages: [(title: String, subtitle: String, icon: String)] = [
        ("Balance the Energy", "Rotate the reactor rings to align segments of the same color. Create lines to score and stabilize the core.", "circle.hexagongrid.fill"),
        ("Three Types of Power", "Green cools and stabilizes. Red gives power but heats. Orange balances. Keep temperature and energy in the safe zone.", "flame.fill"),
        ("Ready to React", "Use boosters when needed. Complete levels, try Endless mode, or take the Daily Challenge. Good luck, Engineer.", "bolt.shield.fill")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ChromaTheme.background, Color(hex: "151520"), ChromaTheme.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            gridOverlay
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(title: page.title, subtitle: page.subtitle, icon: page.icon)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                pageIndicator
                Spacer().frame(height: 24)
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(ChromaTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [ChromaTheme.stable, ChromaTheme.stable.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .shadow(color: ChromaTheme.stable.opacity(0.4), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
    
    private func onboardingPage(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ChromaTheme.stable, ChromaTheme.balancing, ChromaTheme.critical],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: ChromaTheme.stable.opacity(0.4), radius: 16)
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 28)
            Spacer()
            Spacer()
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? ChromaTheme.stable : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
            }
        }
        .padding(.bottom, 16)
    }
    
    private var gridOverlay: some View {
        GeometryReader { g in
            Path { p in
                let step: CGFloat = 24
                var x: CGFloat = 0
                while x <= g.size.width {
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: g.size.height))
                    x += step
                }
                var y: CGFloat = 0
                while y <= g.size.height {
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: g.size.width, y: y))
                    y += step
                }
            }
            .stroke(Color.white.opacity(ChromaTheme.gridOpacity), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
