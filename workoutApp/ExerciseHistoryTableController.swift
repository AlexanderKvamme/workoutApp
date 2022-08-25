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
        
        styleBackButton()
    }
    
    private func setupTable() {
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        automaticallyAdjustsScrollViewInsets = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .akLight
        
        tableView.reloadData()
    }
    
    // MARK: Helper methods
    
    @objc private func xButtonHandler() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

extension UIViewController {
    func styleBackButton() {
        let btnRefresh = UIBarButtonItem(image: UIImage.chevronLeftSlim17, style: .plain, target: self, action: #selector(pop))
        navigationItem.leftBarButtonItem = btnRefresh
        navigationItem.leftBarButtonItem?.tintColor = .akDark
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
}
