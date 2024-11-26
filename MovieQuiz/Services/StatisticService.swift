//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Kira on 13.11.2024.
//

import Foundation

// MARK: - Расширяем при объявлении

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    var totalAccuracy: Double {
        if gamesCount == 0 {
            return 0
        }
        return 100 * storage.double(forKey: Keys.totalCorrect.rawValue) / (10*Double(gamesCount))
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue,forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct: Int = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total: Int = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date: Date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return .init(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct,forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total,forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date,forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    private enum Keys: String {
        case totalCorrect = "totalCorrect"
        case bestGameCorrect = "bestGame.correct"
        case bestGameTotal = "bestGame.total"
        case bestGameDate = "bestGame.date"
        case gamesCount = "gamesCount"
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount+=1
        let gameResult: GameResult = .init(correct: count, total: amount, date: Date())
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
        let totalCorrect: Int = storage.integer(forKey: Keys.totalCorrect.rawValue) + count
        storage.set(totalCorrect,forKey: Keys.totalCorrect.rawValue)
        
    }
}
