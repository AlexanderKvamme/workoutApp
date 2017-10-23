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
    var indexPathBeingEdited: IndexPath?
    var shouldUpdateUponAppearing = false
    
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
        setupDelegate()
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
        addLongPressRecognizer()
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAnyChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showSelectionIndicator()
        updateTableIfNeeded()
        
        refreshControl?.endRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetRefreshControlAnimation()
    }
    
    // MARK: - Methods
    
    private func addLongPressRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showEditor(_:)))
        view.addGestureRecognizer(longPress)
    }
    
    @objc private func showEditor(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self.view)
            if let indexPathToEdit = tableView.indexPathForRow(at: location) {
                indexPathBeingEdited = indexPathToEdit
                let workoutToEdit = dataSource.getWorkout(at: indexPathToEdit)
                let editor = WorkoutEditor(with: workoutToEdit)
                navigationController?.pushViewController(editor, animated: Constant.Animation.pickerVCsShouldAnimateIn)
            }
        default:
            return
        }
    }
    
    private func setupDataSource() {
        dataSource = WorkoutTableViewDataSource(workoutStyleName: workoutStyleName)
        dataSource.owner = self

        tableView.dataSource = dataSource
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
    }
    
    private func setupDelegate() {
        tableView.delegate = self
    }
    
    private func animateAnyChanges() {
        if let indexPath = indexPathBeingEdited {
            // Pre-animation
            tableView.cellForRow(at: indexPath)?.alpha = 0
            tableView.cellForRow(at: indexPath)?.layoutIfNeeded()
            
            // Animate with completion>
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.indexPathBeingEdited = nil
            })
            self.tableView.reloadRows(at: [indexPath], with: .left)
            CATransaction.commit()
        }
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        self.dataSource.deleteDataAt(indexPath)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
    
    // Update table only if new workouts are added
    private func updateTableIfNeeded() {

        guard let dataCountPreUpdate = dataSource?.getData()?.count else { return }
        
        dataSource.refresh()
        
        guard let dataCountPostUpdate = dataSource?.getData()?.count else { return }
        if dataCountPreUpdate != dataCountPostUpdate || shouldUpdateUponAppearing {

            shouldUpdateUponAppearing = false // resetp
            
            let indexSet = NSIndexSet(index: 0) as IndexSet
            tableView.reloadSections(indexSet, with: .automatic)
                self.tableView.reloadData()
        }
    }
    
    // MARK: TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wo = dataSource.getData() as? [Workout]
        if let wo = wo {
            let selectedWorkout = wo[indexPath.row]
            let detailedVC = ExerciseTableViewController(withWorkout: selectedWorkout)
            detailedVC.presentingBoxTable = self
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
    
    // Editing and deletion
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
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
            let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                let wo = self.dataSource.getWorkout(at: indexPath)
                let workoutEditor = WorkoutEditor(with: wo)
                self.navigationController?.pushViewController(workoutEditor, animated: Constant.Animation.pickerVCsShouldAnimateIn)
            }
            editAction.image = self.wrenchImage
            editAction.backgroundColor = .light
            indexPathBeingEdited = indexPath
            
            return [editAction]
        }
    }
}

