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
        
        // Visuals
        tableView.backgroundColor = .light
        setupNavigationBar()
        
        // Table view setup
        dataSource = ExerciseTableViewDataSource(workout: currentWorkout)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "exerciseCell")
        
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        
        //        setDebugColors()
    }
    
    // MARK: - Initializers
    
    init(withWorkout workout: Workout) {
        super.init(nibName: nil, bundle: nil)
        self.currentWorkout = workout
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navbar
    
    private func setupNavigationBar() {
        if let name = currentWorkout.name {
            self.title = name.uppercased()
        } else {
            self.title = "test"
        }
        let navButtonRight = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: navButtonRight, style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - Delegate methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let verticalSpacingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        return verticalSpacingView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped \(indexPath)")
        print("- \(dataSource.currentExercises[indexPath.section].name)")
    }
    
    // Helper
    
    func setDebugColors() {
        view.backgroundColor = .green
    }
}
