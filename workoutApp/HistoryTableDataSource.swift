//
//  HistoryTableDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//


import Foundation
import UIKit
import CoreData


class HistoryTableViewDataSource: NSObject, isBoxTableViewDataSource {
    
    var cellIdentifier: String!
    var workoutStyleName: String?
    var fetchedWorkoutLogs = [WorkoutLog]()
    
    // MARK: - Initializers
    
    override init() {
        print("nil provided, instatiating all")
    }
    
    required init(workoutStyleName: String?) {
        super.init()
        self.workoutStyleName = workoutStyleName
        self.cellIdentifier = "HistoryBoxCell"
        
        refreshDataSource()
    }
    
    // MARK: - Protocol requirements
    
    func getData() -> [NSManagedObject]? {
        let wo = DatabaseFacade.fetchAllWorkoutLogs()
        return wo
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
        
        // FIXME: - Set the remaining of the box
        
        // Subheader (top right)
        if let workoutStyleName = log.design?.workoutStyle?.name {
            cell.box.setSubHeader(workoutStyleName)
        } else {
            cell.box.setSubHeader("Test")
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
            cell.box.content?.contentStack?.secondStack.setBottomText("?")
        }
        
        // Stack: PRS
        cell.box.content?.contentStack?.thirdStack.setBottomText("X")
        
        return cell
    }
    
    // MARK: - API
    
    func refreshDataSource() {
        print("refreshing data source for HISTORY")
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
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            fetchedWorkoutLogs = results
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
}

