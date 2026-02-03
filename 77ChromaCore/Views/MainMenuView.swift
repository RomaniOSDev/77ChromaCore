//
//  MainMenuView.swift
//  77ChromaCore
//

import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    @State private var gameLevel = 1
    @State private var gameMode: GameMode = .level(1)
    @State private var showHowToPlay = false
    
    private var progress: ProgressService { ProgressService.shared }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [ChromaTheme.background, Color(hex: "151520"), ChromaTheme.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                gridOverlay
                VStack(spacing: 32) {
                    Spacer()
                    titleBlock
                    Spacer()
                    primaryButtons
                    secondaryButtons
                    Spacer().frame(height: 48)
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(level: gameLevel, mode: gameMode)
            }
            .navigationDestination(for: MenuDestination.self) { destination in
                switch destination {
                case .levels:
                    LevelsView()
                case .settings:
                    SettingsView()
                }
            }
            .sheet(isPresented: $showHowToPlay) {
                NavigationStack {
                    HowToPlayView()
                }
            }
        }
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
    
    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text("CHROMA CORE")
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ChromaTheme.stable, ChromaTheme.balancing, ChromaTheme.critical],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: ChromaTheme.stable.opacity(0.5), radius: 12, x: 0, y: 0)
                .shadow(color: ChromaTheme.critical.opacity(0.3), radius: 20, x: 0, y: 4)
            Text("Balance the energy. Control the reaction.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
    }
    
    private var primaryButtons: some View {
        VStack(spacing: 12) {
            if progress.lastCompletedLevel > 0 {
                Button {
                    gameLevel = progress.nextLevelToPlay
                    gameMode = .level(gameLevel)
                    showGame = true
                } label: {
                    Text("Continue (Level \(progress.nextLevelToPlay))")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(ChromaTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [ChromaTheme.balancing, ChromaTheme.balancing.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .shadow(color: ChromaTheme.balancing.opacity(0.4), radius: ChromaTheme.buttonShadowRadius, x: 0, y: ChromaTheme.buttonShadowY)
            }
            Button {
                gameLevel = 1
                gameMode = .level(1)
                showGame = true
            } label: {
                Text(progress.lastCompletedLevel > 0 ? "Start from Level 1" : "Start Reactor")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(ChromaTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [ChromaTheme.stable, ChromaTheme.stable.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .shadow(color: ChromaTheme.stable.opacity(0.4), radius: ChromaTheme.buttonShadowRadius, x: 0, y: ChromaTheme.buttonShadowY)
            Button {
                gameLevel = 1
                gameMode = .endless
                showGame = true
            } label: {
                HStack {
                    Text("Endless")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Spacer()
                    Text("Best: \(progress.endlessBestScore)")
                        .font(.caption)
                        .opacity(0.9)
                }
                .foregroundStyle(ChromaTheme.background)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [ChromaTheme.critical, ChromaTheme.critical.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .shadow(color: ChromaTheme.critical.opacity(0.5), radius: ChromaTheme.buttonShadowRadius, x: 0, y: ChromaTheme.buttonShadowY)
            Button {
                gameLevel = 1
                gameMode = .daily
                showGame = true
            } label: {
                HStack {
                    Text("Daily Challenge")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Spacer()
                    let (best, _) = progress.dailyScoreAndDate
                    Text("Today: \(best)")
                        .font(.caption)
                        .opacity(0.9)
                }
                .foregroundStyle(ChromaTheme.background)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [ChromaTheme.balancing.opacity(0.95), ChromaTheme.balancing.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .shadow(color: ChromaTheme.balancing.opacity(0.4), radius: ChromaTheme.buttonShadowRadius, x: 0, y: ChromaTheme.buttonShadowY)
        }
    }
    
    private var secondaryButtons: some View {
        VStack(spacing: 12) {
            Button("How to Play") {
                showHowToPlay = true
            }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ChromaTheme.balancing)
            NavigationLink(value: MenuDestination.levels) {
                HStack {
                    Text("Levels")
                    Spacer()
                    Text("\(progress.highestUnlockedLevel)/100")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
            }
            NavigationLink(value: MenuDestination.settings) {
                Text("Settings")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

enum MenuDestination: Hashable {
    case levels
    case settings
}

#Preview {
    MainMenuView()
}
