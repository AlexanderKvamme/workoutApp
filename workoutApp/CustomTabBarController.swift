//
//  CustomTabBarController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    let selectionIndicator = tabBarSelectionIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let profileController = TestViewController()
        let progressController = SelectionViewController()
        let historyController = TestViewController()
        let workoutController = TestViewController()
        
        viewControllers = [progressController, historyController, workoutController, profileController]
        
        progressController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "progress"), tag: 0)
        historyController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "history"), tag: 1)
        workoutController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "workout"), tag: 2)
        profileController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), tag: 3)

        let tabBarItems = tabBar.items! as [UITabBarItem]
        for item in tabBarItems {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        tabBar.tintColor = UIColor.light
        tabBar.unselectedItemTintColor = UIColor.light
        tabBar.barTintColor = UIColor.dark
        tabBar.isTranslucent = false
        
        // SelectionView
        
        selectionIndicator.setup(selectableItemsCount: 4, atHeight: tabBar.frame.minY)
        view.addSubview(selectionIndicator)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectionIndicator.moveToItem(item.tag, ofItemCount: (tabBar.items?.count)!)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
