//
//  FirestoreBaseRepository.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation
import FirebaseFirestore

// MARK: Jay - 공통 Firestore 리포지토리 (DTO 제네릭)
final class FirestoreBaseRepository<DTO: Decodable & FirestoreDomainMappable> {

    // MARK: Jay - 컬렉션/정렬 필드
    private let collectionName: String
    private let orderField: String
    private let descending: Bool

    // MARK: Jay - 초기화
    init(collectionName: String, orderField: String, descending: Bool = true) {
        self.collectionName = collectionName
        self.orderField = orderField
        self.descending = descending
    }

    // MARK: Jay - 상위 N개 조회
    func fetchTop(limit: Int) async throws -> [DTO.DomainModel] {
        // MARK: Jay - Firestore 인스턴스
        let db = Firestore.firestore()

        // MARK: Jay - 여유 100개 로드 후 상위 limit만 사용
        let snap = try await db.collection(collectionName)
            .order(by: orderField, descending: descending)
            .limit(to: max(limit, 100))
            .getDocuments()

        // MARK: Jay - 디코딩/매핑
        var results: [DTO.DomainModel] = []
        results.reserveCapacity(limit)

        for doc in snap.documents {
            do {
                let dto = try doc.data(as: DTO.self)
                if let model = dto.toDomain() { results.append(model) }
                if results.count >= limit { break }
            } catch {
                print("🔥 Jay - decode error for \(doc.documentID):", error)
            }
        }
        return results
    }
}
