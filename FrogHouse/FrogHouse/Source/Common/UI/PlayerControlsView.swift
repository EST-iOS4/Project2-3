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
        let button = UIButton()
        let image = UIImage(systemName: "gobackward.10", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular))
        // FIXME: - 이건준 FH Color색상으로 변경
        button.tintColor = .label
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let seekForwardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "goforward.10", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular))
        // FIXME: - 이건준 FH Color색상으로 변경
        button.tintColor = .label
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        // FIXME: - 이건준 FH Color색상으로 변경
        button.tintColor = .label
        return button
    }()
    
    private let speedButton: UIButton = {
        let button = UIButton()
        // FIXME: - 이건준 FH Color색상으로 변경
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .FH.caption(size: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let muteButton: UIButton = {
        let button = UIButton()
        // FIXME: - 이건준 FH Color색상으로 변경
        button.tintColor = .label
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
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
        speedButton.anchor.size(width: 32, height: 25)
        muteButton.anchor.size(width: 32, height: 25)
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
    func configureUI(
        startTime: String,
        endTime: String
    ) {
        videoProgressView.startTimeLabel.text = startTime
        videoProgressView.endTimeLabel.text = endTime
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let image = UIImage(
            systemName: isPlaying ? "pause" : "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
        )
        playPauseButton.setImage(image, for: .normal)
    }
    
    func updateMuteButton(isMuted: Bool) {
        let image = UIImage(
            systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        )
        muteButton.setImage(image, for: .normal)
    }
    
    func updateSpeedButton(speed: Float) {
        let title = "\(speed)x"
        speedButton.setTitle(title, for: .normal)
    }
    
    func updateSlider(value: Float) {
        videoProgressView.volumeSlider.value = value
    }
}
