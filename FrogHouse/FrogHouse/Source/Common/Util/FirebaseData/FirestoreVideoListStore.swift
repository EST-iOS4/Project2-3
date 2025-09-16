//
//  FirestoreVideoListStore.swift
//  FrogHouse
//

import Foundation
import FirebaseFirestore

// MARK: Jay - Firestore VideoList를 앱에서 공유하는 캐시 스토어
actor FirestoreVideoListStore {
    static let shared = FirestoreVideoListStore()

    private var cache: [FirestoreVideoListDTO] = []
    private var lastFetchAt: Date?
    private var listener: ListenerRegistration?
    
    private let collection = Firestore.firestore().collection("VideoList")
    private let ttl: TimeInterval = 60

    // MARK: Jay - 캐시된 DTO 전부 반환 (정렬 X, 그대로)
    func currentFirestoreData() -> [FirestoreVideoListDTO] {
        cache
    }

    // MARK: Jay - 캐시가 유효하면 그대로, 아니면 Firestore에서 새로 로드
    func getOrFetch(type: VideoListSort) async throws -> [FirestoreVideoListDTO] {
        if let last = lastFetchAt,
           Date().timeIntervalSince(last) < ttl,
           !cache.isEmpty { return cache }
        return try await loadFirestoreData(type: type)
    }

    // MARK: Jay - Firestore에서 강제 갱신
    func loadFirestoreData(type: VideoListSort) async throws -> [FirestoreVideoListDTO] {
        let snap = try await collection
            .limit(to: 200).order(by: type.sortBy, descending: false)
            .getDocuments()

        let next: [FirestoreVideoListDTO] = snap.documents.compactMap {
            try? $0.data(as: FirestoreVideoListDTO.self)
        }
        cache = next
        lastFetchAt = Date()
        return cache
    }

    // MARK: Jay - id(UUID)로 DTO 조회
    func dto(for id: UUID) async -> FirestoreVideoListDTO? {
        cache.first { $0.id == id.uuidString || $0.id == id.uuidString.uppercased() }
    }

    // MARK: Jay - 실시간 변경 감지 시작
    func startListening() {
        guard listener == nil else { return }
        listener = collection
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                Task { await self.applySnapshot(snap) }
            }
    }

    // MARK: Jay - 스냅샷을 반영
    private func applySnapshot(_ snapshot: QuerySnapshot) {
        let next: [FirestoreVideoListDTO] = snapshot.documents.compactMap {
            try? $0.data(as: FirestoreVideoListDTO.self)
        }
        cache = next
        lastFetchAt = Date()
    }

    // MARK: Jay - 실시간 감지 중단
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    enum VideoListSort {
        case createdAtDesc
        case viewCountDesc
        case lastWatchedAtDesc
        
        var sortBy: String {
            switch self {
            case .createdAtDesc:
                return "createdAt"
            case .viewCountDesc:
                return "viewCount"
            case .lastWatchedAtDesc:
                return "lastWatchedAt"
            }
        }
    }
}
