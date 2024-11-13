//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Kira on 12.11.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
