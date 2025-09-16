//
//  FirestoreVideoListStore.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation
import FirebaseFirestore

// MARK: Jay - VideoList DTO 공유 스토어(인메모리 캐시 + 선택적 실시간 구독)
actor FirestoreVideoListStore {

    // MARK: Jay - 싱글톤
    static let shared = FirestoreVideoListStore()

    // MARK: Jay - 내부 상태
    private var cache: [String: FirestoreVideoListDTO] = [:]
    private var lastFetchAt: Date?
    private var listener: ListenerRegistration?

    // MARK: Jay - 설정
    private let collectionName = "VideoList"
    private let defaultOrderField = "viewCount"
    private let ttl: TimeInterval = 60 // MARK: Jay - 기본 TTL 60초

    // MARK: Jay - 현재 DTO 스냅샷
    func current() -> [FirestoreVideoListDTO] {
        Array(cache.values)
    }

    // MARK: Jay - TTL 고려해서 가져오기
    func getOrFetch(orderBy field: String? = nil, descending: Bool = true) async throws -> [FirestoreVideoListDTO] {
        if let last = lastFetchAt, Date().timeIntervalSince(last) < ttl, !cache.isEmpty {
            return current()
        }
        return try await refreshOnce(orderBy: field, descending: descending)
    }

    // MARK: Jay - 강제 1회 갱신
    func refreshOnce(orderBy field: String? = nil, descending: Bool = true) async throws -> [FirestoreVideoListDTO] {
        let db = Firestore.firestore()
        let orderField = field ?? defaultOrderField

        let snap = try await db.collection(collectionName)
            .order(by: orderField, descending: descending)
            .limit(to: 200) // MARK: Jay - 여유분
            .getDocuments()

        var next: [String: FirestoreVideoListDTO] = [:]
        for doc in snap.documents {
            do {
                let dto = try doc.data(as: FirestoreVideoListDTO.self)
                next[dto.id] = dto
            } catch {
                #if DEBUG
                print("🔥 Jay - decode error for \(doc.documentID):", error)
                #endif
            }
        }
        cache = next
        lastFetchAt = Date()
        return current()
    }

    // MARK: Jay - 실시간 리스닝 시작(선택)
    func startListening(orderBy field: String? = nil, descending: Bool = true) {
        guard listener == nil else { return }
        let db = Firestore.firestore()
        let orderField = field ?? defaultOrderField

        listener = db.collection(collectionName)
            .order(by: orderField, descending: descending)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    print("🔥 Jay - snapshot error:", error)
                    return
                }
                guard let snapshot else { return }

                Task { [weak self] in
                    guard let self else { return }
                    var next = self.cache
                    for change in snapshot.documentChanges {
                        do {
                            let dto = try change.document.data(as: FirestoreVideoListDTO.self)
                            switch change.type {
                            case .added, .modified:
                                next[dto.id] = dto
                            case .removed:
                                next.removeValue(forKey: dto.id)
                            @unknown default:
                                break
                            }
                        } catch {
                            #if DEBUG
                            print("🔥 Jay - live decode error for \(change.document.documentID):", error)
                            #endif
                        }
                    }
                    self.cache = next
                    self.lastFetchAt = Date()
                }
            }
    }

    // MARK: Jay - 리스너 해제
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
// MARK: Jay - id(UUID)로 DTO 조회 (메모리 캐시)
extension FirestoreVideoListStore {
    func dto(for id: UUID) async -> FirestoreVideoListDTO? {
        let k1 = id.uuidString
        let k2 = id.uuidString.uppercased()
        return cache[k1] ?? cache[k2]
    }
}
