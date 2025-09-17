//
//  YoutubeService.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

final class YoutubeService {
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    func fetchMostPopularVideos(request: MostPopularRequest, completion:  @escaping (Result<MostPopularResponseDTO, Error>) -> Void) {
        client.request(router: YoutubeRouter.mostPopular(request), decodeTo: MostPopularResponseDTO.self, completion: completion)
    }
}
