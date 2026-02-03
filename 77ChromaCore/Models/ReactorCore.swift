//
//  ReactorCore.swift
//  77ChromaCore
//

import Foundation

/// Segment counts per ring: inner 4, middle 8, outer 12
struct ReactorConfig {
    static let innerCount = 4
    static let middleCount = 8
    static let outerCount = 12
    static var ringCounts: [Int] { [innerCount, middleCount, outerCount] }
}

final class ReactorCore {
    var rings: [[ReactorSegment]]
    var rotationAngles: [Double]
    var energyLevel: Double
    var temperature: Double
    var stability: Double
    var movesRemaining: Int
    var score: Int
    var level: Int
    
    var thermalShieldMovesLeft: Int = 0
    var nextMatchDouble: Bool = false
    var lockedRingIndex: Int? = nil
    
    let maxMoves: Int
    private var coolingRate: Double { level <= 15 ? 0.03 : 0.02 }
    private let stabilityDrift: Double = 0.01
    
    init(level: Int = 1, maxMoves: Int? = nil, seed: Int? = nil) {
        self.level = level
        let moves = maxMoves ?? Self.movesForLevel(level)
        self.maxMoves = moves
        self.movesRemaining = moves
        self.score = 0
        self.energyLevel = 0.4
        self.temperature = 0.4
        self.stability = 0.0
        self.rotationAngles = [0, 0, 0]
        self.rings = ReactorCore.createInitialRings(seed: seed, level: level)
    }
    
    /// More moves on early levels.
    static func movesForLevel(_ level: Int) -> Int {
        switch level {
        case 1...5: return 40
        case 6...15: return 32
        case 16...30: return 28
        default: return 25
        }
    }
    
    static func createInitialRings(seed: Int? = nil, level: Int = 1) -> [[ReactorSegment]] {
        var rng: RandomNumberGenerator
        if let s = seed {
            rng = SeededRandomNumberGenerator(seed: UInt64(bitPattern: Int64(s)))
        } else {
            rng = SystemRandomNumberGenerator()
        }
        let counts = ReactorConfig.ringCounts
        let bias = Self.colorBiasForLevel(level)
        return counts.enumerated().map { ringIndex, count in
            (0..<count).map { pos in
                let type = Self.randomEnergyType(using: &rng, bias: bias)
                return ReactorSegment(
                    energyType: type,
                    ringIndex: ringIndex,
                    positionIndex: pos
                )
            }
        }
    }
    
    /// Early levels: more green (stable), less red (critical) so temperature is easier to control.
    static func colorBiasForLevel(_ level: Int) -> (stable: Double, critical: Double, balancing: Double) {
        switch level {
        case 1...5: return (0.50, 0.15, 0.35)   // very easy
        case 6...12: return (0.40, 0.25, 0.35)
        case 13...25: return (0.35, 0.35, 0.30)
        default: return (0.33, 0.34, 0.33)       // even
        }
    }
    
    static func randomEnergyType(using rng: inout RandomNumberGenerator, bias: (stable: Double, critical: Double, balancing: Double)) -> EnergyType {
        let r = Double.random(in: 0..<1, using: &rng)
        if r < bias.stable { return .stable }
        if r < bias.stable + bias.critical { return .critical }
        return .balancing
    }
    
    struct SeededRandomNumberGenerator: RandomNumberGenerator {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }
    }
    
    func rotateRing(_ ringIndex: Int, by angle: Double) {
        guard ringIndex >= 0, ringIndex < rings.count, movesRemaining > 0 else { return }
        rotationAngles[ringIndex] += angle
        movesRemaining -= 1
        updateReactorState()
    }
    
    func rotateRingSteps(_ ringIndex: Int, steps: Int) {
        guard ringIndex >= 0, ringIndex < rings.count, movesRemaining > 0 else { return }
        if lockedRingIndex == ringIndex { return }
        let count = rings[ringIndex].count
        guard count > 0 else { return }
        let normalizedSteps = ((steps % count) + count) % count
        if normalizedSteps == 0 { return }
        
        if thermalShieldMovesLeft > 0 { thermalShieldMovesLeft -= 1 }
        
        var ring = rings[ringIndex]
        let slice = ring.suffix(normalizedSteps)
        ring.removeLast(normalizedSteps)
        ring.insert(contentsOf: slice, at: 0)
        for i in ring.indices {
            ring[i].positionIndex = i
        }
        rings[ringIndex] = ring
        movesRemaining -= 1
        
        processMatches()
        updateReactorState()
    }
    
    func checkForMatches() -> [EnergyMatch] {
        var matches: [EnergyMatch] = []
        let counts = ReactorConfig.ringCounts
        let resolution = 24
        for radial in 0..<resolution {
            var byType: [EnergyType: [ReactorSegment]] = [.stable: [], .critical: [], .balancing: []]
            for (ringIndex, ring) in rings.enumerated() {
                let count = counts[ringIndex]
                let pos = (radial * count / resolution) % count
                let segment = ring[pos]
                byType[segment.energyType, default: []].append(segment)
            }
            for (type, segs) in byType where segs.count >= 3 {
                matches.append(EnergyMatch(type: type, segments: segs, ringPositions: Array(0..<rings.count), chainPotential: 0))
            }
        }
        for (ringIndex, ring) in rings.enumerated() {
            let count = ring.count
            for start in 0..<count {
                let type = ring[start].energyType
                var line: [ReactorSegment] = [ring[start]]
                for offset in 1..<count {
                    let pos = (start + offset) % count
                    if ring[pos].energyType == type {
                        line.append(ring[pos])
                    } else { break }
                }
                if line.count >= 3 {
                    matches.append(EnergyMatch(type: type, segments: line, ringPositions: [ringIndex], chainPotential: 0))
                }
            }
        }
        return matches
    }
    
    private func processMatches() {
        let matches = checkForMatches()
        var combo = 1
        let doubleMultiplier = nextMatchDouble ? 2 : 1
        if !matches.isEmpty && nextMatchDouble { nextMatchDouble = false }
        for match in matches {
            for seg in match.segments {
                score += match.type.energyValue * 10 * combo * doubleMultiplier
                energyLevel = min(1.0, energyLevel + Double(match.type.energyValue) * 0.05)
                if thermalShieldMovesLeft <= 0 {
                    temperature = max(0, min(1.0, temperature + match.type.heatEffect))
                }
                stability = max(-1, min(1, stability + match.type.stabilityEffect))
            }
            combo += 1
        }
        if !matches.isEmpty {
            setActiveSegments(matches.flatMap { $0.segments })
        } else {
            clearActiveSegments()
        }
    }
    
    func recalibrateRing(_ ringIndex: Int) {
        guard ringIndex >= 0, ringIndex < rings.count else { return }
        for i in rings[ringIndex].indices {
            rings[ringIndex][i].energyType = EnergyType.allCases.randomElement()!
        }
    }
    
    private func setActiveSegments(_ segments: [ReactorSegment]) {
        let positions = Set(segments.map { "\($0.ringIndex):\($0.positionIndex)" })
        for ringIndex in rings.indices {
            for segIndex in rings[ringIndex].indices {
                rings[ringIndex][segIndex].isActive = positions.contains("\(ringIndex):\(segIndex)")
            }
        }
    }
    
    private func clearActiveSegments() {
        for ringIndex in rings.indices {
            for segIndex in rings[ringIndex].indices {
                rings[ringIndex][segIndex].isActive = false
            }
        }
    }
    
    func updateReactorState() {
        temperature = max(0, temperature - coolingRate)
        if stability > 0 { stability = max(0, stability - stabilityDrift) }
        else if stability < 0 { stability = min(0, stability + stabilityDrift) }
    }
    
    var isEnergyCritical: Bool { energyLevel < 0.2 }
    var isOverheating: Bool { temperature > 0.8 }
    var isDestabilized: Bool { abs(stability) > 0.8 }
    var hasExploded: Bool { temperature >= 1.0 }
    
    /// Easier win conditions on early levels.
    var isLevelComplete: Bool {
        switch level {
        case 1...5:
            return energyLevel >= 0.35 && temperature < 0.85 && abs(stability) < 0.75
        case 6...12:
            return energyLevel >= 0.4 && temperature < 0.78 && abs(stability) < 0.7
        case 13...25:
            return energyLevel >= 0.45 && temperature < 0.72 && abs(stability) < 0.65
        default:
            return energyLevel >= 0.5 && temperature < 0.7 && abs(stability) < 0.6
        }
    }
}
