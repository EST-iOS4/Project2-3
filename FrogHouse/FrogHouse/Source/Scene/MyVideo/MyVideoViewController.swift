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
    private lazy var myVideoCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.delegate = self
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<MyVideoSection, MyVideoItem>!
    private var historyCellRegistration: UICollectionView.CellRegistration<HistoryCardCell,MyVideoViewModel.HistoryVideoItem>!
    private var likedVideoCellRegistration: UICollectionView.CellRegistration<VideoCell, MyVideoViewModel.LikedVideoItem>!
    
    private var headerRegistration: UICollectionView.SupplementaryRegistration<SectionHeaderView>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            do {
                try await viewModel.fetchMyVideoViewModel()
            } catch {
                showSnackBar(type: .fetchVideo(false))
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "나만의 비디오"
        navigationController?.navigationBar.tintColor = UIColor.FH.primary.color
        setupDataSource()
    }
    
    override func setupLayouts() {
        super.setupLayouts()
        view.addSubview(myVideoCollectionView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        myVideoCollectionView.pinToSuperview()
    }
    
    override func bind() {
        super.bind()
        viewModel.$historyVideoModel
            .receive(on: RunLoop.main)
            .sink { [weak self] histories in
                self?.applySnapshot(for: .history, items: histories.map { .history($0) })
            }
            .store(in: &cancellables)
        
        viewModel.$likedVideoModel
            .receive(on: RunLoop.main)
            .sink { [weak self] likes in
                self?.applySnapshot(for: .like, items: likes.map { .like($0) })
            }
            .store(in: &cancellables)
        
    }
    
    private func setupDataSource() {
        historyCellRegistration = UICollectionView.CellRegistration<HistoryCardCell, MyVideoViewModel.HistoryVideoItem> { cell, _, model in
            cell.configureUI(title: model.title, thumbnailImageURL: model.thumbnailURL)
        }
        
        likedVideoCellRegistration = UICollectionView.CellRegistration<VideoCell, MyVideoViewModel.LikedVideoItem> { [weak self] cell, indexPath, item in
            cell.configure(title: item.title, description: item.description, isLiked: item.isLiked, thumbnailImageURL: item.thumbnailURL)
            
            cell.onLikeTapped = { [weak self] in
                guard let self,
                      let indexPath = self.myVideoCollectionView.indexPath(for: cell),
                      case .like(let item) = self.dataSource.itemIdentifier(for: indexPath),
                      item.isLiked else {
                    return
                }
                
                Task {
                    do {
                        try await self.viewModel.cancelLike(at: item)
                        self.showSnackBar(type: .updateUnLikedState(true))
                    } catch {
                        self.showSnackBar(type: .updateUnLikedState(false))
                    }
                }
            }
        }
        
        headerRegistration = UICollectionView.SupplementaryRegistration<SectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView,
            _,
            indexPath in
            guard let self = self, let section = MyVideoSection(rawValue: indexPath.section) else { return }
            
            switch section {
            case .history:
                headerView.headerText = "시청 기록"
                headerView.setTrailingActionTitle("모두 보기", handler: {
                    let vc = MyVideoHistoryAllViewController(viewModel: MyVideoHistoryAllViewModel())
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            case .like:
                headerView.headerText = "좋아요 영상"
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<MyVideoSection, MyVideoItem>(collectionView: self.myVideoCollectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            switch item {
            case .history(let model):
                return collectionView.dequeueConfiguredReusableCell(using: self.historyCellRegistration, for: indexPath, item: model)
            case .like(let model):
                return collectionView.dequeueConfiguredReusableCell(using: self.likedVideoCellRegistration, for: indexPath, item: model)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: self.headerRegistration, for: indexPath)
        }
    }
    
    private func applySnapshot(for section: MyVideoSection, items: [MyVideoItem]) {
        var snapshot = dataSource.snapshot()
        
        if !snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendSections([section])
        }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
        snapshot.appendItems(items, toSection: section)
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(160),
                    heightDimension: .absolute(140)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = .init(top: .zero, leading: 20, bottom: 16, trailing: 12)
                section.interGroupSpacing = 8
                
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
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: .zero, leading: 20, bottom: 16, trailing: 20)
                section.interGroupSpacing = 15
                
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
            heightDimension: .absolute(40)
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
        let selectdVideoID: UUID
        switch item {
        case .history(let model):
            selectdVideoID = model.id
        case .like(let model):
            selectdVideoID = model.id
        }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(id: selectdVideoID))
        navigationController?.pushViewController(vc, animated: true)
    }
}
