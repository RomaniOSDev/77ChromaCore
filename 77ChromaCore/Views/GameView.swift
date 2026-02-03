//
//  GameView.swift
//  77ChromaCore
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showHowToPlay = false
    
    init(level: Int = 1, mode: GameMode = .level(1)) {
        _viewModel = StateObject(wrappedValue: GameViewModel(level: level, mode: mode))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ChromaTheme.background, Color(hex: "121218"), ChromaTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            gridOverlay
            VStack(spacing: 0) {
                header
                reactorArea
                stabilityBar
                bottomPanel
            }
            if viewModel.showLevelComplete {
                levelCompleteOverlay
            }
            if viewModel.showExplosion {
                explosionOverlay
            }
            if viewModel.showOutOfMoves {
                outOfMovesOverlay
            }
            if viewModel.isPaused {
                pauseOverlay
            }
            if viewModel.showBoosterAlert != nil {
                boosterAlertOverlay
            }
        }
        .sheet(isPresented: $showHowToPlay) {
            NavigationStack {
                HowToPlayView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(ChromaTheme.balancing)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHowToPlay = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(ChromaTheme.balancing)
                }
            }
        }
    }
    
    private var gridOverlay: some View {
        GeometryReader { g in
            Path { p in
                let step: CGFloat = 20
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
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitleLabel)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Text(headerTitleValue)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
            )
            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(viewModel.score)")
                    .font(.title2.bold())
                    .foregroundStyle(ChromaTheme.stable)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(ChromaTheme.stable.opacity(0.25), lineWidth: 1))
            )
            .shadow(color: ChromaTheme.stable.opacity(0.2), radius: 6, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    private var headerTitleLabel: String {
        if viewModel.isEndless { return "Mode" }
        if viewModel.isDaily { return "Challenge" }
        return "Level"
    }
    
    private var headerTitleValue: String {
        if viewModel.isEndless { return "Endless" }
        if viewModel.isDaily { return "Daily" }
        return "\(viewModel.level)"
    }
    
    private var reactorArea: some View {
        HStack(alignment: .center, spacing: 12) {
            energyScale
            ReactorRingsView(
                rings: viewModel.rings,
                selectedRingIndex: viewModel.selectedRingIndex,
                lockedRingIndex: viewModel.reactor.lockedRingIndex,
                onRotateRing: { viewModel.rotateRing($0, clockwise: $1) },
                onSelectRing: { viewModel.selectRing($0) }
            )
            .onTapGesture(count: 2) { }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.35))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [ChromaTheme.balancing.opacity(0.3), ChromaTheme.critical.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            )
            .shadow(color: ChromaTheme.balancing.opacity(0.15), radius: 20, x: 0, y: 0)
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
            temperatureScale
        }
        .padding(.horizontal, 8)
    }
    
    private var energyScale: some View {
        VStack(spacing: 4) {
            Text("ENERGY")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.7))
            ScaleBar(value: viewModel.energyLevel, colors: [ChromaTheme.stable, ChromaTheme.balancing, ChromaTheme.critical])
                .frame(width: 14, height: 160)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.4)))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.15), lineWidth: 1))
            Text("\(Int(viewModel.energyLevel * 100))%")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(width: 38)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var temperatureScale: some View {
        VStack(spacing: 4) {
            Text("TEMP")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.7))
            ScaleBar(value: viewModel.temperature, colors: [ChromaTheme.stable, ChromaTheme.balancing, ChromaTheme.critical])
                .frame(width: 14, height: 160)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.4)))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.15), lineWidth: 1))
            Text("\(Int(viewModel.temperature * 100))%")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(width: 38)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var stabilityBar: some View {
        VStack(spacing: 4) {
            Text("STABILITY")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.7))
            StabilityBar(value: viewModel.stability)
                .frame(height: 10)
                .padding(.horizontal, 20)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.black.opacity(0.4)))
        }
        .padding(.vertical, 8)
    }
    
    private var bottomPanel: some View {
        VStack(spacing: 8) {
            controlHint
            if let ring = viewModel.selectedRingIndex {
                HStack(spacing: 12) {
                    Text("Ring \(ring + 1)")
                        .font(.caption)
                        .foregroundStyle(ChromaTheme.balancing)
                    Button { viewModel.rotateRing(ring, clockwise: false) } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                            .foregroundStyle(ChromaTheme.stable)
                    }
                    Button { viewModel.rotateRing(ring, clockwise: true) } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundStyle(ChromaTheme.stable)
                    }
                    Button("Deselect") { viewModel.selectRing(nil) }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            HStack(spacing: 16) {
                Button {
                    viewModel.togglePause()
                } label: {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundStyle(ChromaTheme.balancing)
                }
                Text("Moves: \(viewModel.movesRemaining)/\(viewModel.maxMoves)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
            }
            if activeBoosterHint != nil {
                Text(activeBoosterHint!)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ChromaTheme.stable)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Boosters")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 12) {
                    ForEach(BoosterType.allCases) { type in
                        boosterButton(type: type)
                    }
                }
                Text("Shield/Pulse: tap to use. Lock/Recal: long-press a ring to select, then tap.")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.black.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.white.opacity(0.1)),
            alignment: .top
        )
        .shadow(color: .black.opacity(0.5), radius: ChromaTheme.cardShadowRadius, x: 0, y: -2)
    }
    
    private var activeBoosterHint: String? {
        if viewModel.reactor.thermalShieldMovesLeft > 0 {
            return "Shield: no temp rise for \(viewModel.reactor.thermalShieldMovesLeft) moves"
        }
        if viewModel.reactor.nextMatchDouble {
            return "Next match: 2× score"
        }
        if let r = viewModel.reactor.lockedRingIndex {
            return "Ring \(r + 1) locked (tap Lock again to unlock)"
        }
        return nil
    }
    
    private func boosterButton(type: BoosterType) -> some View {
        let count = viewModel.boosterCounts[type] ?? 0
        return Button {
            viewModel.useBooster(type)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: type.iconName)
                    .font(.system(size: 12))
                    .foregroundStyle(count > 0 ? type.color : Color.white.opacity(0.3))
                Text(type.shortName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(count > 0 ? .white.opacity(0.9) : Color.white.opacity(0.4))
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(count > 0 ? type.color : Color.white.opacity(0.3))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(count > 0 ? type.color.opacity(0.2) : Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(count == 0)
        .buttonStyle(.plain)
    }
    
    private var boosterAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { viewModel.dismissBoosterAlert() }
            VStack(spacing: 16) {
                if let type = viewModel.showBoosterAlert {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundStyle(type.color)
                    Text(type.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    Text(type.usageHint)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Button("OK") { viewModel.dismissBoosterAlert() }
                        .foregroundStyle(ChromaTheme.stable)
                        .padding(.top, 4)
                }
            }
            .padding(24)
            .background(ChromaTheme.background.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var controlHint: some View {
        Text("Tap = rotate 1 step · Swipe left/right = rotate that ring")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.5))
    }
    
    private var levelCompleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(viewModel.isStoryLevel ? "Level Complete" : "Reactor Stable")
                    .font(.title.bold())
                    .foregroundStyle(ChromaTheme.stable)
                Text("Score: \(viewModel.score)")
                    .font(.title3)
                    .foregroundStyle(.white)
                if viewModel.isEndless {
                    Text("Best: \(ProgressService.shared.endlessBestScore)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                if viewModel.isDaily {
                    let (best, _) = ProgressService.shared.dailyScoreAndDate
                    Text("Today's best: \(best)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                HStack(spacing: 16) {
                    Button("Restart") {
                        viewModel.restartLevel()
                    }
                    .foregroundStyle(ChromaTheme.balancing)
                    if viewModel.isStoryLevel {
                        Button("Next Level") {
                            viewModel.nextLevel()
                        }
                        .foregroundStyle(ChromaTheme.stable)
                    } else {
                        Button("Back") {
                            dismiss()
                        }
                        .foregroundStyle(ChromaTheme.stable)
                    }
                }
            }
            .padding(32)
            .background(ChromaTheme.background.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(ChromaTheme.stable.opacity(0.3), lineWidth: 1))
            .shadow(color: .black.opacity(0.6), radius: 24, x: 0, y: 8)
        }
    }
    
    private var explosionOverlay: some View {
        ZStack {
            Color.white.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Reactor Overload")
                    .font(.title.bold())
                    .foregroundStyle(ChromaTheme.critical)
                Text("Score: \(viewModel.score)")
                    .font(.body)
                    .foregroundStyle(.white)
                if viewModel.isEndless {
                    Text("Best: \(ProgressService.shared.endlessBestScore)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                HStack(spacing: 16) {
                    Button("Restart") {
                        viewModel.restartLevel()
                    }
                    .foregroundStyle(ChromaTheme.balancing)
                    if viewModel.isEndless || viewModel.isDaily {
                        Button("Back") {
                            dismiss()
                        }
                        .foregroundStyle(ChromaTheme.stable)
                    }
                }
            }
            .padding(32)
        }
    }
    
    private var outOfMovesOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Out of Moves")
                    .font(.title.bold())
                    .foregroundStyle(ChromaTheme.balancing)
                Text("Score: \(viewModel.score)")
                    .font(.title3)
                    .foregroundStyle(.white)
                if viewModel.isEndless {
                    Text("Best: \(ProgressService.shared.endlessBestScore)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                if viewModel.isDaily {
                    let (best, _) = ProgressService.shared.dailyScoreAndDate
                    Text("Today's best: \(best)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                HStack(spacing: 16) {
                    Button("Restart") {
                        viewModel.restartLevel()
                    }
                    .foregroundStyle(ChromaTheme.balancing)
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundStyle(ChromaTheme.stable)
                }
            }
            .padding(32)
            .background(ChromaTheme.background.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(ChromaTheme.balancing.opacity(0.3), lineWidth: 1))
            .shadow(color: .black.opacity(0.6), radius: 24, x: 0, y: 8)
        }
    }
    
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Paused")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Button("Resume") {
                    viewModel.togglePause()
                }
                .foregroundStyle(ChromaTheme.stable)
                Button("How to Play") {
                    viewModel.togglePause()
                    showHowToPlay = true
                }
                .foregroundStyle(ChromaTheme.balancing)
            }
        }
    }
}

struct ScaleBar: View {
    let value: Double
    let colors: [Color]
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.15))
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: geo.size.height * CGFloat(max(0, min(1, value))))
            }
        }
    }
}

struct StabilityBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geo in
            let clamped = max(0, min(1, 0.5 + value * 0.5))
            let pos = geo.size.width * (CGFloat(clamped) - 0.1)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.15))
                RoundedRectangle(cornerRadius: 4)
                    .fill(ChromaTheme.balancing)
                    .frame(width: geo.size.width * 0.2)
                    .offset(x: pos)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameView()
    }
}
