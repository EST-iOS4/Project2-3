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
    private var dataSource: UICollectionViewDiffableDataSource<Section, VideoListViewModel.Item>!
    
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
        layout.minimumLineSpacing = 8
        
        let collectionView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.FH.backgroundBase.color // TODO: 송지석 (색상 추후 교체)
        collectionView.delegate = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchVideoList()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "모든 콘텐츠"
        
        view.backgroundColor = UIColor.FH.backgroundBase.color
    }
    
    override func setupLayouts() {
        view.addSubview(scrollView)
        view.addSubview(emptyView)
        scrollView.addSubview(containerStackView)
        [categorySegmentedControl, videoCollectionView].forEach { containerStackView.addArrangedSubview($0) }
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
    private func categoryChanged(_ sender: UISegmentedControl) {
        viewModel.selectCategory(at: sender.selectedSegmentIndex)
    }
}

// MARK: - Setup DataSource
extension VideoListViewController {
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, VideoListViewModel.Item>(collectionView: videoCollectionView) { collectionView, indexPath, videoItem in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as? VideoCell ?? VideoCell()
            cell.configure(
                title: videoItem.title,
                description: videoItem.description,
                isLiked: videoItem.isLiked,
                thumbnailImageURL: nil
            )
            
            cell.onLikeTapped = { [weak self] in
                guard let self else { return }
                self.viewModel.toggleLike(at: indexPath.row)
            }
            return cell
        }
    }
    
    func applySnapshot(videoItems: [VideoListViewModel.Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, VideoListViewModel.Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videoItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(videoURL: item.thumbnailImageURL))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 120)
    }
}
