//
//  MyVideoHistoryAllViewController.swift
//  FrogHouse
//
//  Created by 서정원 on 9/14/25.
//

import UIKit

final class MyVideoHistoryAllViewController: BaseViewController<MyVideoHistoryAllViewModel> {
    enum Section: Int, Hashable {
        case main
    }
    private var dataSource: UICollectionViewDiffableDataSource<Section, MyVideoHistoryAllViewModel.VideoListAllItem>!
    
    private let emptyView = EmptyView(state: .noVideo)
    
    private lazy var videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.FH.backgroundBase.color
        collectionView.delegate = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            do {
                try await viewModel.fetchVideoList()
            } catch {
                showSnackBar(type: .fetchVideo(false))
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "시청 기록"
    }
    
    override func setupLayouts() {
        [videoCollectionView, emptyView].forEach { view.addSubview($0) }
    }
    
    override func setupConstraints() {
        videoCollectionView.pinToSuperview()
        
        emptyView.anchor
            .top(view.safeAreaLayoutGuide.topAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    override func bind() {
        super.bind()
        setupDataSource()
        
        viewModel.$videoList
            .receive(on: RunLoop.main)
            .sink { [weak self] videoItems in
                self?.emptyView.isHidden = !videoItems.isEmpty
                self?.applySnapshot(videoItems: videoItems)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Setup DataSource
extension MyVideoHistoryAllViewController {
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MyVideoHistoryAllViewModel.VideoListAllItem>(collectionView: videoCollectionView) { collectionView, indexPath, videoItem in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as? VideoCell ?? VideoCell()
            cell.configure(
                title: videoItem.title,
                description: videoItem.descriptionText,
                isLiked: videoItem.isLiked,
                thumbnailImageURL: videoItem.thumbnailURL
            )
            
            cell.onLikeTapped = { [weak self] in
                Task {
                    guard
                        let self,
                        let selectedIndexPath = collectionView.indexPath(for: cell),
                        let item = self.dataSource.itemIdentifier(for: selectedIndexPath)
                    else { return }

                    do {
                        try await self.viewModel.toggleLike(id: item.id, isLiked: !cell.isLiked)
                        cell.isLiked.toggle()
                        self.showSnackBar(type: cell.isLiked ? .updateLikedState(true) : .updateUnLikedState(true))
                    } catch {
                        self.showSnackBar(type: cell.isLiked ? .updateLikedState(false) : .updateUnLikedState(false))
                    }
                }
            }
            return cell
        }
    }
    
    func applySnapshot(videoItems: [MyVideoHistoryAllViewModel.VideoListAllItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MyVideoHistoryAllViewModel.VideoListAllItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videoItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyVideoHistoryAllViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(id: item.id))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 40, height: 80)
    }
}
