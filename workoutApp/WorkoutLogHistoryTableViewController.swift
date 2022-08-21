//
//  HistoryTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import SwipeCellKit

/// Used to a table of Workouts, latest first, to provide user with an overview of most recent performances
class WorkoutLogHistoryTableViewController: BoxTableViewController, SwipeTableViewCellDelegate {
    
    // MARK: - Properties
    
    var dataSource: isBoxTableViewDataSource!
    
    // MARK: - Initializers
    
    init(workoutStyleName: String?) {
        super.init(workoutStyleName: workoutStyleName, cellIdentifier: "HistoryBoxCell")
        tableView.register(WorkoutLogHistoryBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        setUpNavigationBar(withTitle: self.workoutStyleName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupDataSource()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataSource.refresh()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showSelectionIndicator()
    }
    
    // MARK: - Methods
    
    private func setupDataSource() {
        dataSource = WorkoutLogHistoryTableViewDataSource(workoutStyleName: workoutStyleName)
        tableView.dataSource = dataSource
        dataSource.owner = self
    }
    
    // MARK: - Data source delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetailedView(for: indexPath)
    }
    
    // MARK: SwipeCellKit
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .right: // User swiped right
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
                self.deleteCell(at: indexPath)
                action.fulfill(with: .delete)
            }
            // customize the action appearance
            deleteAction.image = ximage
            deleteAction.backgroundColor = .secondary
            
            return [deleteAction]
        case .left: // User swiped left
            return nil
        }
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        self.dataSource.deleteDataAt(indexPath)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
    
    private func showDetailedView(for indexPath: IndexPath) {
        let newDataSource = dataSource as! WorkoutLogHistoryTableViewDataSource
        let tappedWorkoutLog = newDataSource.getWorkoutLog(at: indexPath)
        let workoutLogTable = ExerciseHistoryTableViewController(withWorkoutLog: tappedWorkoutLog)
        
        navigationController?.pushViewController(workoutLogTable, animated: true)
    }
}

