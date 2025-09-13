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
        stackView.spacing = 15
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: .zero, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var playerControlsView: PlayerControlsView = {
        let controlView = PlayerControlsView()
        controlView.delegate = self
        return controlView
    }()
    
    private var playerLayer: AVPlayerLayer?
    
    private let videoTagsView = VideoTagListView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .FH.amount(size: 22)
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .FH.body(size: 16)
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let statisticsLabel: UILabel = {
        let label = UILabel()
        label.font = .FH.body(size: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    
    private lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTappedVideoScreen))
        gesture.numberOfTapsRequired = 1
        gesture.isEnabled = true
        gesture.cancelsTouchesInView = false
        gesture.require(toFail: doubleTapLeftGesture)
        gesture.require(toFail: doubleTapRightGesture)
        return gesture
    }()
    
    private lazy var doubleTapLeftGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapLeft))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        gesture.isEnabled = true
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private lazy var doubleTapRightGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapRight))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        gesture.isEnabled = true
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
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
        [playerContainerView, playerControlsView, titleLabel, descriptionLabel, videoTagsView, statisticsLabel].forEach { containerStackView.addArrangedSubview($0) }
        playerContainerView.addSubview(feedbackLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        scrollView.pinToSuperview()
        
        containerStackView.pinToSuperview().anchor
            .width(scrollView.widthAnchor)
        
        playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 9.0/16.0).isActive = true
        containerStackView.setCustomSpacing(.zero, after: playerContainerView)
        feedbackLabel.anchor
            .centerX(playerContainerView.centerXAnchor)
            .centerY(playerContainerView.centerYAnchor)
    }
    
    override func setupUI() {
        super.setupUI()
        setPlayerLayer()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Binding
    override func bind() {
        super.bind()
        
        viewModel.$startTime
            .receive(on: RunLoop.main)
            .sink { [weak self] startTime in
                self?.playerControlsView.updateStartTime(startTime)
            }
            .store(in: &cancellables)
        
        viewModel.$endTime
            .receive(on: RunLoop.main)
            .sink { [weak self] endTime in
                self?.playerControlsView.updateEndTime(endTime)
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
        
        viewModel.$video
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                self?.titleLabel.text = item.title
                self?.descriptionLabel.text = item.descriptionText
                self?.videoTagsView.setTags(item.videoCategories.map { $0.title })
                
                let likeText = item.isLiked ? "❤️" : "♡"
                let createdDate = item.createdAt.formatted(.dateTime.month().day())
                let viewText = "조회수: \(item.statistics.viewCount)"
                self?.statisticsLabel.text = "\(likeText) • \(viewText) • 생성일: \(createdDate)"
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
        [singleTapGesture, doubleTapLeftGesture, doubleTapRightGesture].forEach { playerContainerView.addGestureRecognizer($0) }
        playerLayer = layer
    }
    
    private func showFeedback(_ text: String) {
        feedbackLabel.text = text
        feedbackLabel.alpha = 0
        feedbackLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.feedbackLabel.alpha = 1
            self.feedbackLabel.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                self.feedbackLabel.alpha = 0
                self.feedbackLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)
        }
    }
    
    @objc
    private func didTappedVideoScreen() {
        viewModel.toggleIsPlaying()
        showFeedback(viewModel.isPlaying ? "▶️ 재생" : "⏸ 정지")
    }
    
    @objc
    private func didDoubleTapLeft() {
        viewModel.seekBackward()
        showFeedback("⏪ 10")
    }
    
    @objc
    private func didDoubleTapRight() {
        viewModel.seekForward()
        showFeedback("10 ⏩")
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

extension VideoDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: playerContainerView)
        let width = playerContainerView.bounds.width
        
        if gestureRecognizer == doubleTapLeftGesture {
            return location.x < width * 0.5
        } else if gestureRecognizer == doubleTapRightGesture {
            return location.x >= width * 0.5
        }
        return true
    }
}
