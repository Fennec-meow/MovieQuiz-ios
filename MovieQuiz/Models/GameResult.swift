//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Kira on 13.11.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
