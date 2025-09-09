//
//  YoutubeRouter.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

enum YoutubeRouter: Router {
    case mostPopular(MostPopularRequest)
    
    var request: RequestParameter {
        return .none
    }
    
    var header: HTTPHeader {
        return .none
    }
    
    var path: String {
        return "/videos"
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var parameter: Encodable? {
        switch self {
        case .mostPopular(let request):
            return request
        }
    }
}
