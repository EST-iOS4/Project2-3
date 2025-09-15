//
//  BaseRepository.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation

// MARK: Jay - 공통 리포지토리 베이스 (도메인 모델 제네릭)
protocol BaseRepository {
    associatedtype Model
    // MARK: Jay - 조회수 기준 상위 N개 조회
    func fetchTop(limit: Int) async throws -> [Model]
}
