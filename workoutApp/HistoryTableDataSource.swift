//
//  HistoryTableDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.


import Foundation
import UIKit
import CoreData


class HistoryTableViewDataSource: NSObject, isBoxTableViewDataSource {
    
    // MARK: - Properties
    
    var cellIdentifier = "HistoryBoxCell"
    var workoutStyleName: String?
    var fetchedWorkoutLogs = [WorkoutLog]()
    
    // MARK: - Initializers
    
    required init(workoutStyleName: String?) {
        super.init()
        self.workoutStyleName = workoutStyleName
        
        refreshDataSource()
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
        let log = fetchedWorkoutLogs[indexPath.row]
        
        var cell: HistoryBoxCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryBoxCell
        cell = HistoryBoxCell(style: .default, reuseIdentifier: cellIdentifier)
        if let name = log.design?.name {
            cell.box.setTitle(name)
        }
        
        // Subheader (top right)
        if let workoutStyleName = log.design?.workoutStyle?.name {
            cell.box.setSubHeader(workoutStyleName)
        } else {
            cell.box.setSubHeader("NA")
        }
        
        // Stack: Total
        let liftCount = log.getLiftCount()
        cell.box.content?.contentStack?.firstStack.setBottomText(String(liftCount))
        
        // Stack: Time
        if let endTime = log.dateEnded as Date?, let startTime = log.dateStarted as Date? {
            let differenceInSeconds = endTime.timeIntervalSince(startTime)
            let differenceInMinutes = Int(differenceInSeconds/60)
            cell.box.content?.contentStack?.secondStack.setBottomText(String(differenceInMinutes) + "M")
        } else {
            cell.box.content?.contentStack?.secondStack.setBottomText("NA")
        }
        
        // Stack: PRS
        cell.box.content?.contentStack?.thirdStack.setBottomText("NA")
        
        return cell
    }
    
    // MARK: - API
    
    func refreshDataSource() {
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
    
    // FIXME: - delete from data source
    func deleteDataAt(_ indexPath: IndexPath) {
        print("*In data source. Will now delete the actual workoutLog*".uppercased())
        let woToDelete = fetchedWorkoutLogs[indexPath.row]
        fetchedWorkoutLogs.remove(at: indexPath.row)
        DatabaseFacade.deleteWorkoutLog(woToDelete) // FIXME: - implement
        print(" would delete: ", woToDelete.design?.name)
    }
}

