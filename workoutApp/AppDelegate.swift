 //
//  AppDelegate.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 11/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData
import AKKIT


var APP_IS_DEBUG = false
var globalTabBar: WellRoundedTabBarController!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let context = DatabaseFacade.persistentContainer.viewContext
        
        // Seed for Fastlane Snapshot data
        if CommandLine.arguments.contains("--fastlaneSnapshot") {
            let seeder = DataSeeder(context: context)
            seeder.seedCoreDataForFastlaneSnapshots()
        }
        
        WorkoutLog.auditWorkoutLogsForMissingDesigns()
        customizeUIAppearance()
        seedIfFirstLaunch(context: context)
        
        // Set initial viewController
        let hexagonScreen = CustomNavigationViewController(rootViewController: HoneycombViewController())
        let historyScreen = CustomNavigationViewController(rootViewController: HistorySelectionViewController())
        let workoutScreen = CustomNavigationViewController(rootViewController: WorkoutSelectionViewController())
        let creatorScreen = CustomNavigationViewController(rootViewController: CreatorScreen())
        let profileScreen = CustomNavigationViewController(rootViewController: ProfileController())

        // FIXME: Make the tabbar controller actually use the images supplied here
        let tabButtonTint = UIColor.black
        let tab3icon = UIImage(named: "create")!
        hexagonScreen.tabBarItem = UITabBarItem(title: "0", image: UIImage.hexIcon.withTintColor(tabButtonTint), tag: 0)
        historyScreen.tabBarItem = UITabBarItem(title: "1", image: UIImage.historyIcon.withTintColor(tabButtonTint), tag: 1)
//        creatorScreen.tabBarItem = UITabBarItem(title: "2", image: UIImage.progressIcon.withTintColor(tabButtonTint), tag: 2)
        creatorScreen.tabBarItem = UITabBarItem(title: "2", image: UIImage.starIcon.withTintColor(tabButtonTint), tag: 2)
        workoutScreen.tabBarItem   = UITabBarItem(title: "3", image: tab3icon.withTintColor(tabButtonTint), tag: 3)
        profileScreen.tabBarItem = UITabBarItem(title: "4", image: UIImage.profileIcon.withTintColor(tabButtonTint), tag: 4)
        
        let screens = [hexagonScreen, historyScreen, workoutScreen, creatorScreen, profileScreen]
//        let centerIcon = UIImage.xmarkIcon.rotate(radians: .pi/4)!
//        let centerIcon = UIImage.close24.rotate(radians: .pi/4)!
        let centerIcon = UIImage(named: "dumbbell")!
//        let centerIcon = UIImage(named: "create")!
//        let tabBar = WellRoundedTabBarController(centerIcon: centerIcon, screens: screens, initalIndex: 2, disabledTabs: [4])
        let tabBar = WellRoundedTabBarController(centerIcon: centerIcon, screens: screens, initalIndex: 0, disabledTabs: [4])
        window?.rootViewController = tabBar
        globalTabBar = tabBar
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .akLight
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.akDark.withAlphaComponent(.opacity.fullyFaded.rawValue),
                    NSAttributedString.Key.font: UIFont.custom(style: .bold, ofSize: .medium),
                NSAttributedString.Key.kern: 0.7
            ]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.synchronize()
        DatabaseFacade.saveContext()
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
        UserDefaults.standard.synchronize()
        DatabaseFacade.saveContext()
    }
    
    // MARK: - Custom Methods
    
    private func seedIfFirstLaunch(context: NSManagedObjectContext) {
        // If first launch, seed with essentials
        switch UserDefaults.isFirstLaunch() {
        case true:
            // Seed Core data 
            let dataSeeder = DataSeeder(context: context)
            dataSeeder.seedCoreData()
            dataSeeder.seedSkillsWithExercises()
            
            // Show Welcome message
            let modal = CustomAlertView(messageContent: "Welcome to the workout!")
            modal.show(animated: true)
            
            // Seed User Defaults
            if !UserDefaultsFacade.hasInitialDefaults {
                UserDefaultsFacade.seed()
            }
        case false:
            // Update Core Data with any new default values
            DataSeeder(context: context).update()
        }
    }
    
    /// Set custom appearance of textFields flashing indicator, and Navigation bar.
    private func customizeUIAppearance() {
        // TextField Customization
        UITextField.appearance(whenContainedInInstancesOf: [InputViewController.self]).tintColor = .akDark
        UITextField.appearance(whenContainedInInstancesOf: [LiftCell.self]).tintColor = .akDark
        
        // Navigaiton bar customization
        UINavigationBar.appearance().barTintColor = .akDark
        let renderedImage = UIImage.backArrowIcon.withRenderingMode(.alwaysTemplate)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.custom(style: CustomFont.bold, ofSize: FontSize.medium),
            NSAttributedString.Key.kern: 0.7,
        ]
    }
}

