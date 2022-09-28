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

fileprivate var workoutToAutomaticallyEnter: Int? = nil

/// The default workoutTableViewController used in both the history and workout tab
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
        
        setupDataSource()
        setupDelegate()
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
        addLongPressRecognizer()
        
        let btnRefresh = UIBarButtonItem(image: UIImage.chevronLeftSlim17, style: .plain, target: self, action: #selector(pop))
        navigationItem.leftBarButtonItem = btnRefresh
        navigationItem.leftBarButtonItem?.tintColor = .akDark
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        view.backgroundColor = .akLight
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.hideIt()
        animateAnyChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showSelectionIndicator()
        updateTableIfNeeded()
        
        refreshControl?.endRefreshing()
        
        debugEnterWorkout(workoutToAutomaticallyEnter)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetRefreshControlAnimation()
    }
    
    // MARK: - Methods
    
    private func debugEnterWorkout(_ i: Int?) {
        guard let i = i else { return }
        let indexPath = IndexPath(row: i, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    private func addLongPressRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showEditor(_:)))
        view.addGestureRecognizer(longPress)
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
        guard let indexPath = indexPathBeingEdited else { return }
        
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
            shouldUpdateUponAppearing = false // reset
            let indexSet = NSIndexSet(index: 0) as IndexSet
            tableView.reloadSections(indexSet, with: .automatic)
                self.tableView.reloadData()
        }
    }
    
    // MARK: TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("bam did select: ", indexPath)
        // Start a workout
        let wo = dataSource.getData() as? [Workout]
        if let wo = wo {
            let selectedWorkout = wo[indexPath.row]
            let detailedVC = ActiveWorkoutController(withWorkout: selectedWorkout)
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
                tableView.reloadData()
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
            editAction.backgroundColor = .akLight
            indexPathBeingEdited = indexPath
            
            return [editAction]
        }
    }
}


extension UIViewController {
    @objc func pop(){
        navigationController?.popViewController(animated: true)
    }
}
