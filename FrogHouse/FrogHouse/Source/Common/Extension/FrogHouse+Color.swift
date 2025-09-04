//
//  FrogHouse+Color.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

/// 모든 색상은 라이트/다크 두 가지 버전을 가져야 한다
protocol AppColor {
    var light: UIColor { get }
    var dark: UIColor { get }
}

extension AppColor {
    /// trait에 따라 적절한 색상 반환
    var color: UIColor {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? self.dark : self.light
        }
    }
    
    var cgColor: CGColor {
        color.cgColor
    }
}

extension UIColor {
    enum FH: AppColor {
        var light: UIColor { .white }
        var dark: UIColor { .black }
    }
}

