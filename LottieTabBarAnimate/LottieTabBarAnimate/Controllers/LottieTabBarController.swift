//
//  LottieTabBarController.swift
//  LottieTabBarAnimate
//
//  Created by 蔡志文 on 11/9/23.
//

import UIKit

class LottieTabBarController: UITabBarController, UITabBarControllerDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()

    delegate = self
    tabBar.backgroundColor = .white

    setupChildController(vc: UIViewController.self, title: "First", image: "icon_home_home", selectImage: "icon_home_home_select")
    setupChildController(vc: UIViewController.self, title: "Second", image: "icon_home_up", selectImage: "icon_home_up_select")
    setupChildController(vc: UIViewController.self, title: "Third", image: "icon_home_card", selectImage: "icon_home_card_select")
    setupChildController(vc: UIViewController.self, title: "Fourth", image: "icon_home_me", selectImage: "icon_home_me_select")
  }

  func setupChildController(vc: UIViewController.Type, title: String, image: String, selectImage: String) {
    let controller = vc.init()
    controller.view.backgroundColor = UIColor(red: CGFloat.random(in: 0..<1), green: CGFloat.random(in: 0..<1), blue: CGFloat.random(in: 0..<1), alpha: 1)
    let nav = UINavigationController(rootViewController: controller)
    nav.tabBarItem.title = title
    nav.tabBarItem.image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
    nav.tabBarItem.selectedImage = UIImage(named: selectImage)?.withRenderingMode(.alwaysOriginal)
    nav.tabBarItem.imageInsets = .init(top: -1.5, left: 0, bottom: 1.5, right: 0)
    addChild(nav)
  }

  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else { return }
    var tabBarSwappableImageViews = [UIView]()
    for subView in tabBarController.tabBar.subviews {
      let subViewType = type(of: subView)
      if "\(subViewType)" == "UITabBarButton" {
        for view in subView.subviews where "\(type(of: view))" == "UITabBarSwappableImageView" {
          tabBarSwappableImageViews.append(view)
        }
      }
    }

    let currentTabBarSwappableImageView = tabBarSwappableImageViews[index]
//    AnimationHelper.gravityAnimation(currentTabBarSwappableImageView)
//    AnimationHelper.zoomIntoZoomOutAnimation(currentTabBarSwappableImageView)
//    AnimationHelper.zAxisRotationAnimation(currentTabBarSwappableImageView)
//    AnimationHelper.yAxisMovementAnimation(currentTabBarSwappableImageView)
//    AnimationHelper.zoomInKeepEffectAnimation(tabBarSwappableImageViews, index: index)
    AnimationHelper.lottieAnimation(currentTabBarSwappableImageView, index: index)
  }
}
