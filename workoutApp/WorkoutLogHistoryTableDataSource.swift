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

class WorkoutLogHistoryTableViewDataSource: NSObject, isBoxTableViewDataSource {

    weak var owner: SwipeTableViewCellDelegate? //the delegate must have reference from dataSource
    
    // MARK: - Properties
    
    var cellIdentifier = "HistoryBoxCell"
    var workoutStyleName: String?
    var fetchedWorkoutLogs = [WorkoutLog]()
    
    // MARK: - Initializers
    
    required init(workoutStyleName: String?) {
        super.init()
        self.workoutStyleName = workoutStyleName
        
        refresh()
    }
    
    // MARK: - Datasource Protocol requirements
    
    func getData() -> [NSManagedObject]? {
        let workouts = DatabaseFacade.fetchAllWorkoutLogs()
        return workouts
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedWorkoutLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workoutLog = fetchedWorkoutLogs[indexPath.row]
        var cell: WorkoutLogHistoryBoxCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutLogHistoryBoxCell
        cell = WorkoutLogHistoryBoxCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.setupContent(with: workoutLog)
        
        
        return cell
    }
    
    // MARK: - API
    
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
        
        do {
            // Fetch from Core Data
            let results = try DatabaseFacade.context.fetch(fetchRequest)
            fetchedWorkoutLogs = results
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func deleteDataAt(_ indexPath: IndexPath) {
        let woToDelete = fetchedWorkoutLogs[indexPath.row]
        fetchedWorkoutLogs.remove(at: indexPath.row)
        DatabaseFacade.deleteWorkoutLog(woToDelete)
    }
}

