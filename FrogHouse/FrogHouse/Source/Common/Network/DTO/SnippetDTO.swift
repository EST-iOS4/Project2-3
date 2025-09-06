//
//  SnippetDTO.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

struct SnippetDTO: Decodable {
    let title: String
    let description: String
    let thumbnails: ThumbnailsDTO
    let tags: [String]
}
