//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Руслан Меланин on 29.05.2025.
//

import UIKit

final class AlertPresenter {
    
    weak var movieQuizViewController: UIViewController?
    
    init(movieQuizViewController: UIViewController? = nil) {
        self.movieQuizViewController = movieQuizViewController
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonTitle, style: .default) { _ in
                    model.completion()
                }
        
        alert.addAction(action)
        movieQuizViewController?.present(alert, animated: true)
    }
    
}
