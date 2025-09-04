//
//  CarouselDataSource.swift
//  FrogHouse
//
//  Created by JAY on 9/4/25.
//


import Foundation


enum CarouselDataSource {
  static func makeItems() -> [CarouselItem] {
    return [
      CarouselItem(
        imageName: "1",
        title: "푸른 바다",
        detail: "이야 물놀이~!! 여름을 즐겨봐요",
        tags: ["추천", "여행", "힐링"]
      ),
      CarouselItem(
        imageName: "2",
        title: "도시 야경",
        detail: "반짝이는 야경과 함께하는 씨티팝.",
        tags: ["야경", "포토스팟"]
      ),
      CarouselItem(
        imageName: "3",
        title: "힐링 숲길",
        detail: "초록빛 숲길을 따라 천천히 산책하며 힐링해요.",
        tags: ["자연", "산책", "휴식"]
      ),
      CarouselItem(
        imageName: "4",
        title: "따뜻한 카페",
        detail: "커피냄새와 함께 보내는 오후, 카페에서 공부하면서 갓생살기.",
        tags: ["카페", "디저트", "공부"]
      ),
      CarouselItem(
        imageName: "5",
        title: "퇴근 후 드라이브",
        detail: "오늘 하루도 무사히 보냈다! 퇴근 후 즐기는 드라이브.",
        tags: ["풍경", "드라이브"]
      ),
      CarouselItem(
        imageName: "6",
        title: "부장님과 주말 등산",
        detail: "왜 등산을 주말에... 는 너무 좋습니다! 와! 자연최고!! 부장님 짱!!",
        tags: ["등산", "아웃도어", "직장", "태그1", "태그2", "태그3", "태그4", "태그5", "태그6"]
      )
    ]
  }
}
