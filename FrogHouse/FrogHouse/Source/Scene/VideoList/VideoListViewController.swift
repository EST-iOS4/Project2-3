//
//  VideoListViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class VideoListViewController: BaseViewController<VideoListViewModel> {
    enum Section: Int, Hashable {
        case main
    }
    private var dataSource: UICollectionViewDiffableDataSource<Section, Video>!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 8, left: 20, bottom: 8, right: 20)
        stackView.spacing = 20
        return stackView
    }()
    
    private let categorySegmentedControl = UISegmentedControl()
    private let emptyView = EmptyView(state: .noVideo)
    
    private lazy var videoCollectionView: AutoSizingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let collectionView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.FH.backgroundBase.color // TODO: 송지석 (색상 추후 교체)
        collectionView.delegate = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try viewModel.fetchVideoList()
        } catch {
            
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "모든 콘텐츠"
        navigationController?.navigationBar.tintColor = UIColor.FH.primary.color
    }
    
    override func setupLayouts() {
        [scrollView, emptyView].forEach { view.addSubview($0) }
        scrollView.addSubview(containerStackView)
        [categorySegmentedControl, videoCollectionView].forEach { containerStackView.addArrangedSubview($0) }
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
    }
    
    override func setupConstraints() {
        scrollView.pinToSuperview()
            .anchor.width(view.widthAnchor)
        
        containerStackView.anchor
            .top(scrollView.topAnchor)
            .leading(scrollView.leadingAnchor)
            .trailing(scrollView.trailingAnchor)
            .bottom(scrollView.bottomAnchor)
            .width(view.widthAnchor)
        
        emptyView.anchor
            .top(categorySegmentedControl.bottomAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor)
        
        categorySegmentedControl.anchor.height(40)
    }
    
    override func bind() {
        setupDataSource()
        
        viewModel.$videoList
            .receive(on: RunLoop.main)
            .sink { [weak self] videoItems in
                self?.emptyView.isHidden = !videoItems.isEmpty
                self?.applySnapshot(videoItems: videoItems)
                
                if self?.refreshControl.isRefreshing == true{
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$categories
            .receive(on: RunLoop.main)
            .sink { [weak self] categories in
                self?.configureSegmentedControl(with: categories.map { $0.title })
            }
            .store(in: &cancellables)
        
        categorySegmentedControl.addTarget(
            self,
            action: #selector(categoryChanged),
            for: .valueChanged
        )
    }
    
    private func configureSegmentedControl(with categories: [String]) {
        categorySegmentedControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category, at: index, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = viewModel.selectedCategoryIndex
    }
    
    @objc
    private func didPullToRefresh() {
        do {
            try viewModel.fetchVideoList()
        } catch {
            
        }
    }
    
    @objc
    private func categoryChanged(_ sender: UISegmentedControl) {
        do {
            try viewModel.selectCategory(at: sender.selectedSegmentIndex)
        } catch {
            
        }
    }
}

// MARK: - Setup DataSource
extension VideoListViewController {
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Video>(collectionView: videoCollectionView) { collectionView, indexPath, videoItem in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as? VideoCell ?? VideoCell()
            cell.configure(
                title: videoItem.title,
                description: videoItem.descriptionText,
                isLiked: videoItem.isLiked,
                thumbnailImageURL: videoItem.thumbnailURL
            )
            
            cell.onLikeTapped = { [weak self] in
                guard let self,
                let selectedIndexPath = collectionView.indexPath(for: cell),
                let item = self.dataSource.itemIdentifier(for: selectedIndexPath) else { return }
                do {
                    try self.viewModel.toggleLike(at: item)
                    cell.updateState(item.isLiked)
                } catch {
                    print("좋아요 \(item.isLiked ? "취소" : "등록")에 실패하였습니다.")
                }
            }
            return cell
        }
    }
    
    func applySnapshot(videoItems: [Video]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videoItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(videoURL: item.mp4URL))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}
