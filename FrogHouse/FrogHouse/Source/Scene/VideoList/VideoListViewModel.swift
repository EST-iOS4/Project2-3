//
//  VideoListViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

final class VideoListViewModel {

    struct Item {
        let id = UUID()
        let title: String
        let description: String
        var isLiked: Bool
    }

    private var allItems: [Item] = (1...40).map { i in
        Item(title: "제목 \(i)",
             description: "안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.",
             isLiked: false)
    }

    private(set) var visibleItems: [Item] = []

    private let pageSize = 10
    private var isLoading = false

    func loadInitial() {
        visibleItems = Array(allItems.prefix(pageSize))
    }

    func loadMoreIfNeeded() -> Bool {
        guard !isLoading else { return false }
        let nextIndex = visibleItems.count
        guard nextIndex < allItems.count else { return false }

        isLoading = true
        let newIndex = min(nextIndex + pageSize, allItems.count)
        visibleItems.append(contentsOf: allItems[nextIndex..<newIndex])
        isLoading = false
        return true
    }

    func numberOfRows() -> Int { visibleItems.count }

    func item(at index: Int) -> Item { visibleItems[index] }

    func toggleLike(at index: Int) {
        guard index >= 0 && index < visibleItems.count else { return }
        visibleItems[index].isLiked.toggle()

        let id = visibleItems[index].id
        if let allIdx = allItems.firstIndex(where: { $0.id == id }) {
            allItems[allIdx].isLiked = visibleItems[index].isLiked
        }
    }
}
