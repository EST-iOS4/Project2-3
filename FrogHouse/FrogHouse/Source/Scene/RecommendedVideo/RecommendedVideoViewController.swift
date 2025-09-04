//
//  RecommendedVideoViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

//final class RecommendedVideoViewController: BaseViewController<RecommendedVideoViewModel> {
//    override func setupUI() {
//        super.setupUI()
//        view.backgroundColor = .blue
//    }
//}

final class RecommendedVideoViewController: UIViewController,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            UICollectionViewDelegateFlowLayout {
  
  // MARK: Jay - 외부 주입 ViewModel (무한 캐러셀/타이머/데이터 관리)
  private let viewModel: RecommendedVideoViewModel
  
  // MARK: Jay - 이미지 캐러셀(위) + 고정 텍스트 영역(아래)
  private var collectionView: UICollectionView!
  private let titleLabel  = UILabel()
  private let detailLabel = UILabel()
  private let tagScroll   = UIScrollView()
  private let tagStack    = UIStackView()
  
  // MARK: Jay - 캐러셀 레이아웃 파라미터 (상황별로 변경되므로 var)
  private var widthRatio: CGFloat  = 0.75   // MARK: Jay - 중앙 카드 너비(컬렉션뷰 폭의 75%)
  private var heightRatio: CGFloat = 0.90   // MARK: Jay - 카드 높이(컬렉션뷰 높이의 90%)
  private var spacing: CGFloat     = 12     // MARK: Jay - 카드 간 간격(겹치게 보이려면 -12 ~ -20)
  private let minScale: CGFloat    = 0.85   // MARK: Jay - 양옆 축소 스케일
  
  // MARK: Jay - 무한 캐러셀 시작 위치 (ViewModel 계산 사용)
  private var initialIndex: Int { viewModel.initialIndex }
  
  // MARK: Jay - 자동 슬라이드 간격 (ViewModel 타이머가 사용)
  private let autoSlideInterval: TimeInterval = 4.0
  
  // MARK: Jay - 레이아웃 변경 감지(회전/사이즈클래스 변경 등에서 1회만 재계산)
  private var lastAppliedSize: CGSize = .zero
  
  // MARK: Jay - 캐러셀 높이 제약들을 보관(상황별 재생성 위해)
  private var aspectConstraint: NSLayoutConstraint!
  private var maxHConstraint: NSLayoutConstraint!
  private var minHConstraint: NSLayoutConstraint!
  
  // MARK: Jay - DI 생성자 (ViewModel 주입)
  init(viewModel: RecommendedVideoViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: Jay - 생명주기: 최초 설정 + 초기 텍스트 동기화
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupImageCarousel()
    setupFixedTextArea()
    viewModel.interval = autoSlideInterval
    
    // MARK: Jay - 초기 표시 안정화(셀 구성 -> 텍스트 세팅)
    collectionView.reloadData()
    applyText(for: initialIndex)
  }
  
  // MARK: Jay - 생명주기: 레이아웃 완료 후 한 번만 중앙으로 스냅 + 동기화
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    // MARK: Jay - 카드 크기/인셋 계산(양옆 미리보기) - 필요 시 1회만
    applyLayoutSizingIfNeeded()
    
    // MARK: Jay - 최초 진입 시 중앙 이동 + 스케일/텍스트 즉시 반영
    if collectionView.indexPathsForVisibleItems.isEmpty {
      let indexPath = IndexPath(item: initialIndex, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
      collectionView.layoutIfNeeded()
      applyScaleEffect()
      applyText(for: initialIndex)
    }
    
    // MARK: Jay - 가시 아이템이 이미 있다면(기기/상황 따라) 현재 중앙 기준으로 동기화
    applyTextForCenteredItem()
  }
  
  // MARK: Jay - 자동 슬라이드: 화면 나타날 때 시작 / 사라질 때 정지
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startAutoSlide()
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopAutoSlide()
  }
  deinit { stopAutoSlide() }
  
  // MARK: Jay - 상단 이미지 캐러셀 구성(가로 스크롤, 스냅, 인셋)
  private func setupImageCarousel() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = spacing
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .clear
    
    // MARK: Jay - 기본 페이징 대신: 커스텀 스냅 + 빠른 관성
    collectionView.isPagingEnabled = false
    collectionView.decelerationRate = .fast
    collectionView.showsHorizontalScrollIndicator = false
    
    collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseID)
    collectionView.dataSource = self
    collectionView.delegate   = self
    
    view.addSubview(collectionView)
    
    // MARK: Jay - 캐러셀 높이 제약 기본값(9:16, 최대 55%, 최소 220)
    aspectConstraint = collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 4.0/3.0)
    maxHConstraint   = collectionView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.55)
    minHConstraint   = collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      aspectConstraint, maxHConstraint, minHConstraint
    ])
    
    // MARK: Jay - 최초 트레이트에 맞춰 파라미터/제약 보정
    updateLayoutForTraits(traitCollection)
  }
  
  // MARK: Jay - 하단 고정 텍스트 영역(title/detail/tags) 구성
  private func setupFixedTextArea() {
    titleLabel.font = .preferredFont(forTextStyle: .title2)
    titleLabel.numberOfLines = 2
    
    detailLabel.font = .preferredFont(forTextStyle: .body)
    detailLabel.textColor = .secondaryLabel
    detailLabel.numberOfLines = 0
    
    tagScroll.showsHorizontalScrollIndicator = false
    tagStack.axis = .horizontal
    tagStack.alignment = .center
    tagStack.spacing = 8
    
    tagScroll.addSubview(tagStack)
    view.addSubview(titleLabel)
    view.addSubview(detailLabel)
    view.addSubview(tagScroll)
    
    [titleLabel, detailLabel, tagScroll, tagStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      
      detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      
      tagScroll.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 12),
      tagScroll.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      tagScroll.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      tagScroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
      tagScroll.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      
      tagStack.topAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.topAnchor),
      tagStack.leadingAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.leadingAnchor),
      tagStack.trailingAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.trailingAnchor),
      tagStack.bottomAnchor.constraint(equalTo: tagScroll.contentLayoutGuide.bottomAnchor),
      tagStack.heightAnchor.constraint(equalTo: tagScroll.frameLayoutGuide.heightAnchor)
    ])
  }
  
  // MARK: Jay - 현재 비율에 맞춰 파라미터/제약 갱신 (iPhone,iPad 가로세로대응)
  private func updateLayoutForTraits(_ traits: UITraitCollection) {
    // MARK: Jay - iPad(regular): 넓은 레이아웃
    if traits.horizontalSizeClass == .regular {
      widthRatio = 0.65
      heightRatio = 0.90
      spacing    = 16
      remakeMaxHeightConstraint(multiplier: 0.55) // 화면 높이의 55% 이하
    }
    // MARK: Jay - iPhone 가로: 더 크게 보여주고 여백은 줄임
    else if traits.verticalSizeClass == .compact {
      widthRatio  = 0.70
      heightRatio = 1.00
      spacing     = 8
      remakeMaxHeightConstraint(multiplier: 0.75) // 화면 높이의 75% 이하 (조금 더 키움)
    }
    // MARK: Jay - iPhone 세로(기본)
    else {
      widthRatio  = 0.75
      heightRatio = 0.90
      spacing     = 12
      remakeMaxHeightConstraint(multiplier: 0.55)
    }
    
    // MARK: Jay - 간격/아이템 크기 다시 계산
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = spacing
    }
    lastAppliedSize = .zero
    applyLayoutSizingIfNeeded()
    collectionView.layoutIfNeeded()
    applyScaleEffect()
    applyTextForCenteredItem()
  }
  
  // MARK: Jay - max 높이 제약 재생성(멀티플라이어 변경 필요하므로 deactivate/새로 생성)
  private func remakeMaxHeightConstraint(multiplier: CGFloat) {
    maxHConstraint.isActive = false
    maxHConstraint = collectionView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: multiplier)
    maxHConstraint.isActive = true
  }
  
  // MARK: Jay - 카드 크기/인셋 1회 계산(양옆 미리보기를 위해 섹션 인셋 적용)
  private func applyLayoutSizingIfNeeded() {
    let bounds = collectionView.bounds
    guard bounds.size != .zero,
          bounds.size != lastAppliedSize,
          let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    else { return }
    
    let itemW = bounds.width  * widthRatio
    let itemH = bounds.height * heightRatio
    layout.itemSize = CGSize(width: itemW, height: itemH)
    
    let insetX = (bounds.width  - itemW) / 2
    let insetY = (bounds.height - itemH) / 2
    layout.sectionInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    layout.minimumLineSpacing = spacing
    
    lastAppliedSize = bounds.size
    layout.invalidateLayout()
  }
  
  // MARK: Jay - 현재 중앙 아이템 인덱스 계산(가장 가까운 셀)
  private func centeredIndex() -> Int? {
    let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
    var best: (idx: Int, dist: CGFloat)?
    
    for ip in collectionView.indexPathsForVisibleItems {
      guard let attrs = collectionView.layoutAttributesForItem(at: ip) else { continue }
      let d = abs(attrs.center.x - centerX)
      if best == nil || d < best!.dist { best = (ip.item, d) }
    }
    return best?.idx
  }
  
  // MARK: Jay - 스케일 효과(중앙 1.0, 멀수록 minScale까지 축소)
  private func applyScaleEffect() {
    guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
    let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
    let activeDistance = layout.itemSize.width
    
    for cell in collectionView.visibleCells {
      guard let ip = collectionView.indexPath(for: cell),
            let attrs = collectionView.layoutAttributesForItem(at: ip) else { continue }
      
      let distance = abs(attrs.center.x - centerX)
      let ratio = max(0, min(1, (activeDistance - distance) / activeDistance)) // MARK: Jay - 1(중앙)~0(가장 멂)
      let scale = minScale + (1 - minScale) * ratio
      cell.transform = CGAffineTransform(scaleX: scale, y: scale)
      cell.layer.zPosition = Double(ratio * 10) // MARK: Jay - 중앙 셀이 위로
    }
  }
  
  // MARK: Jay - 텍스트/태그를 현재 중앙 아이템과 동기화
  private func applyTextForCenteredItem() {
    let idx = centeredIndex() ?? initialIndex
    applyText(for: idx)
  }
  
  // MARK: Jay - 주어진 인덱스의 텍스트/태그 표시
  private func applyText(for virtualIndex: Int) {
    let item = viewModel.item(at: virtualIndex)
    titleLabel.text  = item.title
    detailLabel.text = item.detail
    
    tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    item.tags.forEach { tagStack.addArrangedSubview(makeTagLabel($0)) }
  }
  
  // MARK: Jay - 태그용 패딩 라벨 생성기
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
  
  // MARK: Jay - 자동 슬라이드 시작/정지 (ViewModel 타이머 사용)
  private func startAutoSlide() {
    viewModel.startAutoSlide(currentIndex: { [weak self] in
      self?.centeredIndex()
    }, onTick: { [weak self] next in
      guard let self = self else { return }
      self.collectionView.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
      self.collectionView.layoutIfNeeded()
      self.applyScaleEffect()
      self.applyText(for: next) // MARK: Jay - 움직이자마자 텍스트도 미리 갱신
    })
  }
  private func stopAutoSlide() { viewModel.stopAutoSlide() }
  
  // MARK: Jay - UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.totalVirtualCount
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.reuseID,
                                                        for: indexPath) as? CarouselCell else {
      return UICollectionViewCell()
    }
    cell.configure(with: viewModel.item(at: indexPath.item)) // MARK: Jay - 이미지 전용 셀
    return cell
  }
  
  // MARK: Jay - UICollectionViewDelegateFlowLayout (레이아웃이 정한 itemSize 사용)
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let flow = collectionViewLayout as? UICollectionViewFlowLayout { return flow.itemSize }
    return collectionView.bounds.size
  }
  
  // MARK: Jay - 스크롤 중: 스케일 실시간 반영
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    applyScaleEffect()
  }
  
  // MARK: Jay - 드래그 시작: 오토 슬라이드 일시정지
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    stopAutoSlide()
  }
  
  // MARK: Jay - 드래그 종료 전: 가장 가까운 셀로 스냅(기본 페이징보다 자연스러운 스냅)
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
    let proposedX = targetContentOffset.pointee.x
    let bounds = collectionView.bounds
    let targetRect = CGRect(x: proposedX, y: 0, width: bounds.width, height: bounds.height)
    guard let attrs = layout.layoutAttributesForElements(in: targetRect) else { return }
    
    let centerX = proposedX + bounds.width / 2
    var closest: CGFloat = .greatestFiniteMagnitude
    for a in attrs {
      let diff = a.center.x - centerX
      if abs(diff) < abs(closest) { closest = diff }
    }
    targetContentOffset.pointee.x = proposedX + closest
  }
  
  // MARK: Jay - 스크롤 종료 시 공통 처리: 리센터(무한) + 스케일/텍스트 보정 + 오토 슬라이드 재개
  private func handleScrollEnd() {
    guard let current = centeredIndex() else { return }
    var target = current
    
    if viewModel.shouldRecenter(current) {
      let newIndex = viewModel.recenteredIndex(from: current)
      collectionView.scrollToItem(at: IndexPath(item: newIndex, section: 0),
                                  at: .centeredHorizontally,
                                  animated: false)
      collectionView.layoutIfNeeded()
      applyScaleEffect()
      target = newIndex
    }
    
    applyText(for: target)
    startAutoSlide()
  }
  
  // MARK: Jay - 감속 종료/드래그 즉시 종료/프로그램적 애니메이션 종료에 동일 로직 적용
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    handleScrollEnd()
  }
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate { handleScrollEnd() }
  }
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    collectionView.layoutIfNeeded()
    applyScaleEffect()
    applyTextForCenteredItem()
  }
  
  // MARK: Jay - 사이즈 클래스/다이내믹 타입 변경 대응 (super 호출 불필요)
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    // MARK: Jay - 실제 변화가 없으면 빠르게 반환
    if let prev = previousTraitCollection {
      let sizeClassUnchanged =
      prev.horizontalSizeClass == traitCollection.horizontalSizeClass &&
      prev.verticalSizeClass   == traitCollection.verticalSizeClass
      let contentSizeUnchanged =
      prev.preferredContentSizeCategory == traitCollection.preferredContentSizeCategory
      if sizeClassUnchanged && contentSizeUnchanged { return }
    }
    updateLayoutForTraits(traitCollection)
  }
  
  // MARK: Jay - 회전/윈도우 리사이즈 중 애니메이션과 함께 레이아웃/스케일/텍스트 갱신
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.lastAppliedSize = .zero
      self.updateLayoutForTraits(self.traitCollection)
    })
  }
}
