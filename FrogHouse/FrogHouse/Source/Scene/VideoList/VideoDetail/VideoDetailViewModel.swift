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
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var currentSpeed: Float = 1.0
    @Published private(set) var endTime: String = "0:00"
    @Published private(set) var currentTimeRatio: Float = 0
    
    private let playManager: AVPlayManager
    private var cancellables = Set<AnyCancellable>()
    
    init(videoURL: URL?, playManager: AVPlayManager = .shared) {
        self.playManager = playManager
        
        bindManager()
        observeCurrentTime()
        observeDuration()
        
        playManager.loadVideo(url: videoURL)
    }
    
    func getPlayer() -> AVPlayer { playManager.getPlayer() }
    func toggleIsPlaying() { playManager.togglePlayPause() }
    func toggleIsMuted() { playManager.toggleMute() }
    func updateSpeed() { playManager.updateSpeed() }
    func seekBackward() { playManager.seekBackward() }
    func seekForward() { playManager.seekForward() }
    func seek(to value: Float) { playManager.seek(to: value) }
    
    private func bindManager() {
        playManager.$isPlaying
            .receive(on: RunLoop.main)
            .assign(to: &$isPlaying)
        
        playManager.$isMuted
            .receive(on: RunLoop.main)
            .assign(to: &$isMuted)
        
        playManager.$currentSpeed
            .receive(on: RunLoop.main)
            .assign(to: &$currentSpeed)
    }
    
    private func observeCurrentTime() {
        playManager.$currentTime
            .map { [weak self] currentTime -> Float in
                guard let duration = self?.playManager.duration, duration > 0 else { return 0 }
                return Float(currentTime / duration)
            }
            .assign(to: &$currentTimeRatio)
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
