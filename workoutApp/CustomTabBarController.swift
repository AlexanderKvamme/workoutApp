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

        // Tabs of the tab bar
        let progressController = SelectionViewController(
            header: SelectionViewHeader(header: "Which kind of", subheader: "Progress?"),
            buttons: [SelectionViewButton(header: "Statistics", subheader: "Workout History"),
                      SelectionViewButton(header: "Workout History", subheader: "292 Workouts")
            ])
        let historyController = SelectionViewController(
            header: SelectionViewHeader(header: "History", subheader: "Of which style?"),
            buttons: [SelectionViewButton(header: "Normal", subheader: "9 Workouts"),
                      SelectionViewButton(header: "Pyramid", subheader: "4 Workouts"),
                      SelectionViewButton(header: "Drop set", subheader: "3 Workouts"),
                      SelectionViewButton(header: "Cardio", subheader: "2 Workouts"),
            ])
        
        // MARK: - Workout Tab
        
        let workoutRequest = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
        workoutRequest.resultType = .managedObjectResultType
        workoutRequest.propertiesToFetch = ["type"]
        
        var workoutTypes = [String]()
        
        do {
            let results = try DatabaseController.getContext().fetch(workoutRequest)
            // Append all received types
            for r in results {
                if let type = r.type {
                    workoutTypes.append(type)
                }
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        // make buttons from unique workout names
        
        var workoutButtons = [SelectionViewButton]()
        let uniqueWorkoutTypes = Set(workoutTypes)
        
        for type in uniqueWorkoutTypes {
            workoutButtons.append(
                SelectionViewButton(
                    header: type,
                    subheader: "\(DatabaseFacade.countWorkoutsOfType(ofType: type)) exercises"))
        }
        
        let workoutController = SelectionViewController(
            header: SelectionViewHeader(header: "Which kind of?", subheader: "Workout"),
            buttons: workoutButtons)
        
        // MARK: - Profile Tab
        
        let profileController = TestViewController()
        
        // MARK: - Set up navbar
        
        viewControllers = [progressController, historyController, workoutController, profileController]
        
        progressController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "progress"), tag: 0)
        historyController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "history"), tag: 1)
        workoutController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "workout"), tag: 2)
        profileController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), tag: 3)

        let tabBarItems = tabBar.items! as [UITabBarItem]
        for item in tabBarItems {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        tabBar.tintColor = UIColor.lightest
        tabBar.unselectedItemTintColor = UIColor.light
        tabBar.barTintColor = UIColor.darkest
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
