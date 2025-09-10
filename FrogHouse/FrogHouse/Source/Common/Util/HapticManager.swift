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
    
    func hapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func hapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
