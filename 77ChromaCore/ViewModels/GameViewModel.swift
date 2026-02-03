//
//  GameViewModel.swift
//  77ChromaCore
//

import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var reactor: ReactorCore
    @Published var selectedRingIndex: Int?
    @Published var isPaused: Bool = false
    @Published var showLevelComplete: Bool = false
    @Published var showExplosion: Bool = false
    @Published var showOutOfMoves: Bool = false
    @Published var boosterCounts: [BoosterType: Int]
    @Published var showBoosterAlert: BoosterType?
    
    let mode: GameMode
    var maxMoves: Int { reactor.maxMoves }
    
    var movesRemaining: Int { reactor.movesRemaining }
    var score: Int { reactor.score }
    var level: Int { reactor.level }
    var energyLevel: Double { reactor.energyLevel }
    var temperature: Double { reactor.temperature }
    var stability: Double { reactor.stability }
    var rings: [[ReactorSegment]] { reactor.rings }
    
    var isEndless: Bool { if case .endless = mode { return true }; return false }
    var isDaily: Bool { if case .daily = mode { return true }; return false }
    var isStoryLevel: Bool { if case .level = mode { return true }; return false }
    
    init(level: Int = 1, mode: GameMode = .level(1), maxMoves: Int? = nil) {
        self.mode = mode
        let moves: Int
        let seed: Int?
        switch mode {
        case .level(let l):
            moves = maxMoves ?? ReactorCore.movesForLevel(l)
            seed = nil
        case .endless:
            moves = maxMoves ?? 99
            seed = nil
        case .daily:
            moves = maxMoves ?? 25
            seed = ProgressService.shared.dailySeed
        }
        self.reactor = ReactorCore(level: level, maxMoves: moves, seed: seed)
        self.boosterCounts = ProgressService.shared.defaultBoosterCounts()
    }
    
    func rotateRing(_ ringIndex: Int, clockwise: Bool) {
        guard !reactor.hasExploded, reactor.movesRemaining > 0 else { return }
        let count = reactor.rings[ringIndex].count
        reactor.rotateRingSteps(ringIndex, steps: clockwise ? (count - 1) : 1)
        objectWillChange.send()
        if reactor.hasExploded {
            showExplosion = true
            if isEndless { ProgressService.shared.saveEndlessScore(score) }
            if isDaily { ProgressService.shared.saveDailyScore(score) }
        } else if reactor.isLevelComplete {
            showLevelComplete = true
            if case .level(let l) = mode {
                ProgressService.shared.saveLevelComplete(level: l, score: score)
            }
            if isEndless { ProgressService.shared.saveEndlessScore(score) }
            if isDaily { ProgressService.shared.saveDailyScore(score) }
        } else if reactor.movesRemaining == 0 {
            showOutOfMoves = true
            if isEndless { ProgressService.shared.saveEndlessScore(score) }
            if isDaily { ProgressService.shared.saveDailyScore(score) }
        }
    }
    
    func selectRing(_ index: Int?) {
        selectedRingIndex = index
    }
    
    func useBooster(_ type: BoosterType) {
        guard let count = boosterCounts[type], count > 0 else { return }
        switch type {
        case .thermalShield:
            reactor.thermalShieldMovesLeft = 3
            boosterCounts[type] = count - 1
            objectWillChange.send()
        case .energyPulse:
            reactor.nextMatchDouble = true
            boosterCounts[type] = count - 1
            objectWillChange.send()
        case .stabilizer:
            if let ring = selectedRingIndex {
                if reactor.lockedRingIndex == ring {
                    reactor.lockedRingIndex = nil
                } else {
                    reactor.lockedRingIndex = ring
                    boosterCounts[type] = count - 1
                }
                objectWillChange.send()
            } else {
                showBoosterAlert = type
            }
        case .recalibration:
            if let ring = selectedRingIndex {
                reactor.recalibrateRing(ring)
                boosterCounts[type] = count - 1
                objectWillChange.send()
            } else {
                showBoosterAlert = type
            }
        }
    }
    
    func dismissBoosterAlert() {
        showBoosterAlert = nil
    }
    
    func nextLevel() {
        showLevelComplete = false
        if case .level(let l) = mode {
            reactor = ReactorCore(level: l + 1, maxMoves: nil, seed: nil)
        } else {
            reactor = ReactorCore(level: 1, maxMoves: 99, seed: nil)
        }
        boosterCounts = ProgressService.shared.defaultBoosterCounts()
    }
    
    func restartLevel() {
        showExplosion = false
        showOutOfMoves = false
        let seed: Int? = isDaily ? ProgressService.shared.dailySeed : nil
        let moves: Int? = isStoryLevel ? nil : (isEndless ? 99 : 25)
        reactor = ReactorCore(level: reactor.level, maxMoves: moves, seed: seed)
        boosterCounts = ProgressService.shared.defaultBoosterCounts()
        objectWillChange.send()
    }
    
    func togglePause() {
        isPaused.toggle()
    }
}
