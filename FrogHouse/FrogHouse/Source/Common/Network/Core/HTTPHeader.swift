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
    case applicationJSON
    
    var value: [String: String]? {
        switch self {
        case .none:
            return nil
        case .authorization(token: let token):
            return ["Authorization": "Bearer \(token)"]
        case .applicationJSON:
            return ["Content-Type": "application/json"]
        }
    }
}
