//
//  FHSnackBar.swift
//  FrogHouse
//
//  Created by 이건준 on 9/12/25.
//

import UIKit

/// 지정된 Snackbar 유형
enum FHSnackBarType {
    case fetchVideo(Bool)
    case updateLikedState(Bool)
    case updateUnLikedState(Bool)
    
    var icon: UIImage? {
        return UIImage(systemName: "checkmark")?.withTintColor(.FH.signatureGreen.color, renderingMode: .alwaysOriginal)
    }
    
    var message: String {
        switch self {
        case .fetchVideo(let isSuccess):
            return isSuccess ? "비디오조회에 성공하였습니다" : "비디오조회에 실패하였습니다"
        case .updateLikedState(let isSuccess):
            return isSuccess ? "좋아요에 성공하였습니다" : "좋아요에 실패하였습니다"
        case .updateUnLikedState(let isSuccess):
            return isSuccess ? "좋아요 취소에 성공하였습니다" : "좋아요 취소에 실패하였습니다"
        }
    }
    
    var duration: SnackBar.Duration {
        return .short
    }
}

/// FrogHouse 앱 전용 SnackBar
final class FHSnackBar: SnackBar {
    init(contextView: UIView, type: FHSnackBarType) {
        let snackBarStyle = SnackBarStyle(
            icon: type.icon,
            message: type.message
        )
        
        let duration = type.duration
        
        super.init(contextView: contextView, style: snackBarStyle, duration: duration)
    }
    
    required init(contextView: UIView, style: SnackBarStyle, duration: Duration) {
        fatalError("init(contextView:style:duration:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


