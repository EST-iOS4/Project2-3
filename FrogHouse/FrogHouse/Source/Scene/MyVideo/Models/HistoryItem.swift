//
//  HistoryItem.swift
//  FrogHouse
//
//  Created by 서정원 on 9/9/25.
//

import Foundation

struct HistoryItem: Hashable {
    let id = UUID()
    let title: String
    let thumbnailURL: String
}
