//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Kira on 13.11.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
}
