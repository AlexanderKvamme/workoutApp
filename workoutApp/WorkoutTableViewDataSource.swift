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

/// Provides data to the workoutTable used in both the history and Workout tabs.
class WorkoutTableViewDataSource: NSObject, isWorkoutTableViewDataSource {

    // MARK: - Properties
    
    var cellIdentifier = "WorkoutBoxCell"
    var workoutStyleName: String?
    var lastUpdatedAt: Date!
    var fetchedWorkouts = [Workout]()
    weak var owner: SwipeTableViewCellDelegate?
    
    // MARK: - Initializers
    
    required init(workoutStyleName: String?) {
        super.init()
        self.workoutStyleName = workoutStyleName

        refresh()
    }
    
    // MARK: - Methods
    // MARK: dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = fetchedWorkouts[indexPath.row]
        var cell: WorkoutBoxCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutBoxCell
        cell = WorkoutBoxCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.accessibilityIdentifier = workout.getName()
        cell.setupContent(withWorkout: workout)
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
        lastUpdatedAt = Date()
    }
    
    func refresh() {
        let fetchRequest = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
        let workoutStyle = DatabaseFacade.fetchWorkoutStyle(withName: self.workoutStyleName!)
        let predicate = NSPredicate(format: "workoutStyle == %@", workoutStyle!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latestPerformence.dateEnded", ascending: false)]
        fetchRequest.predicate = predicate
        lastUpdatedAt = Date()
        
        // Fetch from Core Data
        do {
            let results = try DatabaseFacade.context.fetch(fetchRequest)
            fetchedWorkouts = results
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
}

