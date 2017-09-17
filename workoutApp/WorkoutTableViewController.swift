//
//  BoxTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class WorkoutTableViewController: BoxTableViewController, SwipeTableViewCellDelegate {
    
    // MARK: - Properties
    
    var dataSource: isWorkoutTableViewDataSource!
    
    lazy var wrenchImage: UIImage = {
        let wrench = UIImage(named: "wrench")!
        let test = wrench.resize(maxWidthHeight: 36)!
        return test
    }()
    
    lazy var ximage: UIImage = {
        let img = UIImage(named: "xmark")!
        return img
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        setupDataSource()
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show SelectionIndicator over tab bar
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.showSelectionindicator()
        }
        
        // Update views
        refreshControl?.endRefreshing()
        dataSource.refreshDataSource()
        tableView.reloadData()
    }
    
    // MARK: - Methods
    
    private func setupDataSource() {
        dataSource = WorkoutTableViewDataSource(workoutStyleName: workoutStyleName)
        dataSource.owner = self
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
    
    // Left swipe
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
                self.dataSource.deleteDataAt(indexPath)
                self.tableView.reloadData()
            }
            
            // customize the action appearance
            deleteAction.image = ximage
            deleteAction.backgroundColor = .secondary
            
            return [deleteAction]
        default: // user swiped left
            let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                let wo = self.dataSource.getWorkout(at: indexPath)
                let workoutEditor = WorkoutEditor(with: wo)
                self.navigationController?.pushViewController(workoutEditor, animated: Constant.Animation.pickerVCsShouldAnimateIn)
            }
            
            editAction.image = self.wrenchImage
            editAction.backgroundColor = .light
            
            return [editAction]
        }
    }
}

