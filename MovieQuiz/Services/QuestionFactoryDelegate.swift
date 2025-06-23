//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Руслан Меланин on 29.05.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
