//
//  PlayerControlsView.swift
//  FrogHouse
//
//  Created by 이건준 on 9/5/25.
//

import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton()
    func playerControlsViewDidTapSeekBackward()
    func playerControlsViewDidTapSeekForward()
    func playerControlsViewDidTapSpeedButton()
    func playerControlsViewDidTapMuteButton()
    func playerControlsView(didSlideSlider value: Float)
}

final class PlayerControlsView: UIView {
    weak var delegate: PlayerControlsViewDelegate?
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let videoProgressView = VideoProgressView()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Buttons
    private let seekBackwardButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "gobackward.10", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        config.baseForegroundColor = UIColor.FH.signatureGreen.color
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        return button
    }()

    private let seekForwardButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "goforward.10", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        config.baseForegroundColor = UIColor.FH.signatureGreen.color
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        return button
    }()

    private let playPauseButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = UIColor.FH.signatureGreen.color
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        return button
    }()

    private let speedButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = UIColor.FH.signatureGreen.color
        config.baseBackgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.FH.quaternary.cgColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .FH.caption(size: 14)
        return button
    }()

    private let muteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = UIColor.FH.signatureGreen.color
        config.baseBackgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.FH.quaternary.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
        setupConstraints()
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        addSubview(containerStackView)
        [speedButton, seekBackwardButton, playPauseButton, seekForwardButton, muteButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        [videoProgressView, buttonStackView].forEach { containerStackView.addArrangedSubview($0) }
    }
    
    private func setupConstraints() {
        containerStackView.pinToSuperview()
        
        playPauseButton.anchor.size(width: 60, height: 60)
        seekForwardButton.anchor.size(width: 50, height: 50)
        seekBackwardButton.anchor.size(width: 50, height: 50)
        speedButton.anchor.size(width: 50, height: 32)
        muteButton.anchor.size(width: 50, height: 32)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    private func setupActions() {
        seekBackwardButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.playerControlsViewDidTapSeekBackward()
        }, for: .touchUpInside)
        
        seekForwardButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.playerControlsViewDidTapSeekForward()
        }, for: .touchUpInside)
        
        playPauseButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.playerControlsViewDidTapPlayPauseButton()
        }, for: .touchUpInside)
        
        speedButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.playerControlsViewDidTapSpeedButton()
        }, for: .touchUpInside)
        
        muteButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.playerControlsViewDidTapMuteButton()
        }, for: .touchUpInside)
        
        videoProgressView.volumeSlider.addAction(UIAction { [weak self] action in
            guard let slider = action.sender as? UISlider else { return }
            self?.delegate?.playerControlsView(didSlideSlider: slider.value)
        }, for: .valueChanged)
    }
}

// MARK: - Public Methods
extension PlayerControlsView {
    func updateStartTime(_ time: String) {
        videoProgressView.startTimeLabel.text = time
    }
    
    func updateEndTime(_ time: String) {
        videoProgressView.endTimeLabel.text = time
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let image = UIImage(
            systemName: isPlaying ? "pause" : "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        )
        playPauseButton.configuration?.image = image
    }
    
    func updateMuteButton(isMuted: Bool) {
        let image = UIImage(
            systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        )
        muteButton.configuration?.image = image
    }
    
    func updateSpeedButton(speed: Float) {
        let title = "\(speed)x"
        speedButton.configuration?.title = title
    }
    
    func updateSlider(value: Float) {
        videoProgressView.volumeSlider.value = value
    }
}
