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
    var coreDataManager: CoreDataManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Seed if contaning commandLine arguments
        if CommandLine.arguments.contains("--fastlaneSnapshot") {
            let inMemoryContext = setUpInMemoryManagedObjectContext()
            coreDataManager = CoreDataManager(providedContext: inMemoryContext)
            let coreDataSeeder = DataSeeder(coreDataManager: coreDataManager!)
            coreDataSeeder.seedCoreDataForFastlaneSnapshots()
        } else if CommandLine.arguments.contains("ACTIVE_WORKOUT_UITESTS") {
            let inMemoryContext = setUpInMemoryManagedObjectContext()
            coreDataManager = CoreDataManager(providedContext: inMemoryContext)
            let coreDataSeeder = DataSeeder(coreDataManager: coreDataManager!)
            coreDataSeeder.makeLongWorkout(coreDataManager: coreDataManager!)
        } else {
            // No arguments, so use context from devices persistent store
            coreDataManager = CoreDataManager()
        }
        // Seed with initial muscles .etc
        seedIfFirstLaunch(coreDataManager: coreDataManager!)
        
        customizeUIAppearance()
        
        // Instantiate master View Controller
        window?.rootViewController = CustomTabBarController(nibName: nil, bundle: nil, coreDataManager: coreDataManager!)
        
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
        coreDataManager!.saveContext()
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
        coreDataManager!.saveContext()
    }
    
    // MARK: - Custom Methods
    
    private func seedIfFirstLaunch(coreDataManager: CoreDataManager) {
        // If first launch, seed with essentials
        switch UserDefaults.isFirstLaunch() {
        case true:
            // Seed Core data with requirements like Muscles, Styles, .etc
            let dataSeeder = DataSeeder(coreDataManager: coreDataManager)
            dataSeeder.seedCoreData()
            
            // Show Welcome message
            let modal = CustomAlertView(type: .message, messageContent: "Welcome to the workout!")
            modal.show(animated: true)
            
            // Seed User Defaults
            if !UserDefaultsFacade.hasInitialDefaults {
                UserDefaultsFacade.seed()
            }
        case false:
            // Update Core Data with any new default values
            DataSeeder(coreDataManager: coreDataManager).update()
        }
    }
    
    /// Set custom appearance of textFields flashing indicator, and Navigation bar.
    private func customizeUIAppearance() {
        customizeTextField()
        customizeNavbar()
    }
    
    private func customizeNavbar() {
        // Navigaiton bar customization
        UINavigationBar.appearance().barTintColor = UIColor.light
        let renderedImage = UIImage.backArrowIcon.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.custom(style: CustomFont.bold, ofSize: FontSize.medium),
            NSAttributedStringKey.foregroundColor: UIColor.faded,
            NSAttributedStringKey.kern: 0.7,
        ]
        
        // remove shadow
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    private func customizeTextField() {
        UITextField.appearance(whenContainedInInstancesOf: [InputViewController.self]).tintColor = .darkest
        UITextField.appearance(whenContainedInInstancesOf: [LiftCell.self]).tintColor = .darkest
    }
}
 
