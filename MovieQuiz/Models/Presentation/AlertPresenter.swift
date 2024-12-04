//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Kira on 12.11.2024.
//

import Foundation
import UIKit

final class AlertPresenter {
    private weak var delegate: UIViewController?
    
    func setup(delegate: UIViewController) {
        self.delegate = delegate
        
    }
    
    // MARK: - Показа результатов раунда квиза
    
    func showAlert(alert alertMobel: AlertModel) {
        let alert = UIAlertController(
            title: alertMobel.title,
            message: alertMobel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertMobel.buttonText, style: .default) { _ in
            alertMobel.completion()
        }
        alert.addAction(action)
        
        delegate?.present(alert, animated: true)
    }
}

