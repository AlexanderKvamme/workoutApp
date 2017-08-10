//
//  CustomTabBarController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

class CustomTabBarController: UITabBarController {

    let selectionIndicator = tabBarSelectionIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Progress
        
//        let progressController = SelectionViewController(
//            header: SelectionViewHeader(header: "Not yet implemented", subheader: "Progress"),
//            buttons: [SelectionViewButton(header: "Normal", subheader: "9 Workouts"),
//                      SelectionViewButton(header: "Pyramid", subheader: "4 Workouts"),
//                      SelectionViewButton(header: "Drop set", subheader: "3 Workouts"),
//                      SelectionViewButton(header: "Cardio", subheader: "2 Workouts"),
//            ])
        
        let progressController = TestViewController()
        
        // MARK: - History
        
        // Embed to enable user to navigate back through stack
        let historySelectionViewController = HistorySelectionViewController()
        let historyNavigationController = CustomNavigationViewController(rootViewController: historySelectionViewController)
        
        // MARK: - Workout Tab
        let workoutSelectionViewController = WorkoutSelectionViewController()
        let workoutNavigationController = CustomNavigationViewController(rootViewController: workoutSelectionViewController)
        
        // MARK: - Profile Tab
        let profileController = ProfileController()
//        let profileNavigationController = CustomNavigationViewController(rootViewController: profileController)
        let profileNavigationController = CustomNavigationViewController(rootViewController: profileController)
        
        // MARK: - Set up navbar
        viewControllers = [progressController, historyNavigationController, workoutNavigationController, profileController]
        
        progressController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "progress"), tag: 0)
        historyNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "history"), tag: 1)
        workoutNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "workout"), tag: 2)
        profileController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), tag: 3)

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
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectionIndicator.moveToItem(item.tag, ofItemCount: (tabBar.items?.count)!)
    }
    
    public func hideSelectionIndicator() {
        selectionIndicator.isHidden = true
    }
    
    public func showSelectionindicator() {
        selectionIndicator.isHidden = false
    }
}

