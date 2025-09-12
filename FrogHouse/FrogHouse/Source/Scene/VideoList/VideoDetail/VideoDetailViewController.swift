//
//  VideoDetailViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/5/25.
//

import AVKit
import UIKit
import Combine

final class VideoDetailViewController: BaseViewController<VideoDetailViewModel> {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var playerControlsView: PlayerControlsView = {
        let controlView = PlayerControlsView()
        controlView.delegate = self
        return controlView
    }()
    
    private var playerLayer: AVPlayerLayer?
    
    // MARK: - Life Cycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel.resetPlayer()
        }
    }
    
    // MARK: - Setup
    override func setupLayouts() {
        super.setupLayouts()
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        [playerContainerView, playerControlsView].forEach { containerStackView.addArrangedSubview($0) }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        scrollView.anchor
            .bottom(view.bottomAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .top(view.topAnchor)
        
        containerStackView.anchor
            .bottom(scrollView.bottomAnchor)
            .leading(scrollView.leadingAnchor)
            .trailing(scrollView.trailingAnchor)
            .top(scrollView.topAnchor)
            .width(scrollView.widthAnchor)
        
        playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 9.0/16.0).isActive = true
    }
    
    override func setupUI() {
        super.setupUI()
        setPlayerLayer()
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        
        viewModel.$endTime
            .receive(on: RunLoop.main)
            .sink { [weak self] endTime in
                self?.playerControlsView.configureUI(startTime: "0:00", endTime: endTime)
            }
            .store(in: &cancellables)
        
        viewModel.$isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] isPlaying in
                self?.playerControlsView.updatePlayPauseButton(isPlaying: isPlaying)
            }
            .store(in: &cancellables)
        
        viewModel.$isMuted
            .receive(on: RunLoop.main)
            .sink { [weak self] isMuted in
                self?.playerControlsView.updateMuteButton(isMuted: isMuted)
            }
            .store(in: &cancellables)
        
        viewModel.$currentSpeed
            .receive(on: RunLoop.main)
            .sink { [weak self] speed in
                self?.playerControlsView.updateSpeedButton(speed: speed)
            }
            .store(in: &cancellables)
        
        viewModel.$currentTimeRatio
            .receive(on: RunLoop.main)
            .sink { [weak self] ratio in
                self?.playerControlsView.updateSlider(value: ratio)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private
    private func setPlayerLayer() {
        let player = viewModel.getPlayer()
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.frame = playerContainerView.bounds
        
        playerContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        playerContainerView.layer.addSublayer(layer)
        playerLayer = layer
    }
}

// MARK: - PlayerControlsViewDelegate
extension VideoDetailViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton() {
        viewModel.toggleIsPlaying()
    }
    
    func playerControlsViewDidTapSeekBackward() {
        viewModel.seekBackward()
    }
    
    func playerControlsViewDidTapSeekForward() {
        viewModel.seekForward()
    }
    
    func playerControlsViewDidTapSpeedButton() {
        viewModel.updateSpeed()
    }
    
    func playerControlsViewDidTapMuteButton() {
        viewModel.toggleIsMuted()
    }
    
    func playerControlsView(didSlideSlider value: Float) {
        viewModel.seek(to: value)
    }
}

