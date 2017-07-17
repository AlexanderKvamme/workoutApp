//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class WorkoutTableViewDataSource: NSObject, UITableViewDataSource {
    
    let cellIdentifier: String = "BoxCell"
    var workoutStyleName: String!
    
    var fetchedWorkouts = [Workout]()
    
    // MARK: - Initializers
    
    init(workoutStyleName: String) {
        super.init()
        self.workoutStyleName = workoutStyleName
        
        refreshDataSource()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wo = fetchedWorkouts[indexPath.row]
        
        var cell: WorkoutBoxCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutBoxCell
        cell = WorkoutBoxCell(style: .default, reuseIdentifier: cellIdentifier)
        if let name = wo.name {
            cell.box.setTitle(name)
        }
        cell.box.setSubHeader(workoutStyleName)
        return cell
    }
    
    // MARK: - API
    
    func getWorkouts() -> [Workout]? {
        return fetchedWorkouts
    }
    
    func refreshDataSource() {
        let fetchRequest = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
        let workoutStyle = DatabaseFacade.fetchWorkoutStyle(withName: self.workoutStyleName)
        let predicate = NSPredicate(format: "workoutStyle == %@", workoutStyle!)
        fetchRequest.predicate = predicate
        
        // Fetch from Core Data
        do {
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            fetchedWorkouts = results
            print("result from refresh: ", results)
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
}

