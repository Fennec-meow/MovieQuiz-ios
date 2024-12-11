//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Kira on 12.11.2024.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
