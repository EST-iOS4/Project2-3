//
//  FirestoreDomainMappable.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation

// MARK: Jay - DTO가 도메인 모델로 매핑하기 위한 프로토콜 (제네릭 베이스용)
protocol FirestoreDomainMappable {
    associatedtype DomainModel
    // MARK: Jay - DTO → Domain 변환
    func toDomain() -> DomainModel?
}
