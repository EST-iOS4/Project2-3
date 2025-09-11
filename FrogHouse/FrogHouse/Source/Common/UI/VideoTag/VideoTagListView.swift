//
//  VideoTagListView.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

// MARK: Jay - 여러 태그셀을 2줄로 쌓아주는 컬렉션뷰 >> 2줄 넘어가면 안보이게 처리 예정
final class VideoTagListView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var tags: [String] = []
    
    private let interitemSpacing: CGFloat = 6
    private let lineSpacing: CGFloat = 6
    
    // MARK: Jay - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.contentInset = .zero
        cv.register(VideoTagCell.self, forCellWithReuseIdentifier: VideoTagCell.reuseID)
        return cv
    }()
    
    // MARK: Jay - 높이 제약 조건(처음에는 0, 이후 updateHeight에서 갱신)
    private var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pinToSuperview()
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.priority = .required
        heightConstraint?.isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Jay - 높이 제약 조건에 맞게 높이 갱신
    private func updateHeight() {
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let singleLineHeight = VideoTagCell.singleLineHeightForCurrentStyle()
        let minTwoLineHeight = (singleLineHeight * 2) + lineSpacing
        let target = max(ceil(contentHeight), ceil(minTwoLineHeight))
        heightConstraint?.constant = target
        layoutIfNeeded()
    }
    
    // MARK: Jay - 레이아웃 갱신
    override func layoutSubviews() {
        super.layoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
        updateHeight()
    }
    
    // MARK: Jay - 외부에서 태그 받아서 설정
    func setTags(_ tags: [String]) {
        self.tags = tags
        collectionView.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.updateHeight()
        }
    }
    
    // MARK: Jay - 태그 배열만큼 셀을만듦
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoTagCell.reuseID, for: indexPath
        ) as? VideoTagCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: "#\(tags[indexPath.item])")
        return cell
    }
    
    // MARK: Jay - 컬렉션뷰 섹션의 패딩을 0으로 설정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
