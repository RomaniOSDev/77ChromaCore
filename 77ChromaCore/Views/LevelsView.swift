//
//  LevelsView.swift
//  77ChromaCore
//

import SwiftUI

private let chapters = [
    (title: "Chapter 1: Balance Basics", range: 1...25),
    (title: "Chapter 2: Energy Challenges", range: 26...50),
    (title: "Chapter 3: Extreme Conditions", range: 51...75),
    (title: "Chapter 4: Boss Reactors", range: 76...100),
]

struct LevelsView: View {
    @State private var selectedLevel: Int?
    private var progress: ProgressService { ProgressService.shared }
    
    var body: some View {
        ZStack {
            ChromaTheme.background
                .ignoresSafeArea()
            gridOverlay
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Select Level")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    ForEach(Array(chapters.enumerated()), id: \.offset) { _, chapter in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(chapter.title)
                                .font(.headline)
                                .foregroundStyle(ChromaTheme.balancing)
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 52), spacing: 10)
                            ], spacing: 10) {
                                ForEach(chapter.range, id: \.self) { level in
                                    let unlocked = progress.isLevelUnlocked(level)
                                    let highScore = progress.highScore(forLevel: level)
                                    Button {
                                        if unlocked { selectedLevel = level }
                                    } label: {
                                        VStack(spacing: 2) {
                                            Text("\(level)")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            if highScore > 0 {
                                                Text("\(highScore)")
                                                    .font(.system(size: 9))
                                                    .opacity(0.8)
                                            }
                                        }
                                        .foregroundStyle(unlocked ? ChromaTheme.background : Color.white.opacity(0.4))
                                        .frame(width: 52, height: 52)
                                        .background(unlocked ? ChromaTheme.stable.opacity(0.9) : Color.white.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!unlocked)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationDestination(item: $selectedLevel) { level in
                GameView(level: level, mode: .level(level))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Levels")
                    .font(.headline)
                    .foregroundStyle(.white)
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
}

#Preview {
    NavigationStack {
        LevelsView()
    }
}
