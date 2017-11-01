//
//  HistoryTableDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.


import Foundation
import UIKit
import CoreData
import SwipeCellKit

/// Provides data for the Table that displays the history if performed workouts
class WorkoutLogHistoryTableViewDataSource: NSObject, isBoxTableViewDataSource {

    // MARK: - Properties
    
    var cellIdentifier = "HistoryBoxCell"
    var workoutStyleName: String?
    var fetchedWorkoutLogs = [WorkoutLog]()
    
    weak var owner: SwipeTableViewCellDelegate?
    
    // MARK: - Initializers
    
    required init(workoutStyleName: String?) {
        super.init()
        self.workoutStyleName = workoutStyleName
        refresh()
    }
    
    // MARK: - Methods

    // Datasource Protocol requirements
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedWorkoutLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workoutLog = fetchedWorkoutLogs[indexPath.row]
        var cell: WorkoutLogHistoryBoxCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutLogHistoryBoxCell
        cell = WorkoutLogHistoryBoxCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.setupContent(with: workoutLog)
        cell.delegate = owner
        
        return cell
    }
    
    // MARK: - API
    
    
    func getData() -> [NSManagedObject]? {
        let workouts = DatabaseFacade.fetchAllWorkoutLogs()
        return workouts
    }
    
    func getWorkoutLog(at indexPath: IndexPath) -> WorkoutLog {
        let workoutLog = fetchedWorkoutLogs[indexPath.row]
        return workoutLog
    }
    
    func refresh() {
        let fetchRequest = NSFetchRequest<WorkoutLog>(entityName: Entity.WorkoutLog.rawValue)
        // If a specific workoutStyle was injected using initialzation. Use this as a predicate to limit the search
        if let styleName = self.workoutStyleName {
            let workoutStyle = DatabaseFacade.getWorkoutStyle(named: styleName)
            let predicate = NSPredicate(format: "design.workoutStyle == %@", workoutStyle!)
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateEnded", ascending: false)]
        
        // Fetch from Core Data
        do {
            let results = try DatabaseFacade.context.fetch(fetchRequest)
            fetchedWorkoutLogs = results
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func deleteDataAt(_ indexPath: IndexPath) {
        let woToDelete = fetchedWorkoutLogs[indexPath.row]
        fetchedWorkoutLogs.remove(at: indexPath.row)
        DatabaseFacade.deleteWorkoutLog(woToDelete)
    }
}

