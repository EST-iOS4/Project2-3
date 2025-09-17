//
//  VideoItemDTO.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

struct VideoItemDTO: Decodable {
    let id: String
    let snippet: SnippetDTO
}
