//
//  CustomTabBarController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Properties
    
    let selectionIndicator = tabBarSelectionIndicatorView()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self

        // MARK: History
        
        // Embed to enable user to navigate back through stack
        let historySelectionViewController = HistorySelectionViewController()
        let historyNavigationController = CustomNavigationViewController(rootViewController: historySelectionViewController)
        
        // MARK: Workout Tab
        let workoutSelectionViewController = WorkoutSelectionViewController()
        let workoutNavigationController = CustomNavigationViewController(rootViewController: workoutSelectionViewController)
        
        // MARK: Profile Tab
        let profileController = ProfileController()
        let profileNavigationController = CustomNavigationViewController(rootViewController: profileController)
        
        // MARK: Set up navbar
        viewControllers = [historyNavigationController, workoutNavigationController, profileNavigationController]
        
        //progressController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "progress"), tag: 0)
        historyNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "history"), tag: 0)
        workoutNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "workout"), tag: 1)
        profileController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), tag: 2)

        let tabBarItems = tabBar.items! as [UITabBarItem]
        
        for item in tabBarItems {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        tabBar.tintColor = UIColor.lightest
        tabBar.unselectedItemTintColor = UIColor.light
        tabBar.barTintColor = UIColor.darkest
        tabBar.isTranslucent = false
        
        // Tab selection indicator (hovering over selected tab)
        selectionIndicator.setup(selectableItemsCount: viewControllers!.count, atHeight: tabBar.frame.minY)
        view.addSubview(selectionIndicator)
    }
    
    // MARK: - Methods
    
    // TabBarController methods
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectionIndicator.moveToItem(item.tag, ofItemCount: (tabBar.items?.count)!)
    }
    
    public func hideSelectionIndicator(shouldAnimate: Bool) {
        if shouldAnimate {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.selectionIndicator.alpha = 0
            }, completion: nil)
        } else {
            self.selectionIndicator.alpha = 0
        }
    }
    
    public func showSelectionindicator() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.selectionIndicator.alpha = 1
        }, completion: nil)
    }
    
    // Delegate methods
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // disable popping navigation stack on second tap
        return viewController != tabBarController.selectedViewController
    }
}

