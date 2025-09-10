//
//  HapticManager.swift
//  FrogHouse
//
//  Created by SJS on 9/10/25.
//

import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    // 종류: warning, error, success
    func hapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    // 종류: heavy, light, meduium, rigid, soft
    func hapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
