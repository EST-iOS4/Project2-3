//
//  Double+Extension.swift
//  FrogHouse
//
//  Created by 이건준 on 9/8/25.
//

import Foundation

extension Double {
    /// 초(seconds)를 "m:ss" 형식 문자열로 변환
    var formattedTime: String {
        guard self.isFinite && !self.isNaN else { return "0:00" }
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

