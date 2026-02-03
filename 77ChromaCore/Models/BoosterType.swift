//
//  BoosterType.swift
//  77ChromaCore
//

import SwiftUI

enum BoosterType: String, CaseIterable, Identifiable {
    case thermalShield   // Protect from overheating for 3 moves
    case energyPulse     // Double next match score
    case stabilizer      // Lock one ring from rotating
    case recalibration   // Shuffle colors on one ring
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .thermalShield: return "Thermal Shield"
        case .energyPulse: return "Energy Pulse"
        case .stabilizer: return "Stabilizer"
        case .recalibration: return "Recalibration"
        }
    }
    
    var shortName: String {
        switch self {
        case .thermalShield: return "Shield"
        case .energyPulse: return "Pulse"
        case .stabilizer: return "Lock"
        case .recalibration: return "Recal"
        }
    }
    
    var iconName: String {
        switch self {
        case .thermalShield: return "shield.fill"
        case .energyPulse: return "bolt.fill"
        case .stabilizer: return "lock.fill"
        case .recalibration: return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .thermalShield: return ChromaTheme.critical
        case .energyPulse: return ChromaTheme.stable
        case .stabilizer: return ChromaTheme.balancing
        case .recalibration: return ChromaTheme.balancing
        }
    }
    
    var description: String {
        switch self {
        case .thermalShield: return "Temperature does not rise from matches for the next 3 moves."
        case .energyPulse: return "Your next line match will give double points."
        case .stabilizer: return "Locks the selected ring so it cannot rotate. Tap again on same ring to unlock (no cost)."
        case .recalibration: return "Randomly changes all segment colors on the selected ring."
        }
    }
    
    var usageHint: String {
        switch self {
        case .thermalShield, .energyPulse: return "Just tap to activate."
        case .stabilizer, .recalibration: return "Long-press a ring to select it (orange outline), then tap this booster."
        }
    }
}
