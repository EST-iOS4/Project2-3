//
//  Router.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

protocol Router {
    var path: String { get }
    var header: HTTPHeader { get }
    var method: HTTPMethod { get }
    var request: RequestParameter { get }
    var parameter: Encodable? { get }
}

extension Router {
    var baseURL: URL? {
        URL(string: "https://www.googleapis.com/youtube/v3")
    }
}
