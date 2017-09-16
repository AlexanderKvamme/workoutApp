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
import SwipeCellKit

class WorkoutTableViewDataSource: NSObject, isWorkoutTableViewDataSource {
    
    // MARK: - Properties
    
    var cellIdentifier = "WorkoutBoxCell"
    var workoutStyleName: String?
    var fetchedWorkouts = [Workout]()
    weak var owner: SwipeTableViewCellDelegate?
    
    // MARK: - Initializers
    
    required init(workoutStyleName: String?) {
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
        if let workoutStyleName = workoutStyleName {
            cell.box.setSubHeader(workoutStyleName)
        }
        cell.delegate = owner
        return cell
    }
    
    // MARK: - API
    
    func getData() -> [NSManagedObject]? {
        return fetchedWorkouts
    }
    
    func getWorkout(at indexPath: IndexPath) -> Workout {
        return fetchedWorkouts[indexPath.row]
    }
    
    func deleteDataAt(_ indexPath: IndexPath) {
        let workoutToDelete = fetchedWorkouts[indexPath.row]
        fetchedWorkouts.remove(at: indexPath.row)
        DatabaseFacade.deleteWorkout(workoutToDelete)
    }
    
    func refreshDataSource() {
        let fetchRequest = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
        let workoutStyle = DatabaseFacade.fetchWorkoutStyle(withName: self.workoutStyleName!) // FIXME: BANG
        let predicate = NSPredicate(format: "workoutStyle == %@", workoutStyle!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latestPerformence.dateEnded", ascending: false)]
        fetchRequest.predicate = predicate
        
        do {
            // Fetch from Core Data
            let results = try DatabaseFacade.context.fetch(fetchRequest)
            fetchedWorkouts = results
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
}

