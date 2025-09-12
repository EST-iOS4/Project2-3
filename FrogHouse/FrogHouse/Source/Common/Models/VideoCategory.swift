//
//  VideoCategory.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

enum VideoCategory: String, Encodable, CaseIterable {
    case all
    case animation
    case comedy
    case action
    case sf
    case drama
    case fantasy
    case demo
    case thriller
    case daily
    case car
    case experiment
    case adventure   
    case unknown

    var title: String {
        switch self {
        case .all: return "전체"
        case .animation: return "애니메이션"
        case .comedy: return "코미디"
        case .action: return "액션"
        case .sf: return "SF"
        case .drama: return "드라마"
        case .fantasy: return "판타지"
        case .demo: return "데모"
        case .thriller: return "스릴러"
        case .daily: return "일상"
        case .car: return "자동차"
        case .experiment: return "실험"
        case .adventure: return "모험"
        case .unknown: return "알 수 없음"
        }
    }
}
