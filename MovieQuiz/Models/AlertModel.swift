//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Руслан Меланин on 29.05.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonTitle: String
    let completion: () -> Void
}
