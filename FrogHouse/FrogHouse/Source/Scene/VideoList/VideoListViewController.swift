//
//  VideoListViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class VideoListViewController: BaseViewController<VideoListViewModel> {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    
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
        
        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.reuseIdentifier)
    }
    
    override func setupLayouts() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.pinToSuperview()
    }
    
    override func bind() {
        viewModel.loadInitial()
        tableView.reloadData()
    }
    
    private func loadMoreIfNeeded() {
        if viewModel.loadMoreIfNeeded() {
            tableView.reloadData()
        }
    }
}

extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: VideoCell.reuseIdentifier,
            for: indexPath
        ) as? VideoCell else { return UITableViewCell() }
        
        let item = viewModel.item(at: indexPath.row)
        cell.configure(title: item.title, desc: item.description, liked: item.isLiked)
        
        cell.onLikeTapped = { [weak self] in
            guard let self else { return }
            self.viewModel.toggleLike(at: indexPath.row)
            let newItem = self.viewModel.item(at: indexPath.row)
            cell.setLiked(newItem.isLiked, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let total = viewModel.numberOfRows()
        guard total >= 3 else { return }
        if indexPath.row == total - 3 {
            loadMoreIfNeeded()
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let it = viewModel.item(at: indexPath.row)
        print("선택된 셀 index=\(indexPath.row)")
        print("제목: \(it.title)")
        print("설명: \(it.description)")
        
    }
}
