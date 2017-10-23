//
//  ExerciseHistoryTableView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class ExerciseHistoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var activeTableCell: ExerciseCellBaseClass? // used by cell to make correct collectionView.label firstResponder
    private var currentWorkoutLog: WorkoutLog! // The workoutLog that contains the exercises this tableVC is displaying
    private var dataSource: ExerciseHistoryTableDataSource!
    private var myWorkoutLog: WorkoutLog! // used in the end
    private var exercisesToLog: [ExerciseLog]! // make an array of ExerciseLogs, and every time a tableViewCell.liftsToDisplay is updated, add it to here
    
    // cells reordering
    private var snapShot: UIView?
    private var location: CGPoint!
    private var sourceIndexPath: IndexPath!
    
    // MARK: - Initializers
    
    init(withWorkoutLog workoutLog: WorkoutLog) {
        super.init(nibName: nil, bundle: nil)
        self.currentWorkoutLog = workoutLog
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = ExerciseHistoryTableDataSource(workoutLog: currentWorkoutLog)
        tableView.dataSource = dataSource
        dataSource.owner = self
        tableView.delegate = self
        tableView.register(ExerciseCellForHistory.self, forCellReuseIdentifier: "exerciseHistoryCell")
        
        setupTable()    
    }
    
    // MARK: - Methods
    
    // MARK: setup methods
    
    private func setupNavigationBar() {
        if let name = currentWorkoutLog.design?.name {
            self.title = name.uppercased()
        }
        
        let xIcon = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: xIcon, style: .done, target: self, action: #selector(xButtonHandler))
        self.navigationItem.rightBarButtonItem = rightButton
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
    }
    
    private func setupTable() {
        // adjust to fit the navbar
        if let navHeight = navigationController?.navigationBar.frame.height {
            let statusHeight = UIApplication.shared.statusBarFrame.height
            tableView.contentInset = UIEdgeInsets(top: navHeight + statusHeight, left: 0, bottom: 0, right: 0)
            tableView.headerView(forSection: 0)?.backgroundColor = .red
            tableView.tableHeaderView?.backgroundColor = .green
        }
        
        // tableview setup
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        automaticallyAdjustsScrollViewInsets = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .light
        
        tableView.reloadData()
    }
    
    // MARK: Helper methods
    
    @objc private func xButtonHandler() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

