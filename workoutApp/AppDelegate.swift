 //
//  AppDelegate.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 11/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // seed Core Data with development Data
        DatabaseController.clearCoreData()
        
        let dataSeeder = DataSeeder(context: DatabaseController.getContext())
        dataSeeder.seedCoreData()
        DatabaseController.saveContext()
        
        customizeUIAppearance()
        UINavigationBar.appearance().barTintColor = UIColor.light
//        UINavigationBar.appearance().tintColor = UIColor.purple
        let backArrowImage = UIImage(named: "arrow-back-blue")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.custom(style: CustomFont.bold, ofSize: FontSize.medium),
            NSForegroundColorAttributeName: UIColor.faded,
            NSKernAttributeName: 0.7,
        ]
    
        
        // Instantiate Tab Bar
        let tabBar = CustomTabBarController()
        window?.rootViewController = tabBar
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DatabaseController.saveContext()
    }
    
    // MARK: - Custom Methods
    
    private func customizeUIAppearance() {
        print("cuztomizing")
    }
}

