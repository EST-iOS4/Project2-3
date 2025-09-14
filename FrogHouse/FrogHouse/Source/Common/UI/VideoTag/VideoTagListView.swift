//
//  VideoTagListView.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

// MARK: Jay - 여러 태그셀을 2줄로 쌓아주는 컬렉션뷰 (2줄 넘어가면 잘림)
final class VideoTagListView: UIView, UICollectionViewDataSource {
    
    // MARK: Jay - 화면에 표시할 태그 배열
    private var tags: [String] = []
    
    private let collectionView: AutoSizingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        // MARK: Jay - 세로 방향으로 줄을 쌓음
        layout.scrollDirection = .vertical
        // MARK: Jay - 셀 크기 자동 계산
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 6
        let cv = AutoSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        // MARK: Jay - 기본은 스크롤 가능 (실제 여부는 setTags에서 결정)
        cv.isScrollEnabled = true
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = true
        cv.backgroundColor = .clear
        cv.register(VideoTagCell.self,
                    forCellWithReuseIdentifier: VideoTagCell.reuseID)
        return cv
    }()
    
    // MARK: Jay - 높이 2줄로 제한 (뷰 자체 높이를 고정)
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: Jay - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 컬렉션뷰 추가 및 오토레이아웃 설정
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.pinToSuperview()
        
        // MARK: Jay - 2줄 높이 계산: 한줄 × 4 + 줄 간격(6)
        let h = (VideoTagCell.singleLineHeightForCurrentStyle() * 4) + 6
        heightConstraint = heightAnchor.constraint(equalToConstant: h)
        heightConstraint?.isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Jay - 태그 배열 세팅
    func setTags(_ tags: [String]) {
        self.tags = tags
        collectionView.reloadData()
        
        // MARK: Jay - 2줄 이하일 경우 스크롤 비활성화
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 콘텐츠 높이가 뷰 높이(2줄 높이) 이하인지 확인
            let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            let viewHeight = self.bounds.height
            self.collectionView.isScrollEnabled = contentHeight > viewHeight
        }
    }
    
    func collectionView(_ c: UICollectionView, numberOfItemsInSection s: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ c: UICollectionView, cellForItemAt i: IndexPath) -> UICollectionViewCell {
        let cell = c.dequeueReusableCell(withReuseIdentifier: VideoTagCell.reuseID, for: i) as! VideoTagCell
        cell.configure(text: "#\(tags[i.item])")
        return cell
    }
}
