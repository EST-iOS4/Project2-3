//
//  FirestoreVideoListStore.swift
//  FrogHouse
//
//  Created by JAY on 9/15/25.
//

import Foundation
import FirebaseFirestore

actor FirestoreVideoListStore {
    static let shared = FirestoreVideoListStore()
    private var cache: [FirestoreVideoListDTO] = []
    private var lastFetchAt: Date?
    private var listener: ListenerRegistration?
    private let collection = Firestore.firestore().collection("VideoList")
    private let ttl: TimeInterval = 60

    func currentFirestoreData() -> [FirestoreVideoListDTO] {
        cache
    }

    func getOrFetch(type: VideoListSort) async throws -> [FirestoreVideoListDTO] {
        if let last = lastFetchAt,
           Date().timeIntervalSince(last) < ttl,
           !cache.isEmpty { return cache }
        return try await loadFirestoreData(type: type)
    }

    func loadFirestoreData(type: VideoListSort) async throws -> [FirestoreVideoListDTO] {
        let snap = try await collection
            .limit(to: 200).order(by: type.sortBy, descending: true)
            .getDocuments()

        let next: [FirestoreVideoListDTO] = snap.documents.compactMap {
            try? $0.data(as: FirestoreVideoListDTO.self)
        }
        cache = next
        lastFetchAt = Date()
        return cache
    }

    func dto(for id: UUID) async -> FirestoreVideoListDTO? {
        cache.first { $0.id == id.uuidString || $0.id == id.uuidString.uppercased() }
    }

    func getDto(for id: UUID) async throws -> FirestoreVideoListDTO? {
            let docRef = collection.document(id.uuidString)
            let snapshot = try await docRef.getDocument()
            return try snapshot.data(as: FirestoreVideoListDTO.self)
        }
    
    func startListening() {
        guard listener == nil else { return }
        listener = collection
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                Task { await self.applySnapshot(snap) }
            }
    }

    private func applySnapshot(_ snapshot: QuerySnapshot) {
        let next: [FirestoreVideoListDTO] = snapshot.documents.compactMap {
            try? $0.data(as: FirestoreVideoListDTO.self)
        }
        cache = next
        lastFetchAt = Date()
    }

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
