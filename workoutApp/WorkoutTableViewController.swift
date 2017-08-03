//
//  BoxTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

class WorkoutTableViewController: BoxTableViewController {
    
    // MARK: - Initializers
    
    init(workoutStyleName: String?) {
        super.init(workoutStyleName: workoutStyleName, cellIdentifier: "WorkoutBoxCell")
        tableView.register(WorkoutBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setUpNavigationBar(withTitle: workoutStyleName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
    }
    
    // MARK: - Methods
    
    private func setupDataSource() {
        dataSource = WorkoutTableViewDataSource(workoutStyleName: workoutStyleName)
        tableView.dataSource = dataSource
    }
    
    // MARK: - TableView delegate methods
    
    // Selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wo = dataSource.getData() as? [Workout]
        if let wo = wo {
            let selectedWorkout = wo[indexPath.row]
            let detailedVC = ExerciseTableViewController(withWorkout: selectedWorkout)
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
    
    // Editing and deletion
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "DEL") { (action, indexPath) in
            self.dataSource.deleteDataAt(indexPath)
            self.tableView.reloadData()
        }
        
        delete.backgroundColor = .secondary
        return [delete]
    }
}

