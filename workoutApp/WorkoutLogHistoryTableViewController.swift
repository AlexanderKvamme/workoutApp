//
//  HistoryTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import SwipeCellKit


class WorkoutLogHistoryTableViewController: BoxTableViewController, SwipeTableViewCellDelegate {
    
    // MARK: - Initializers
    
    var dataSource: isBoxTableViewDataSource!
    
    init(workoutStyleName: String?) {
        super.init(workoutStyleName: workoutStyleName, cellIdentifier: "HistoryBoxCell")
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
        
        view.backgroundColor = .light
        
        setupDataSource()
        setupTableView()
//        setupRefreshControl()
//        resetRefreshControlAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataSource.refresh()
        self.tableView.reloadData()
    }
    
    // MARK: - Methods
    
    private func setupDataSource() {
        dataSource = WorkoutLogHistoryTableViewDataSource(workoutStyleName: workoutStyleName)
        tableView.dataSource = dataSource
        dataSource.owner = self
    }
    
    // Delete rows
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let newDataSource = dataSource as! HistoryTableViewDataSource
        let newDataSource = dataSource as! WorkoutLogHistoryTableViewDataSource
        let tappedWorkoutLog = newDataSource.getWorkoutLog(at: indexPath)
        
        let workoutLogTable = ExerciseHistoryTableViewController(withWorkoutLog: tappedWorkoutLog)
        navigationController?.pushViewController(workoutLogTable, animated: true)
    }

//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .destructive, title: "DELETE") { (action, indexPath) in
//            self.dataSource.deleteDataAt(indexPath)
//            self.tableView.reloadData() // Add animation through tableView.deleteRows(at: [indexPath], with: .none)
//        }
//        delete.backgroundColor = UIColor.secondary
//        return [delete]
//    }
    
    // MARK: SwipeCellKit
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        print("editActions")
        
        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
                action.fulfill(with: .delete)
                self.deleteCell(at: indexPath)
            }
            
            // customize the action appearance
            deleteAction.image = ximage
            deleteAction.backgroundColor = .secondary
            
            return [deleteAction]
        case .left: // user swiped left
            return nil
//            let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
//                let wo = self.dataSource.getWorkout(at: indexPath)
//                let workoutEditor = WorkoutEditor(with: wo)
//                self.navigationController?.pushViewController(workoutEditor, animated: Constant.Animation.pickerVCsShouldAnimateIn)
//            }
//            editAction.image = self.wrenchImage
//            editAction.backgroundColor = .light
//            indexPathBeingEdited = indexPath
//
//            return [editAction]
        }
    }
        
    private func deleteCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        self.dataSource.deleteDataAt(indexPath)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
        
}

