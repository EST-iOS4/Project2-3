//
//  AVPlayManager.swift
//  FrogHouse
//
//  Created by 이건준 on 9/5/25.
//

import AVFoundation
import Combine

final class AVPlayManager {
    static let shared = AVPlayManager()
    
    private let player = AVPlayer()
    private var cancellables = Set<AnyCancellable>()
    private let speeds: [Float] = [1.0, 1.5, 2.0]
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var currentSpeed: Float = 1.0
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0
    
    let didFinishPlaying = PassthroughSubject<Void, Never>()
    private var timeObserver: Any?
    
    private init() {
        observeCurrentItemDuration()
        observeCurrentTime()
        observePlaybackEnd()
    }
    
    func getPlayer() -> AVPlayer { player }
    
    func loadVideo(url: URL?) {
        guard let url else { return }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
    }
    
    // MARK: - Controls
    func play() {
        player.play()
        player.rate = currentSpeed
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            if let currentItem = player.currentItem,
               CMTimeCompare(player.currentTime(), currentItem.duration) >= 0 {
                player.seek(to: .zero)
            }
            play()
        }
    }
    
    func toggleMute() {
        player.isMuted.toggle()
        isMuted = player.isMuted
    }
    
    func updateSpeed() {
        if let index = speeds.firstIndex(of: currentSpeed) {
            let nextIndex = (index + 1) % speeds.count
            currentSpeed = speeds[nextIndex]
        } else {
            currentSpeed = 1.0
        }
        if isPlaying {
            player.rate = currentSpeed
        }
    }
    
    func seek(to value: Float) {
        guard let currentItem = player.currentItem else { return }
        let targetTime = CMTime(
            seconds: Double(value) * CMTimeGetSeconds(currentItem.duration),
            preferredTimescale: currentItem.currentTime().timescale
        )
        player.seek(to: targetTime)
    }
    
    func seekBackward(seconds: Double = 10) {
        guard let currentItem = player.currentItem else { return }
        let currentSec = CMTimeGetSeconds(player.currentTime())
        let newTime = max(currentSec - seconds, 0)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: currentItem.currentTime().timescale))
    }
    
    func seekForward(seconds: Double = 10) {
        guard let currentItem = player.currentItem else { return }
        let currentSec = CMTimeGetSeconds(player.currentTime())
        let dur = CMTimeGetSeconds(currentItem.duration)
        let newTime = min(currentSec + seconds, dur)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: currentItem.currentTime().timescale))
    }
    
    // MARK: - Observers
    private func observeCurrentItemDuration() {
        player.publisher(for: \.currentItem)
            .compactMap { $0 }
            .flatMap { $0.publisher(for: \.duration) }
            .map { CMTimeGetSeconds($0) }
            .sink { [weak self] seconds in
                guard let self else { return }
                if seconds.isFinite {
                    self.duration = seconds
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeCurrentTime() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            let seconds = CMTimeGetSeconds(time)
            if seconds.isFinite {
                self.currentTime = seconds
            }
        }
    }
    
    private func observePlaybackEnd() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pause()
            self?.didFinishPlaying.send()
        }
    }
}
