//
//  RequestBuilder.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

struct RequestBuilder {
    func buildRequest(from router: Router) throws -> URLRequest {
        //1. baseURL + path
        guard let url = router.baseURL?.appendingPathComponent(router.path) else { throw NetworkError.urlError }
        
        //2. queryItems 세팅
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        //(parameter -> 쿼리스트링)
        if let encodableParam = router.parameter, let queryItems = encodableParam.toQueryItems() {
            components?.queryItems = queryItems
        }
        
        //최종 URL 생성
        guard let finalURL = components?.url else {
            throw NetworkError.urlError
        }
        
        //URLRequest 생성 및 설정
        var request = URLRequest(url: finalURL)
        request.httpMethod = router.method.rawValue
        
        return request
    }
}
