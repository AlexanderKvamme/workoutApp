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
    lazy var tabBarHeight = tabBar.frame.height
    lazy var tabBarItemLength = Constant.UI.width/CGFloat(3)
    var coreDataManager: CoreDataManager
    
    lazy var xConstraint = { () -> NSLayoutConstraint in
        guard let selectionIndicator = selectionIndicator else {
            fatalError()
        }
        
        return selectionIndicator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
    }()
    
    lazy var yConstraint = { () -> NSLayoutConstraint in
        guard let selectionIndicator = selectionIndicator else {
            fatalError()
        }
        
        if #available(iOS 11, *) {
            return selectionIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -tabBarHeight)
        } else {
            return selectionIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight)
        }
    }()
    
    // MARK: - Initializer
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, coreDataManager: CoreDataManager){
        self.coreDataManager = coreDataManager
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
        let historySelectionViewController = HistorySelectionViewController(coreDataManager: coreDataManager)
        let historyNavigationController = CustomNavigationViewController(rootViewController: historySelectionViewController)
        
        // Workout Tab
        let workoutSelectionViewController = WorkoutSelectionViewController(coreDataManager: coreDataManager)
        let workoutNavigationController = CustomNavigationViewController(rootViewController: workoutSelectionViewController)
        
        // Profile Tab
        let profileController = ProfileController(coreDataManager: coreDataManager)
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
    
    // MARK: - Methods
    
    private func setupSelectionIndicatorIfiOS11() {
        // Indicator only avaiable to ios 11
        guard #available(iOS 11, *) else { return }
        
        selectionIndicator = TabBarSelectionIndicator(tabBarItemcount: 3)
        guard let selectionIndicator = selectionIndicator else { return }
        
        view.addSubview(selectionIndicator)
        
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraint to the tabBar top
        NSLayoutConstraint.activate([
            xConstraint,
            yConstraint,
            ])
    }
    
    // MARK: TabBar Delegate methods
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        moveSelectionIndicator(toItem: item.tag)
    }
    
    // MARK: Private Methods
    
    private func moveSelectionIndicator(toItem i: Int) {
        self.xConstraint.constant = getXPosition(ofItem: i)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func getXPosition(ofItem i: Int) -> CGFloat {
        guard let selectionIndicator = selectionIndicator else { fatalError() }
        return tabBarItemLength*CGFloat(i) + selectionIndicator.indicatorHorizontalShrinkage/2
    }
    
    // MARK: API
    
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
        })
    }
}

// MARK: - Extensions

extension CustomTabBarController: UITabBarControllerDelegate {
    // disable popping navigation stack on second tap, so that users dont accidentally cancels workout
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}

