//
//  MyVideoViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Combine
import UIKit

final class MyVideoViewController: BaseViewController<MyVideoViewModel> {
    private var histories: [HistoryItem] = []
    private var recommendedVideos: [VideoListViewModel.Item] = []
    
    //TODO: 서정원 - String -> Image 타입으로 변경하는 메서드가 필요함
    let demoHistories = [
        HistoryItem(title: "오늘의 하이라이트1", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트2", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트3", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트4", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트5", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트6", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트7", thumbnailURL: ""),
        HistoryItem(title: "오늘의 하이라이트8", thumbnailURL: "")
    ]
    
    let demoRecommendedVideos = [
        VideoListViewModel.Item(title: "asd1", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd2", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd3", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd4", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd5", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd6", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: [])
    ]
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemBackground
        cv.alwaysBounceVertical = true
        cv.delegate = self
        return cv
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<MyVideoSection, MyVideoItem> = {
        let dataSource = UICollectionViewDiffableDataSource<MyVideoSection, MyVideoItem>(collectionView: self.collectionView) { [weak self] collectionView, indexPath,
            item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .history(let model):
                return collectionView.dequeueConfiguredReusableCell(using: self.historyRegistration, for: indexPath, item: model)
            case .recommend(let model):
                return collectionView.dequeueConfiguredReusableCell(using: self.videoCellRegistration, for: indexPath, item: model)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: self.headerRegistration, for: indexPath)
        }
        return dataSource
    }()
    
    private let headerRegistration: UICollectionView.SupplementaryRegistration<
        SectionHeaderView> = {
            UICollectionView.SupplementaryRegistration<SectionHeaderView>(
                elementKind: UICollectionView.elementKindSectionHeader
            ) { headerView, _, indexPath in
                guard let section = MyVideoSection(rawValue: indexPath.section) else { return }
                
                switch section {
                case .history:
                    headerView.headerText = "시청 기록"
                    headerView.setTrailingActionTitle("모두 보기", handler: { print("debug - 모두 보기"
                    ) })
                case .recommend:
                    headerView.headerText = "추천 영상"
                }
            }
        }()
    
    private let historyRegistration: UICollectionView.CellRegistration<HistoryCardCell,HistoryItem> = {
        UICollectionView.CellRegistration<HistoryCardCell, HistoryItem> { cell,
            _,
            model in
            cell.configure(with: model)
        }
    }()
    
    private let videoCellRegistration = UICollectionView.CellRegistration<VideoCell, VideoListViewModel.Item> { cell, _, model in
        cell.configure(title: model.title, description: model.description, isLiked: model.isLiked, thumbnailImageURL: model.thumbnailImageURL)
    }
    
    override func setupUI() {
        super.setupUI()
        
        collectionView.dataSource = self.dataSource
        configureData(histories: demoHistories, recommendedVideos: demoRecommendedVideos, animate: false)
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        collectionView.anchor
            .top(view.safeAreaLayoutGuide.topAnchor)
            .leading(view.safeAreaLayoutGuide.leadingAnchor)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    override func bind() {
        super.bind()
    }
    
    func configureData(histories: [HistoryItem], recommendedVideos: [VideoListViewModel.Item], animate: Bool = true) {
        self.histories = histories
        self.recommendedVideos = recommendedVideos
        applySnapshot(animate: animate)
    }

    
    private func applySnapshot(animate: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<MyVideoSection, MyVideoItem>()
        snapshot.appendSections([.history, .recommend])
        snapshot.appendItems(histories.map { .history($0) }, toSection: .history)
        snapshot.appendItems(recommendedVideos.map { MyVideoItem.recommend($0) }, toSection: .recommend)
        
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    // MARK: - Compositional Layout
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let section = MyVideoSection(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .history:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(160),
                    heightDimension: .absolute(220)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = .init(top: 12, leading: 12, bottom: 16, trailing: 12)
                
                if let header = self?.makeHeaderItem() {
                    section.boundarySupplementaryItems = [header]
                }
                return section
            case .recommend:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 0, leading: 20, bottom: 8, trailing: 20)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(120)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 12, leading: 0, bottom: 16, trailing: 0)

                if let header = self?.makeHeaderItem() {
                    section.boundarySupplementaryItems = [header]
                }
                return section
            }
        }
    }
    
    private func makeHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

extension MyVideoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .history(let model):
            print("Tap history: \(model.title)")
        case .recommend(let model):
            print("Tap recommend: \(model.title)")
        }
    }
}
