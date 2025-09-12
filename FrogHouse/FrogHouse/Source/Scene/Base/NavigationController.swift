//
//  NavigationController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class NavigationController: UINavigationController {
    override func viewDidLoad() {
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = UIColor.FH.signatureGreen.color
        updateTitle(for: topViewController)
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    private func updateTitle(for viewController: UIViewController?) {
        guard let vc = viewController else { return }
        vc.navigationItem.title = vc.navigationItem.title
    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        updateTitle(for: viewController)
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
