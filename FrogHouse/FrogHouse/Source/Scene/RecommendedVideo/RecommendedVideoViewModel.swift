//
//  RecommendedVideoViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

final class RecommendedVideoViewModel {
  
  
  // 데이터
  private(set) var items: [CarouselItem]
  
  // MARK: Jay - 무한 캐러셀
  private let multiplier: Int
  var totalVirtualCount: Int { items.count * multiplier }
  var initialIndex: Int {
    let total = totalVirtualCount
    return total / 2 - (total / 2) % items.count
  }
  
  // MARK: Jay - 자동 슬라이드
  private var timer: Timer?
  var interval: TimeInterval = 4.0
  
  init(items: [CarouselItem], multiplier: Int = 1000) {
    self.items = items
    self.multiplier = multiplier
  }
  
  func item(at virtualIndex: Int) -> CarouselItem {
    items[virtualIndex % items.count]
  }
  
  func realIndex(from virtualIndex: Int) -> Int {
    virtualIndex % items.count
  }
  
  func shouldRecenter(_ currentIndex: Int) -> Bool {
    let threshold = items.count * 10
    let maxIndex = totalVirtualCount
    return currentIndex < threshold || currentIndex > maxIndex - threshold
  }
  
  func recenteredIndex(from currentIndex: Int) -> Int {
    initialIndex + (currentIndex % items.count)
  }
  
  // MARK: Jay - 자동 슬라이드 제어
  func startAutoSlide(currentIndex: @escaping () -> Int?, onTick: @escaping (_ nextIndex: Int) -> Void) {
    guard timer == nil else { return }
    let interval = self.interval
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      let idx = currentIndex() ?? self.initialIndex
      onTick(idx + 1)
    }
  }
  
  func stopAutoSlide() {
    timer?.invalidate()
    timer = nil
  }
}
