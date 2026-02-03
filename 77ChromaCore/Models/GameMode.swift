//
//  GameMode.swift
//  77ChromaCore
//

import Foundation

enum GameMode: Hashable {
    case level(Int)   // Story level 1...100
    case endless      // One life, score attack
    case daily        // Same seed per day, daily leaderboard
}
