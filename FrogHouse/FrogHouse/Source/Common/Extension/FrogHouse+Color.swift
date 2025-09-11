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
        /// Primary – 기본 텍스트, 버튼 (본문, 제목 등 메인 정보)
        case primary

        /// Secondary – 보조 텍스트,  버튼 (설명, 서브 정보)
        case secondary

        /// Tertiary – 약한 텍스트 (placeholder, hint 등)
        case tertiary

        /// Quaternary – 흐린 텍스트 (비활성화, 구분선 등)
        case quaternary

        /// Signature – 앱 아이덴티티 컬러green (주요 포인트 버튼)
        case signatureGreen

        /// Emphasis – 강조 컬러red (좋아요/하트/에러)
        case emphasis

        /// BackgroundPlain – 기본 배경색 (라이트: 흰색 / 다크: 검정)
        case backgroundBase

        /// BackgroundPlain – 미색 배경색 (라이트: 흰색 / 다크: 검정)
        case backgroundNeutral

        /// BackgroundFrog – 색들어간 서브 배경 (라이트: 밝은 메론 / 다크: 짙은 메론)
        /// 카드, 섹션 구분, 특수 영역 배경 등
        case backgroundLightGreen
var light: UIColor {
            switch self {
            case .primary: return UIColor(hex: "#000000") ?? .systemBackground
            case .secondary: return UIColor(hex: "#3C3C4399") ?? .systemBackground
            case .tertiary: return UIColor(hex: "#3C3C434C") ?? .systemBackground
            case .quaternary: return UIColor(hex: "#3C3C432E") ?? .systemBackground
            case .signatureGreen: return UIColor(hex: "#1DB954") ?? .systemBackground
            case .emphasis: return UIColor(hex: "#FF3B30") ?? .systemBackground
            case .backgroundBase: return UIColor(hex: "#FFFFFF") ?? .systemBackground
            case .backgroundNeutral: return UIColor(hex: "#F5F5F0") ?? .systemBackground
            case .backgroundLightGreen: return UIColor(hex: "#E6F8E0") ?? .systemBackground
            }
        }
var dark: UIColor {
            switch self {
            case .primary: return UIColor(hex: "#FFFFFF") ?? .systemBackground
            case .secondary: return UIColor(hex: "#EBEBF599") ?? .systemBackground
            case .tertiary: return UIColor(hex: "#EBEBF54C") ?? .systemBackground
            case .quaternary: return UIColor(hex: "#EBEBF52E") ?? .systemBackground
            case .signatureGreen: return UIColor(hex: "#1ED760") ?? .systemBackground
            case .emphasis: return UIColor(hex: "#FF453A") ?? .systemBackground
            case .backgroundBase: return UIColor(hex: "#121212") ?? .systemBackground
            case .backgroundNeutral: return UIColor(hex: "#1E1E1E") ?? .systemBackground
            case .backgroundLightGreen: return UIColor(hex: "#1C352D") ?? .systemBackground
            }
        }
    }
}
// MARK: - HEX 지원 Extension
extension UIColor {
    /// HEX 문자열 (#RRGGBB 또는 #RRGGBBAA)로 UIColor 생성
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        var r, g, b, a: CGFloat
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
