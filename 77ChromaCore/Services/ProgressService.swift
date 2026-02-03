//
//  ProgressService.swift
//  77ChromaCore
//

import Foundation

final class ProgressService {
    static let shared = ProgressService()
    
    private let defaults = UserDefaults.standard
    private let keyLastCompletedLevel = "progress_lastCompletedLevel"
    private let keyHighScores = "progress_highScores"
    private let keyEndlessBestScore = "progress_endlessBestScore"
    private let keyDailyScore = "progress_dailyScore"
    private let keyDailyDate = "progress_dailyDate"
    private let keyBoosterCounts = "progress_boosterCounts"
    
    var lastCompletedLevel: Int {
        get { defaults.integer(forKey: keyLastCompletedLevel) }
        set { defaults.set(newValue, forKey: keyLastCompletedLevel) }
    }
    
    /// Next level to play (e.g. for Continue). Level 1...100, or 1 if none completed.
    var nextLevelToPlay: Int {
        min(lastCompletedLevel + 1, 100)
    }
    
    /// Level N is unlocked if we completed N-1 (level 1 always unlocked).
    func isLevelUnlocked(_ level: Int) -> Bool {
        level <= 1 || lastCompletedLevel >= level - 1
    }
    
    /// Highest unlocked level number (1...100).
    var highestUnlockedLevel: Int {
        min(lastCompletedLevel + 1, 100)
    }
    
    func highScore(forLevel level: Int) -> Int {
        let dict = defaults.dictionary(forKey: keyHighScores) as? [String: Int] ?? [:]
        return dict["\(level)"] ?? 0
    }
    
    func saveLevelComplete(level: Int, score: Int) {
        if level > lastCompletedLevel {
            lastCompletedLevel = level
        }
        var dict = defaults.dictionary(forKey: keyHighScores) as? [String: Int] ?? [:]
        let prev = dict["\(level)"] ?? 0
        dict["\(level)"] = max(prev, score)
        defaults.set(dict, forKey: keyHighScores)
    }
    
    var endlessBestScore: Int {
        get { defaults.integer(forKey: keyEndlessBestScore) }
        set { defaults.set(newValue, forKey: keyEndlessBestScore) }
    }
    
    func saveEndlessScore(_ score: Int) {
        if score > endlessBestScore {
            endlessBestScore = score
        }
    }
    
    /// Returns (score, dateString) for today's daily. Date string is "yyyy-MM-dd".
    var dailyScoreAndDate: (score: Int, date: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let storedDate = defaults.string(forKey: keyDailyDate) ?? ""
        let score = storedDate == today ? defaults.integer(forKey: keyDailyScore) : 0
        return (score, today)
    }
    
    func saveDailyScore(_ score: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let (currentBest, storedDate) = dailyScoreAndDate
        if storedDate != today || score > currentBest {
            defaults.set(today, forKey: keyDailyDate)
            defaults.set(max(score, currentBest), forKey: keyDailyScore)
        }
    }
    
    /// Seed for daily challenge: same for everyone on the same calendar day.
    var dailySeed: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let s = formatter.string(from: Date())
        return Int(s) ?? 0
    }
    
    /// Default booster counts per game (can be overridden).
    func defaultBoosterCounts() -> [BoosterType: Int] {
        var d: [BoosterType: Int] = [:]
        for t in BoosterType.allCases {
            d[t] = 3
        }
        return d
    }
    
    private init() {}
}
