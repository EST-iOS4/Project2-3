//
//  BaseViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import class Combine.AnyCancellable
import UIKit

class BaseViewController<ViewModel>: UIViewController {
    let viewModel: ViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit called \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called \(self)")
        bind()
        setupUI()
        setupLayouts()
        setupConstraints()
    }
    
    func setupLayouts() { }
    
    func setupConstraints() { }
    
    /// 뷰 컨트롤러의 UI 속성을 설정합니다.
    /// 예: 배경색, 타이틀, 네비게이션 바 스타일 등
    func setupUI() {
        view.backgroundColor = UIColor.FH.backgroundBase.color
    }
    
    /// ViewModel 바인딩에 필요한 코드
    func bind() { }
}

extension BaseViewController {
    func showSnackBar(type: FHSnackBarType) {
        FHSnackBar(contextView: view, type: type)
            .show()
    }
}
