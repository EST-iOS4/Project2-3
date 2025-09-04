//
//  NavigationController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class NavigationController: UINavigationController {
    override func viewDidLoad() {
        self.navigationBar.prefersLargeTitles = false
        self.navigationBar.isTranslucent = true
        updateTitle(for: topViewController)
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    private func updateTitle(for viewController: UIViewController?) {
        guard let vc = viewController else { return }
        vc.navigationItem.title = vc.title
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
