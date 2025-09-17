//
//  VideoDetailViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/5/25.
//

import AVFoundation
import Combine
import Foundation

final class VideoDetailViewModel: ObservableObject {
    struct VideoDetailItem {
        let title: String
        let descriptionText: String
        let thumbnailURL: URL?
        let viewCount: Int
        let categories: [VideoCategory]
        let createdAt: Date
        var isLiked: Bool
    }
    
    private let id: UUID
    private let playManager: AVPlayManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var isPlaying: Bool = true
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var currentSpeed: Float = 1.0
    @Published private(set) var startTime: String = "0:00"
    @Published private(set) var endTime: String = "0:00"
    @Published private(set) var currentTimeRatio: Float = 0
    @Published private(set) var video: VideoDetailItem?
    
    init(id: UUID, playManager: AVPlayManager = .shared) {
        self.playManager = playManager
        self.id = id
        
        bindManager()
        observeCurrentTime()
        observeDuration()
    }
    
    func getPlayer() -> AVPlayer { playManager.getPlayer() }
    func toggleIsPlaying() { playManager.togglePlayPause() }
    func toggleIsMuted() { playManager.toggleMute() }
    func updateSpeed() { playManager.updateSpeed() }
    func seekBackward() { playManager.seekBackward() }
    func seekForward() { playManager.seekForward() }
    func seek(to value: Float) { playManager.seek(to: value) }
    func resetPlayer() { playManager.reset() }
    func play() { playManager.play() }
    
    // MARK: Jay - Firestore 캐시에서 DTO 조회 → DetailItem 매핑 → 플레이어 로드
    func fetchVideo() async throws {
        Task {
            isLoading = true
            defer { isLoading = false }
            if let dto = try await FirestoreVideoListStore.shared.getDto(for: id),
               let detail = FirestoreVideoListMapper.toVideoDetailItem(dto) {
                try await FirestoreCRUDHelper.updateLastWatchedAt(id: id)
                if let mp4 = URL(string: dto.mp4URL) {
                    self.playManager.loadVideo(url: mp4)
                }
                self.video = detail
            }
        }
    }
    
    func toggleLike(isLiked: Bool) async throws {
        try await FirestoreCRUDHelper.updateIsLiked(id: id, isLiked: isLiked)
    }
    
    private func bindManager() {
        playManager.$isPlaying
            .assign(to: &$isPlaying)
        
        playManager.$isMuted
            .assign(to: &$isMuted)
        
        playManager.$currentSpeed
            .assign(to: &$currentSpeed)
    }
    
    private func observeCurrentTime() {
        let currentTimePublisher = playManager.$currentTime.share()
        
        currentTimePublisher
            .map { [weak self] currentTime -> Float in
                guard let duration = self?.playManager.duration, duration > 0 else { return 0 }
                return Float(currentTime / duration)
            }
            .assign(to: &$currentTimeRatio)
        
        currentTimePublisher
            .map { currentTime -> String in
                guard currentTime.isFinite else { return "0:00" }
                return currentTime.formattedTime
            }
            .assign(to: &$startTime)
    }
    
    private func observeDuration() {
        playManager.$duration
            .map { seconds -> String in
                guard seconds.isFinite else { return "0:00" }
                return seconds.formattedTime
            }
            .assign(to: &$endTime)
    }
}
