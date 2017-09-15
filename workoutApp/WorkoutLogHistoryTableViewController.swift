//
//  HistoryTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit


class WorkoutLogHistoryTableViewController: BoxTableViewController {
    
    // MARK: - Initializers
    
    init(workoutStyleName: String?) {
        super.init(workoutStyleName: workoutStyleName, cellIdentifier: "HistoryBoxCell")
//        tableView.register(HistoryBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(WorkoutLogHistoryBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        setUpNavigationBar(withTitle: self.workoutStyleName)
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
//        dataSource = HistoryTable
        dataSource = WorkoutLogHistoryTableViewDataSource(workoutStyleName: workoutStyleName)
//        dataSource = HistoryTableViewDataSource(workoutStyleName: workoutStyleName)
        tableView.dataSource = dataSource
    }
    
    // Delete rows
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "DELETE") { (action, indexPath) in
            self.dataSource.deleteDataAt(indexPath)
            self.tableView.reloadData() // Add animation through tableView.deleteRows(at: [indexPath], with: .none)
        }
        delete.backgroundColor = UIColor.secondary
        return [delete]
    }
    
    // FIXME: - tappable cells
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //let newDataSource = dataSource as! HistoryTableViewDataSource
        let newDataSource = dataSource as! WorkoutLogHistoryTableViewDataSource
        let tappedWorkoutLog = newDataSource.getWorkoutLog(at: indexPath)
            
        let workoutLogTable = ExerciseHistoryTableViewController(withWorkoutLog: tappedWorkoutLog)
        navigationController?.pushViewController(workoutLogTable, animated: true)
    }
    
    
}

