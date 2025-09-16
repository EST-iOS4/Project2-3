//
//  VideoTagListView.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

enum TagAlignment {
    case left
    case center
}

final class VideoTagListView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var tags: [String] = []
    private let layout: AlignedFlowLayout
    
    private lazy var collectionView: AutoSizingCollectionView = {
        let cv = AutoSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = true
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = true
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(VideoTagCell.self,
                    forCellWithReuseIdentifier: VideoTagCell.reuseID)
        return cv
    }()
    
    init(alignment: TagAlignment) {
        layout = AlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.alignment = alignment
        
        super.init(frame: .zero)
        
        addSubview(collectionView)
        collectionView.pinToSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setTags(_ tags: [String]) {
        self.tags = tags
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
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
