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
        
        view.backgroundColor = .light
        setupDataSource(with: muscle)
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
        addLongPressRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAnyChanges()
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
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
        let wo = dataSource.getData() as? [Workout]
        if let wo = wo {
            let selectedWorkout = wo[indexPath.row]
            let detailedVC = ExerciseTableViewController(withWorkout: selectedWorkout)
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
    
    // Editing and deletion
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
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
    
    private func deleteCell(at indexPath: IndexPath) {
        self.dataSource.deleteDataAt(indexPath)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
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

