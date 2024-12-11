//
//  Untitled.swift
//  MovieQuiz
//
//  Created by Kira on 28.10.2024.
//

import Foundation
import UIKit

private struct Fonts {
    let YSDisplayBold: String = "YSDisplay-Bold"
    let YSDisplayMedium: String = "YSDisplay-Medium"
}

public func printSystemFonts() {
    
    // MARK: - Идентификатор для фильтрации системных шрифтов в журналах
    let identifier: String = "[SYSTEM FONTS]"
    
    // MARK: - Функциональность, которая печатает все системные шрифты
    for family in UIFont.familyNames as [String] {
        
        debugPrint("\(identifier) FONT FAMILY :  \(family)")
        for name in UIFont.fontNames(forFamilyName: family) {
            debugPrint("\(identifier) FONT NAME :  \(name)")
        }
    }
}
