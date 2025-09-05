//
//  VideoListViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class VideoListViewController: BaseViewController<VideoListViewModel> {
    
    // TODO : 송지석 (이미지 캐싱 해야됨)
    private struct Item {
        let title: String
        let description: String
        var isLiked: Bool
    }
    
    private final class VideoCell: UITableViewCell {
        var onLikeTapped: (() -> Void)?
        
        private let thumbImageView = UIImageView()
        private let titleLabel     = UILabel()
        private let descLabel      = UILabel()
        private let likeButton     = UIButton(type: .system)
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            setupUI()
            setupConstraints()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        private func setupUI() {
            thumbImageView.contentMode = .scaleAspectFill
            thumbImageView.clipsToBounds = true
            thumbImageView.clipsToBounds = true
            thumbImageView.layer.cornerRadius = 8
            thumbImageView.backgroundColor = .tertiarySystemFill
            thumbImageView.image = UIImage(systemName: "video")
            
            titleLabel.font = UIFont.FH.title(size: 20)
            titleLabel.textColor = .label
            titleLabel.numberOfLines = 2
            titleLabel.lineBreakMode = .byTruncatingTail
            
            descLabel.font = UIFont.FH.body(size: 15)
            descLabel.textColor = .secondaryLabel
            descLabel.numberOfLines = 2
            descLabel.lineBreakMode = .byTruncatingTail
            
            let heart = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .medium)
            likeButton.setPreferredSymbolConfiguration(heart, forImageIn: .normal)
            likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
            
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            contentView.addSubview(thumbImageView)
            contentView.addSubview(likeButton)
            contentView.addSubview(titleLabel)
            contentView.addSubview(descLabel)
        }
        
        private func setupConstraints() {
            let guide = contentView.layoutMarginsGuide
            let spacing: CGFloat = 8
            
            let titleHeight = ceil(titleLabel.font.lineHeight * 2)
            titleLabel.anchor.height(titleHeight)
            
            let descHeight = ceil(descLabel.font.lineHeight * 2)
            descLabel.anchor.height(descHeight)
            
            thumbImageView.anchor
                .leading(guide.leadingAnchor)
                .centerY(guide.centerYAnchor)
                .width(120)
            thumbImageView.heightAnchor.constraint(
                equalTo: thumbImageView.widthAnchor, multiplier: 10.0/16.0
            ).isActive = true
            
            likeButton.anchor
                .top(guide.topAnchor)
                .trailing(guide.trailingAnchor)
                .size(width: 24, height: 24)
            
            titleLabel.anchor
                .top(guide.topAnchor)
                .leading(thumbImageView.trailingAnchor, offset: 12)
                .trailing(likeButton.leadingAnchor, offset: 8)
            
            descLabel.anchor
                .top(titleLabel.bottomAnchor, offset: spacing)
                .leading(titleLabel.leadingAnchor)
                .trailing(guide.trailingAnchor)
                .bottom(guide.bottomAnchor)
            
            likeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        @objc private func didTapLike() { onLikeTapped?() }
        
        func configure(title: String, desc: String, liked: Bool) {
            titleLabel.text = title
            descLabel.text  = desc
            setLiked(liked, animated: false)
        }
        
        func setLiked(_ liked: Bool, animated: Bool = true) {
            let img = UIImage(systemName: liked ? "heart.fill" : "heart")
            if animated {
                UIView.transition(with: likeButton, duration: 0.12, options: .transitionCrossDissolve) {
                    self.likeButton.setImage(img, for: .normal)
                    self.likeButton.tintColor = liked ? .systemRed : .label
                }
            } else {
                likeButton.setImage(img, for: .normal)
                likeButton.tintColor = liked ? .systemRed : .label
            }
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var allItems: [Item] = (1...40).map { i in
        Item(title: "제목 \(i)",
             description: "안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.안녕하세요 반갑습니다.",
             isLiked: false)
    }
    private var visibleItems: [Item] = []
    
    private let pageSize = 10
    private var isLoading = false
    
    override func setupUI() {
        super.setupUI()
        

        view.backgroundColor = .systemBackground // TODO : 송지석 (색상 추후 교체)
        title = "상세리스트화면"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground // TODO : 송지석 (색상 추후 교체)
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(VideoCell.self, forCellReuseIdentifier: "VideoCell")
    }
    
    override func setupLayouts() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.pinToSuperview()
    }
    
    override func bind() {
        visibleItems = Array(allItems.prefix(pageSize))
        tableView.reloadData()
    }
    
    private func loadMoreIfNeeded() {
        guard !isLoading else { return }
        let nextIndex = visibleItems.count
        guard nextIndex < allItems.count else { return }
        
        isLoading = true
        let newIndex = min(nextIndex + pageSize, allItems.count)
        visibleItems.append(contentsOf: allItems[nextIndex..<newIndex])
        tableView.reloadData()
        isLoading = false
    }
}

extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "VideoCell",
            for: indexPath
        ) as? VideoCell else { return UITableViewCell() }
        
        let item = visibleItems[indexPath.row]
        cell.configure(title: item.title, desc: item.description, liked: item.isLiked)
        
        cell.onLikeTapped = { [weak self, weak tableView, weak cell] in
            guard let self, let tableView, let cell,
                  let current = tableView.indexPath(for: cell) else { return }
            self.visibleItems[current.row].isLiked.toggle()
            self.allItems[current.row].isLiked = self.visibleItems[current.row].isLiked
            cell.setLiked(self.visibleItems[current.row].isLiked, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard visibleItems.count >= 3 else { return }
        if indexPath.row == visibleItems.count - 3 {
            loadMoreIfNeeded()
        }
    }
    
    
    // 화면 전환 없음, 상세표시 담당자가 상세 UI 작업 예정 (선택된 리스트 print만 찍음)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let it = visibleItems[indexPath.row]
        print("선택된 셀 index=\(indexPath.row)")
        print("제목: \(it.title)")
        print("설명: \(it.description)")
        
    }
}
