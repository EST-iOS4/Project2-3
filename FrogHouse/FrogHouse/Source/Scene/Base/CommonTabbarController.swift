//
//  CommonTabbarController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

struct TabbarItem {
    let title: String
    let unselectedImage: UIImage
    let selectedImage: UIImage
}

final class CommonTabbarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let tabs: [TabbarItem] = [
            TabbarItem(title: "Videos", unselectedImage: UIImage(systemName: "video")!, selectedImage: UIImage(systemName: "video.fill")!),
            TabbarItem(title: "Recommended", unselectedImage: UIImage(systemName: "star")!, selectedImage: UIImage(systemName: "star.fill")!),
            TabbarItem(title: "History", unselectedImage: UIImage(systemName: "clock")!, selectedImage: UIImage(systemName: "clock.fill")!)
        ]
        
        let viewControllers: [UIViewController] = [
            NavigationController(rootViewController: VideoListViewController(viewModel: VideoListViewModel())),
            NavigationController(rootViewController: RecommendedVideoViewController(viewModel: RecommendedVideoViewModel(items: CarouselDataSource.makeItems()))),
            NavigationController(rootViewController: MyVideoViewController(viewModel: MyVideoViewModel()))
        ]
        
        for (index, vc) in viewControllers.enumerated() {
            let tab = tabs[index]
            vc.tabBarItem = UITabBarItem(title: tab.title, image: tab.unselectedImage, selectedImage: tab.selectedImage)
        }
        
        self.viewControllers = viewControllers
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
}
