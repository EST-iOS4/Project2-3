//
//  VideoProgressView.swift
//  FrogHouse
//
//  Created by 이건준 on 9/5/25.
//

import UIKit

final class VideoProgressView: UIView {
    let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.0
        slider.minimumTrackTintColor = UIColor.FH.signatureGreen.color
        return slider
    }()
    
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .FH.body(size: 12)
        label.textColor = UIColor.FH.primary.color
        return label
    }()
    
    let endTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .FH.body(size: 12)
        label.textColor = UIColor.FH.primary.color
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        [startTimeLabel, endTimeLabel, volumeSlider].forEach { addSubview($0) }
        volumeSlider.anchor
            .leading(leadingAnchor)
            .trailing(trailingAnchor)
            .top(topAnchor)
        
        startTimeLabel.anchor
            .top(volumeSlider.bottomAnchor)
            .leading(volumeSlider.leadingAnchor)
            .bottom(bottomAnchor)
        
        endTimeLabel.anchor
            .top(volumeSlider.bottomAnchor)
            .trailing(volumeSlider.trailingAnchor)
            .bottom(bottomAnchor)
    }
}
