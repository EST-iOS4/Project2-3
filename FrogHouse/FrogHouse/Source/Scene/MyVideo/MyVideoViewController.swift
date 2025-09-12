//
//  MyVideoViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Combine
import Kingfisher
import UIKit

final class MyVideoViewController: BaseViewController<MyVideoViewModel> {
    private var histories: [HistoryItem] = []
    private var recommendedVideos: [VideoListViewModel.Item] = []
    var onLikeTapped: (() -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemBackground
        cv.alwaysBounceVertical = true
        cv.delegate = self
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<MyVideoSection, MyVideoItem>!
    private var historyRegistration: UICollectionView.CellRegistration<HistoryCardCell,HistoryItem>!
    private var videoCellRegistration: UICollectionView.CellRegistration<VideoCell, VideoListViewModel.Item>!
    
    private let headerRegistration: UICollectionView.SupplementaryRegistration<
        SectionHeaderView> = {
            UICollectionView.SupplementaryRegistration<SectionHeaderView>(
                elementKind: UICollectionView.elementKindSectionHeader
            ) { headerView,
                _,
                indexPath in
                guard let section = MyVideoSection(rawValue: indexPath.section) else { return }
                
                switch section {
                case .history:
                    headerView.headerText = "시청 기록"
                    //TODO: 서정원 - 모두 보기 기능의 경우 필수기능 구현 후 개발 예정
                    headerView.setTrailingActionTitle("모두 보기", handler: { print("debug - 모두 보기") })
                case .like:
                    headerView.headerText = "좋아요 영상"
                }
            }
        }()
    
    override func setupUI() {
        super.setupUI()
        
        setupDataSource()
        collectionView.dataSource = self.dataSource
        configureData(histories: MyVideoViewModel().demoHistories, recommendedVideos: MyVideoViewModel().demoRecommendedVideos, animate: false)
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
    
    private func setupDataSource() {
        historyRegistration = UICollectionView.CellRegistration<HistoryCardCell, HistoryItem> { cell, _, model in
            cell.configure(with: model)
        }
        
        videoCellRegistration = UICollectionView.CellRegistration<VideoCell, VideoListViewModel.Item> { [weak self] cell, indexPath, model in
            cell.configure(title: model.title, description: model.description, isLiked: model.isLiked, thumbnailImageURL: model.thumbnailImageURL)
            
            cell.onLikeTapped = { [weak self] in
                guard let self = self else { return }
                guard self.recommendedVideos.indices.contains(indexPath.item) else { return }
                
                var updatedItem = self.recommendedVideos[indexPath.item]
                updatedItem.isLiked.toggle()
                self.recommendedVideos[indexPath.item] = updatedItem
                
                self.applySnapshot(animate: true)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<MyVideoSection, MyVideoItem>(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            switch item {
            case .history(let model):
                return collectionView.dequeueConfiguredReusableCell(using: self.historyRegistration, for: indexPath, item: model)
            case .like(let model):
                return collectionView.dequeueConfiguredReusableCell(using: self.videoCellRegistration, for: indexPath, item: model)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: self.headerRegistration, for: indexPath)
        }
    }
    
    func configureData(histories: [HistoryItem], recommendedVideos: [VideoListViewModel.Item], animate: Bool = true) {
        self.histories = histories
        self.recommendedVideos = recommendedVideos
        applySnapshot(animate: animate)
    }

    
    private func applySnapshot(animate: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<MyVideoSection, MyVideoItem>()
        snapshot.appendSections([.history, .like])
        snapshot.appendItems(histories.map { .history($0) }, toSection: .history)
        snapshot.appendItems(recommendedVideos.map { MyVideoItem.like($0) }, toSection: .like)
        
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
                    heightDimension: .absolute(160)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = .init(top: 12, leading: 20, bottom: 16, trailing: 12)
                
                if let header = self?.makeHeaderItem() {
                    section.boundarySupplementaryItems = [header]
                }
                return section
            case .like:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 0, leading: 0, bottom: 8, trailing: 0)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(120)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 12, leading: 20, bottom: 16, trailing: 20)

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
        case .like(let model):
            print("Tap recommend: \(model.title)")
        }
    }
}
