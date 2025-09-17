//
//  NetworkError.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case responseError
    case decodeError
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case dataError
}
