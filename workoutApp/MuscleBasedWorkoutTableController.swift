//
//  MuscleBasedWorkoutTable.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

/// Lets a suggestionbox display a table of all workouts matching its suggested Muscle
class MuscleBasedWorkoutTableController: BoxTableViewController, SwipeTableViewCellDelegate {
    
    // MARK: - Properties
    
    var dataSource: isWorkoutTableViewDataSource!
    var indexPathBeingEdited: IndexPath?
    var muscle: Muscle!
    
    // MARK: - Initializers
    
    init(muscle: Muscle) {
        self.muscle = muscle
        super.init(workoutStyleName: nil, cellIdentifier: "WorkoutBoxCell")
        
        tableView.register(WorkoutBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setUpNavigationBar(withTitle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .akLight
        setupDataSource(with: muscle)
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
        addLongPressRecognizer()
        
        if dataSource.getDataCount() == 0 {
            let alert = CustomAlertView(messageContent: "Go make a workout that contains \(self.muscle.getName())!")
            alert.show(animated: true)
        }
        
        styleBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAnyChanges()
        
        globalTabBar.showIt()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showSelectionIndicator()
        updateTableIfNeeded()
        
        // Update views
        refreshControl?.endRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetRefreshControlAnimation()
    }
    
    // MARK: - Methods
    
    override func setUpNavigationBar(withTitle title: String?) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.title = muscle.getName()
        refreshControl?.endRefreshing()
        removeBackButton()
    }
    
    private func addLongPressRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showEditor(_:)))
        view.addGestureRecognizer(longPress)
    }

    private func setupDataSource(with muscle: Muscle) {
        dataSource = MuscleBasedWorkoutTableViewDataSource(muscle: muscle)
        dataSource.owner = self
        
        tableView.dataSource = dataSource
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let workout = dataSource.getData() as? [Workout] else { return }
        
        let selectedWorkout = workout[indexPath.row]
        let detailedVC = ActiveWorkoutController(withWorkout: selectedWorkout) 
        navigationController?.pushViewController(detailedVC, animated: true)
    }
    
    // Editing and deletion
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .right: // User swiped right
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
                self.deleteCell(at: indexPath)
            }
            // Customize the action appearance
            deleteAction.image = ximage
            deleteAction.backgroundColor = .secondary
            
            return [deleteAction]
        case .left: // user swiped left
            let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                let workout = self.dataSource.getWorkout(at: indexPath)
                let workoutEditor = WorkoutEditor(with: workout)
                self.navigationController?.pushViewController(workoutEditor, animated: Constant.Animation.pickerVCsShouldAnimateIn)
            }
            editAction.image = self.wrenchImage
            editAction.backgroundColor = .akLight
            indexPathBeingEdited = indexPath
            
            return [editAction]
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
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
    
    @objc private func showEditor(_ gesture: UIGestureRecognizer) {
        
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: self.view)
        
        if let indexPathToEdit = tableView.indexPathForRow(at: location) {
            indexPathBeingEdited = indexPathToEdit
            let workoutToEdit = dataSource.getWorkout(at: indexPathToEdit)
            let editor = WorkoutEditor(with: workoutToEdit)
            navigationController?.pushViewController(editor, animated: Constant.Animation.pickerVCsShouldAnimateIn)
        }
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        self.dataSource.deleteDataAt(indexPath)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
    
    // Update table only if new workouts are added
    private func updateTableIfNeeded() {
        guard let dataCountPreUpdate = dataSource?.getData()?.count else { return }
        
        dataSource.refresh()
        
        guard let dataCountPostUpdate = dataSource?.getData()?.count else { return }
        if dataCountPreUpdate != dataCountPostUpdate {
            tableView.reloadData()
        }
    }
}

