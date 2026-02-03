//
//  EnergyType.swift
//  77ChromaCore
//

import SwiftUI

enum EnergyType: String, CaseIterable, Codable {
    case stable       // #28a809 — safe, low energy, cools
    case critical     // #e6053a — dangerous, high energy, heats
    case balancing    // #d17305 — stabilizes, moderate energy
    
    var color: Color {
        switch self {
        case .stable: return Color(hex: "28a809")
        case .critical: return Color(hex: "e6053a")
        case .balancing: return Color(hex: "d17305")
        }
    }
    
    var energyValue: Int {
        switch self {
        case .stable: return 1
        case .critical: return 3
        case .balancing: return 2
        }
    }
    
    var heatEffect: Double {
        switch self {
        case .stable: return -0.1
        case .critical: return 0.3
        case .balancing: return 0.0
        }
    }
    
    var stabilityEffect: Double {
        switch self {
        case .stable: return 0.05
        case .critical: return -0.1
        case .balancing: return 0.15
        }
    }
    
    var displayName: String {
        switch self {
        case .stable: return "Stable"
        case .critical: return "Critical"
        case .balancing: return "Balancing"
        }
    }
}
