//
//  ExerciseTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ExerciseTableViewController: UITableViewController {

    var currentWorkout: Workout! // The workout that contains the exercises this tableVC is displaying
    var dataSource: ExerciseTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDebugColors()
        
        // Table view setup
        dataSource = ExerciseTableViewDataSource(workout: currentWorkout)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "exerciseCell")
        
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }
    
    // MARK: - Initializers
    
    init(withWorkout workout: Workout) {
        super.init(nibName: nil, bundle: nil)
        self.currentWorkout = workout
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row \(indexPath.row)")
    }
    
    // Helper
    
    func setDebugColors() {
        view.backgroundColor = .green
    }
}

