//
//  VideoListViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Combine
import UIKit

final class VideoListViewController: BaseViewController<VideoListViewModel> {
    enum Section: Int, Hashable {
        case main
    }
    private var categoryActions: [UIAction] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, VideoListViewModel.VideoListItem>!
    
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
    
    private let emptyView = EmptyView(state: .noVideo)
    
    private lazy var videoCollectionView: AutoSizingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        
        let collectionView = AutoSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.FH.backgroundBase.color
        collectionView.delegate = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try viewModel.fetchVideoList()
        } catch {
            showSnackBar(type: .fetchVideo(false))
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var categoryDropdownButton: UIButton = {
        let button = UIButton()
        let chevronImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium), forImageIn: .normal)
        button.setImage(chevronImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = UIColor.FH.signatureGreen.color
        button.setTitleColor(UIColor.FH.signatureGreen.color, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    override func setupUI() {
        super.setupUI()
        setupNavigationItem()
    }
    
    override func setupLayouts() {
        [scrollView, emptyView].forEach { view.addSubview($0) }
        scrollView.addSubview(containerStackView)
        [videoCollectionView].forEach { containerStackView.addArrangedSubview($0) }
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
    }
    
    override func setupConstraints() {
        scrollView.pinToSuperview()
            .anchor.width(view.widthAnchor)
        
        containerStackView.pinToSuperview().anchor
            .width(view.widthAnchor)
        
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
                print("데이터: \(videoItems.map { ($0.title, $0.isLiked) })")
                self?.emptyView.isHidden = !videoItems.isEmpty
                self?.applySnapshot(videoItems: videoItems)
                
                if self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.$categories, viewModel.$selectedCategoryIndex)
            .receive(on: RunLoop.main)
            .sink { [weak self] categories, selectedIndex in
                self?.updateMenu(categories: categories.map { $0.title }, selectedIndex: selectedIndex)
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "모든 콘텐츠"
        let navigationButtonStackView = UIStackView(arrangedSubviews: [categoryDropdownButton])
        navigationButtonStackView.axis = .horizontal
        navigationButtonStackView.alignment = .center
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationButtonStackView)
    }
    
    private func updateMenu(categories: [String], selectedIndex: Int) {
        let actions = categories.enumerated().map { (index, title) in
            UIAction(
                title: title,
                state: index == selectedIndex ? .on : .off) { [weak self] _ in
                    do {
                        try self?.viewModel.selectCategory(at: index)
                    } catch {
                        self?.showSnackBar(type: .fetchVideo(false))
                    }
                }
        }
        categoryDropdownButton.menu = UIMenu(title: "카테고리 선택", children: actions)
        categoryDropdownButton.setTitle(categories[selectedIndex], for: .normal)
    }
    
    @objc
    private func didPullToRefresh() {
        do {
            try viewModel.fetchVideoList()
        } catch {
            showSnackBar(type: .fetchVideo(false))
        }
    }
}

// MARK: - Setup DataSource
extension VideoListViewController {
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, VideoListViewModel.VideoListItem>(collectionView: videoCollectionView) { collectionView, indexPath, videoItem in
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
                    try self.viewModel.toggleLike(id: item.id, isLiked: !cell.isLiked)
                    cell.isLiked = !cell.isLiked
                    showSnackBar(type: cell.isLiked ? .updateLikedState(true) : .updateUnLikedState(true))
                } catch {
                    showSnackBar(type: cell.isLiked ? .updateLikedState(false) : .updateUnLikedState(false))
                }
            }
            return cell
        }
    }
    
    func applySnapshot(videoItems: [VideoListViewModel.VideoListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, VideoListViewModel.VideoListItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videoItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(id: item.id))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}
