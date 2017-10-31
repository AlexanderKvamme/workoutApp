//
//  MuscleBasedWorkoutTableDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwipeCellKit

class MuscleBasedWorkoutTableViewDataSource: NSObject, isWorkoutTableViewDataSource {
    
    // MARK: - Properties
    
    var cellIdentifier = "WorkoutBoxCell"
    var workoutStyleName: String?
    var muscle: Muscle!
    var lastUpdatedAt: Date!
    var fetchedWorkouts = [Workout]()
    weak var owner: SwipeTableViewCellDelegate?
    
    // MARK: - Initializers
    
    required init(muscle: Muscle) {
        super.init()
        self.muscle = muscle
        
        refresh()
    }
    
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
        let predicate = NSPredicate(format: "musclesUsed CONTAINS %@", muscle)
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

