//
//  HTTPHeader.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

enum HTTPHeader {
    case none
    case authorization(token: String)
    
    var value: [String: String] {
        switch self {
        case .none:
            return ["Content-Type": "application/json"]
        case .authorization(let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        }
    }
}
