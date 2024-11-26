//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kira on 12.11.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
