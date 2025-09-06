//
//  RequestParameter.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

enum RequestParameter {
    case query([String: Any])
    case body([String: Any])
    case none
}
