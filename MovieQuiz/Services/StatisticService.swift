//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Руслан Меланин on 02.06.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage = UserDefaults.standard
    
    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
    
    // Общее количество игр

    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    // Средняя точность (все правильные / все вопросы)

    var totalAccuracy: Double {
        let correct = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let total = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard total > 0 else { return 0.0 }
        return (Double(correct) / Double(total)) * 100
    }
    
    // Результат лучшей игры

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    // Сохранение результата новой игры
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let previousCorrect = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let previousTotal = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        storage.set(previousCorrect + count, forKey: Keys.correctAnswers.rawValue)
        storage.set(previousTotal + amount, forKey: Keys.totalQuestions.rawValue)
        
        let current = GameResult(correct: count, total: amount, date: Date())
        if current.isBetterThan(bestGame) {
            bestGame = current
        }
    }
}
