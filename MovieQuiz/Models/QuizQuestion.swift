//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Руслан Меланин on 28.05.2025.
//

import UIKit

struct QuizQuestion {
  // строка с названием фильма, cовпадает с названием картинки афиши фильма в Assets
  let imageData: Data
  // строка с вопросом о рейтинге фильма
  let text: String
  // булевое значение (true, false), правильный ответ на вопрос
  let correctAnswer: Bool
    
}
