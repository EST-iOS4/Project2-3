//
//  NetworkClientProtocol.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(router: Router,
                               decodeTo type: T.Type,
                               completion: @escaping (Result<T,Error>) -> Void)
}
