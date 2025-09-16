//
//  FirestoreVideoListStore.swift
//  FrogHouse
//

import Foundation
import FirebaseFirestore

// MARK: Jay - Firestore VideoList를 앱에서 공유하는 캐시 스토어
actor FirestoreVideoListStore {
    static let shared = FirestoreVideoListStore()

    private var cache: [String: FirestoreVideoListDTO] = [:]
    private var lastFetchAt: Date?
    private var listener: ListenerRegistration?
    
    private let collection = Firestore.firestore().collection("VideoList")
    private let ttl: TimeInterval = 60

    // MARK: Jay - 캐시된 DTO 전부 반환
    func currentFirestoreData() -> [FirestoreVideoListDTO] { Array(cache.values) }

    // MARK: Jay - 캐시가 유효하면 그대로, 아니면 Firestore에서 새로 로드
    func getOrFetch() async throws -> [FirestoreVideoListDTO] {
        if let last = lastFetchAt,
           Date().timeIntervalSince(last) < ttl,
           !cache.isEmpty { return currentFirestoreData() }
        return try await loadFirestoreData()
    }

    // MARK: Jay - Firestore에서 강제 갱신
    func loadFirestoreData() async throws -> [FirestoreVideoListDTO] {
        let snap = try await collection
            .order(by: "viewCount", descending: true)
        // MARK: Jay - 현재는 한번에 200개만 불러옴 추후 필요시 tartAfterDocument 같은 페이징 처리
            .limit(to: 200)
            .getDocuments()

        var next: [String: FirestoreVideoListDTO] = [:]
        for doc in snap.documents {
            if let dto = try? doc.data(as: FirestoreVideoListDTO.self) {
                next[dto.id] = dto
            }
        }
        cache = next
        lastFetchAt = Date()
        return currentFirestoreData()
    }

    // MARK: Jay - id(UUID)로 DTO 조회
    func dto(for id: UUID) async -> FirestoreVideoListDTO? {
        cache[id.uuidString] ?? cache[id.uuidString.uppercased()]
    }

    // MARK: Jay - 실시간 변경 감지 시작
    func startListening() {
        // MARK: Jay - 중복 리스너 방지
        guard listener == nil else { return }
        
        listener = collection
            .order(by: "viewCount", descending: true)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                // MARK: Jay - actor 격리로 복귀해서 상태 수정
                Task { await self.applySnapshot(snap) }
            }
    }

    // MARK: Jay - 스냅샷을 반영
    private func applySnapshot(_ snapshot: QuerySnapshot) {
        var next = cache
        for change in snapshot.documentChanges {
            if let dto = try? change.document.data(as: FirestoreVideoListDTO.self) {
                switch change.type {
                case .added, .modified:
                    next[dto.id] = dto
                case .removed:
                    next.removeValue(forKey: dto.id)
                @unknown default:
                    break
                }
            }
        }
        cache = next
        lastFetchAt = Date()
    }

    // MARK: Jay - 실시간 감지 중단
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
