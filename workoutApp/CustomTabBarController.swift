//
//  CustomTabBarController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

/// Tab bar displayed in the bottom of the main screen. Used to let users navigate between History, Workout, and Profile tabs.
class CustomTabBarController: UITabBarController {

    // MARK: - Properties
    
    var selectionIndicator: TabBarSelectionIndicator? // For iOS 11
    
    // MARK: - Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        selectedIndex = 2 // Initial selection: The Profile Tab
        
        setupSelectionIndicatorIfiOS11()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        delegate = self

        // History
        let historySelectionViewController = HistorySelectionViewController()
        let historyNavigationController = CustomNavigationViewController(rootViewController: historySelectionViewController)
        
        // Workout Tab
        let workoutSelectionViewController = WorkoutSelectionViewController()
        let workoutNavigationController = CustomNavigationViewController(rootViewController: workoutSelectionViewController)
        
        // Profile Tab
        let profileController = ProfileController()
        let profileNavigationController = CustomNavigationViewController(rootViewController: profileController)
        
        // Set up navbar
        viewControllers = [historyNavigationController, workoutNavigationController, profileNavigationController]
        historyNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage.historyIcon, tag: 0)
        workoutNavigationController.tabBarItem = UITabBarItem(title: "", image: UIImage.workoutIcon, tag: 1)
        profileController.tabBarItem = UITabBarItem(title: "", image: UIImage.profileIcon, tag: 2)
        
        // Accessibility
        workoutNavigationController.tabBarItem.accessibilityIdentifier = "workout-tab"
        historyNavigationController.tabBarItem.accessibilityIdentifier = "history-tab"
        profileController.tabBarItem.accessibilityIdentifier = "profile-tab"
        
        let tabBarItems = tabBar.items! as [UITabBarItem]
        
        for item in tabBarItems {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        tabBar.tintColor = UIColor.lightest
        tabBar.unselectedItemTintColor = UIColor.light
        tabBar.barTintColor = UIColor.darkest
        tabBar.isTranslucent = false
    }
    
    // MARK: - Overrides
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectionIndicator?.moveToItem(selectedIndex, ofItemCount: viewControllers!.count)
    }
    
    // MARK: - Methods
    
    private func setupSelectionIndicatorIfiOS11() {
        if #available(iOS 11, *) {
            selectionIndicator = TabBarSelectionIndicator(count: 3)
            guard let selectionIndicator = selectionIndicator else { return }
            view.addSubview(selectionIndicator)
            
            selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            // Constraint to the tabBar top
            let tabBarHeight = tabBar.frame.height
            NSLayoutConstraint.activate([
                selectionIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -tabBarHeight)
                ])
        }
    }
    
    // MARK: TabBar Delegate methods
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selectionIndicator?.moveToItem(item.tag, ofItemCount: (tabBar.items?.count)!)
    }
    
    public func hideSelectionIndicator(shouldAnimate: Bool) {
        if shouldAnimate {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.selectionIndicator?.alpha = 0
            }, completion: nil)
        } else {
            self.selectionIndicator?.alpha = 0
        }
    }
    
    public func showSelectionIndicator() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.selectionIndicator?.alpha = 1
        }, completion: nil)
    }
}

// MARK: - Extensions

extension CustomTabBarController: UITabBarControllerDelegate {
    // disable popping navigation stack on second tap, so that users dont accidentally cancels workout
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}

