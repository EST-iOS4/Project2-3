//
//  PaddingLabel.swift
//  FrogHouse
//
//  Created by JAY on 9/4/25.
//
import UIKit


// MARK: Jay - 길이에 따라 내부 여백이 들어가 둥글게 보이는 라벨 (태그 모양 용)
final class PaddingLabel: UILabel {
  private let insets: UIEdgeInsets
  
  
  init(insets: UIEdgeInsets) {
    self.insets = insets
    super.init(frame: .zero)
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + insets.left + insets.right,
      height: size.height + insets.top + insets.bottom
    )
  }
  
  
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: insets))
  }
  
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let s = super.sizeThatFits(
      CGSize(
        width: size.width - insets.left - insets.right,
        height: size.height - insets.top - insets.bottom
      )
    )
    return CGSize(
      width: s.width + insets.left + insets.right,
      height: s.height + insets.top + insets.bottom
    )
  }
}
