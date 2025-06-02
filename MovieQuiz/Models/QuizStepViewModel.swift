//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Руслан Меланин on 28.05.2025.
//

import UIKit

// вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
  // картинка с афишей фильма с типом UIImage
  let image: UIImage
  // вопрос о рейтинге квиза
  let question: String
  // строка с порядковым номером этого вопроса (ex. "1/10")
  let questionNumber: String
}
