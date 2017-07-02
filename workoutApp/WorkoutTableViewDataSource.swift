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
    var workoutStyle: String!
    
    var fetchedWorkouts = [Workout]()
    
    // MARK: - Initializers
    
    init(workoutStyle: String) {
        super.init()
        self.workoutStyle = workoutStyle
        
        let fetchRequest = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
        let predicate = NSPredicate(format: "type = %@", workoutStyle)
        fetchRequest.predicate = predicate
        
        // Fetch from Core Data
        do {
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            fetchedWorkouts = results
         
        } catch let err as NSError {
            print(err.debugDescription)
        }
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
        cell.box.setSubHeader(workoutStyle)
        return cell
    }
    
    // MARK: - API
    
    func getWorkouts() -> [Workout]? {
        return fetchedWorkouts
    }
}

