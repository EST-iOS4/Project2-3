//
//  NetworkClient.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let builder: RequestBuilder
    
    init(session: URLSession = .shared,
         builder: RequestBuilder = RequestBuilder()) {
        self.session = session
        self.builder = builder
    }
    
    func request<T>(router: Router,
                    decodeTo type: T.Type,
                    completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        do {
            let request = try builder.buildRequest(from: router)
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.responseError))
                    return
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.dataError))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(NetworkError.decodeError))
                    print(error)
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
