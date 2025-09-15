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
    
    func fetchVideo() throws {
        isLoading = true
        let request = Video.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let videoList = try PersistenceManager.shared.fetch(request: request)
        guard let selectedVideo = videoList.first else { return }
        playManager.loadVideo(url: selectedVideo.mp4URL)
        
        // MARK: - indicator 테스트용 딜레이 0.5초
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.video = .init(title: selectedVideo.title, descriptionText: selectedVideo.descriptionText, thumbnailURL: selectedVideo.thumbnailURL, viewCount: Int(selectedVideo.statistics.viewCount), categories: selectedVideo.videoCategories, createdAt: selectedVideo.createdAt, isLiked: selectedVideo.isLiked)
            self.isLoading = false
        }
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
