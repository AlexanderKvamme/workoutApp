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
    
    let cellIdentifier = "WorkoutBoxCell"
    
    override init(workoutStyleName: String) {
        super.init(workoutStyleName: workoutStyleName)
        self.title = "\(workoutStyleName) workouts".uppercased()
        self.workoutStyleName = workoutStyleName
        
        setUpNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    // viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        // Navbar
        setUpNavigationBar()

        // TableViewSetup
        dataSource.refreshDataSource()
        tableView.reloadData()
    }
    
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(WorkoutBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorInset.left = 0
    }
    
    // MARK: - TableView delegate methods
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wo = dataSource.getData() as? [Workout]
        if let wo = wo {
            let selectedWorkout = wo[indexPath.row]
            let detailedVC = ExerciseTableViewController(withWorkout: selectedWorkout)
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
}

