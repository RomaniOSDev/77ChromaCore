//
//  ReactorSegment.swift
//  77ChromaCore
//

import Foundation

struct ReactorSegment: Identifiable, Equatable {
    let id: UUID
    var energyType: EnergyType
    var ringIndex: Int
    var positionIndex: Int
    var isActive: Bool
    
    init(id: UUID = UUID(), energyType: EnergyType, ringIndex: Int, positionIndex: Int, isActive: Bool = false) {
        self.id = id
        self.energyType = energyType
        self.ringIndex = ringIndex
        self.positionIndex = positionIndex
        self.isActive = isActive
    }
}

struct EnergyMatch: Identifiable {
    let id = UUID()
    let type: EnergyType
    let segments: [ReactorSegment]
    let ringPositions: [Int]
    var chainPotential: Int
}
