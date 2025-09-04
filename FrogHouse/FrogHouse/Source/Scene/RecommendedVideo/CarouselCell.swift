////
////  CarouselCell.swift
////  FrogHouse
////
////  Created by JAY on 9/4/25.
////
//
//import UIKit
//
//final class CarouselCell: UICollectionViewCell {
//  static let reuseID = "CarouselCell"
//  
//  
//  private let imageView = UIImageView()
//  private let titleLabel = UILabel()
//  private let detailLabel = UILabel()
//  
//  
//  private let tagScroll = UIScrollView()
//  private let tagStack = UIStackView()
//  
//  
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    contentView.backgroundColor = .systemBackground
//    setupViews()
//    setupConstraints()
//  }
//  
//  
//  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//  
//  
//  private func setupViews() {
//    // 미리보기 이미지 (크게)
//    imageView.contentMode = .scaleAspectFill
//    imageView.clipsToBounds = true
//    imageView.layer.cornerRadius = 16
//    
//    
//    // 제목
//    titleLabel.font = .preferredFont(forTextStyle: .title2)
//    titleLabel.numberOfLines = 2
//    
//    
//    // 상세 설명
//    detailLabel.font = .preferredFont(forTextStyle: .body)
//    detailLabel.numberOfLines = 0
//    detailLabel.textColor = .secondaryLabel
//    
//    
//    // 태그 스크롤/스택
//    tagScroll.showsHorizontalScrollIndicator = false
//    tagStack.axis = .horizontal
//    tagStack.alignment = .center
//    tagStack.spacing = 8
//    
//    
//    tagScroll.addSubview(tagStack)
//    
//    
//    contentView.addSubview(imageView)
//    contentView.addSubview(titleLabel)
//    contentView.addSubview(detailLabel)
//    contentView.addSubview(tagScroll)
//  }
//  
//  
//  private func setupConstraints() {
//    imageView.translatesAutoresizingMaskIntoConstraints = false
//    titleLabel.translatesAutoresizingMaskIntoConstraints = false
//    detailLabel.translatesAutoresizingMaskIntoConstraints = false
//    tagScroll.translatesAutoresizingMaskIntoConstraints = false
//    tagStack.translatesAutoresizingMaskIntoConstraints = false
//    
//    
//    NSLayoutConstraint.activate([
//      imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
//      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//      imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
//      
//      
//      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
//      titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
//      titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
//      
//      
//      detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//      detailLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
//      detailLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
//      
//      
//      tagScroll.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 180),
//      tagScroll.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
//      tagScroll.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
//      tagScroll.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
//      tagScroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
//      
//      
//      tagStack.topAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.topAnchor),
//      tagStack.leadingAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.leadingAnchor),
//      tagStack.trailingAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.trailingAnchor),
//      tagStack.bottomAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.bottomAnchor),
//      tagStack.heightAnchor.constraint(equalTo: tagScroll.frameLayoutGuide.heightAnchor)
//    ])
//  }
//  
//  
//  private func makeTagLabel(_ text: String) -> UILabel {
//    let label = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
//    label.text = text
//    label.font = .preferredFont(forTextStyle: .footnote)
//    label.textColor = .label
//    label.backgroundColor = .systemGreen.withAlphaComponent(0.8)
//    label.layer.cornerRadius = 10
//    label.clipsToBounds = true
//    return label
//  }
//  
//  // MARK: Jay - 셀 중복 방지 (태그 제거, 이미지 nil 처리)
//  override func prepareForReuse() {
//    super.prepareForReuse()
//    tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
//    imageView.image = nil
//  }
//  
//  
//  func configure(with item: CarouselItem) {
//    imageView.image = UIImage(named: item.imageName)
//    titleLabel.text = item.title
//    detailLabel.text = item.detail
//    
//    
//    tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
//    for tag in item.tags {
//      tagStack.addArrangedSubview(makeTagLabel(tag))
//    }
//  }
//}



//
//  CarouselCell.swift
//  FrogHouse
//
//  Created by JAY on 9/4/25.
//

import UIKit

final class CarouselCell: UICollectionViewCell {
  static let reuseID = "CarouselCell"
  
  
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let detailLabel = UILabel()
  
  
  private let tagScroll = UIScrollView()
  private let tagStack = UIStackView()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .systemBackground
    setupViews()
    setupConstraints()
  }
  
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  private func setupViews() {
    // MARK: Jay - 미리보기 이미지 (크게)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 16
    contentView.addSubview(imageView)
  }
  
  
  private func setupConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    // MARK: Jay - 이미지가 셀을 가득 채우도록 >> 삭제할 주석
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
  
  private func makeTagLabel(_ text: String) -> UILabel {
    let label = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
    label.text = text
    label.font = .preferredFont(forTextStyle: .footnote)
    label.textColor = .label
    label.backgroundColor = .systemGreen.withAlphaComponent(0.8)
    label.layer.cornerRadius = 10
    label.clipsToBounds = true
    return label
  }
  
  // MARK: Jay - 셀 중복 방지 (태그 제거, 이미지 nil 처리)
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }
  
  
  func configure(with item: CarouselItem) {
    imageView.image = UIImage(named: item.imageName)
  }
}
