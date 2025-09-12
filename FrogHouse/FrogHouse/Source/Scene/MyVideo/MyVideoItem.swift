//
//  MyVideoItem.swift
//  FrogHouse
//
//  Created by 서정원 on 9/9/25.
//

import Foundation

enum MyVideoItem: Hashable {
    case history(MyVideoViewModel.HistoryItem)
    case like(VideoListViewModel.Item)
}
