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
    @Published private(set) var isPlaying: Bool = true
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var currentSpeed: Float = 1.0
    @Published private(set) var startTime: String = "0:00"
    @Published private(set) var endTime: String = "0:00"
    @Published private(set) var currentTimeRatio: Float = 0
    @Published private(set) var video: Video?
    
    private let playManager: AVPlayManager
    private var cancellables = Set<AnyCancellable>()
    
    init(video: Video, playManager: AVPlayManager = .shared) {
        self.playManager = playManager
        self.video = video
        
        bindManager()
        observeCurrentTime()
        observeDuration()
        
        playManager.loadVideo(url: video.mp4URL)
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
