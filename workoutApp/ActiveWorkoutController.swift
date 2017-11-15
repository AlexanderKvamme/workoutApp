//
//  ExerciseTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/// This TableView is the actual workout when the user is working out
class ActiveWorkoutController: UITableViewController {
    
    // MARK: - Properties
    
    var activeTableCell: UITableViewCell? // used by cell to make correct collectionView.label firstResponder
    private var currentWorkout: Workout! // The workout that contains the exercises this tableVC is displaying
    private var dataSource: ExerciseTableDataSource!
    private var myWorkoutLog: WorkoutLog! // used in the end
    private var exercisesToLog: [ExerciseLog]! // make an array of ExerciseLogs, and every time a tableViewCell.liftsToDisplay is updated, add it to here
    // cells reorder
    private var snapShot: UIView?
    private var location: CGPoint!
    private var sourceIndexPath: IndexPath!
    
    
    weak var presentingBoxTable: WorkoutTableViewController?
    
    // MARK: - Initializers
    
    init(withWorkout workout: Workout) {
        super.init(nibName: nil, bundle: nil)
        self.currentWorkout = workout
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        setupNavigationBar()
        enableSwipeBackGesture(false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        dataSource = ExerciseTableDataSource(workout: currentWorkout) // Make datasource out of the provided Workout
        tableView.dataSource = dataSource
        dataSource.owner = self
        
        // Delegate setup
        tableView.delegate = self
        tableView.register(ExerciseCellForWorkouts.self, forCellReuseIdentifier: "exerciseCell")
        
        setupTable()
        
        // Long press recognizer
        let longPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        enableSwipeBackGesture(false)
    }
    
    // MARK: - Methods
    
    // MARK: setup methods
    
    private func enableSwipeBackGesture(_ b: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = b
    }
    
    private func setupNavigationBar() {
        if let name = currentWorkout.name {
            self.title = name.uppercased()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Right navBar button
        let xIcon = UIImage.xmarkIcon.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: xIcon, style: .done, target: self, action: #selector(xButtonHandler))
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.navigationItem.hidesBackButton = true
    }
    
    private func setupTable() {
        // tableview setup
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        automaticallyAdjustsScrollViewInsets = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .light
        
        setupTableFooter()
        tableView.reloadData()
    }
    
    private func setupTableFooter() {
        let footerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let footer = ExerciseTableFooter(frame: footerFrame)
        footer.saveButton.accessibilityIdentifier = "footer-save-button"
        footer.saveButton.addTarget(self, action: #selector(saveButtonHandler), for: .touchUpInside)
        
        footer.backgroundColor = .dark
        view.backgroundColor = .dark
        tableView.tableFooterView = footer
    }
    
    // MARK: Helper methods
    
    private func customSnapShotFromView(_ inputView: UIView) -> UIImageView {
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
    
    // MARK: Handlers
    
    @objc private func saveButtonHandler() {
        dataSource.saveWorkoutLog()
        presentingBoxTable?.shouldUpdateUponAppearing = true
    }
    
    @objc private func xButtonHandler() {
        dataSource.deleteAssosciatedLiftsExerciseLogsAndWorkoutLogs()
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    /// Handles the long press by 'lifting' the target cell and letting the user move it around
    @objc private func longPressRecognized( _ sender: UIGestureRecognizer) {
        
        var allowedToHideCell = true
        
        switch sender.state {
            
        case .began:
            location = sender.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: location) else { return }
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            sourceIndexPath = indexPath
            
            // get snapshot, add it as a subview of the tableView and center it at cell's center
            snapShot = customSnapShotFromView(cell)
            
            var center = CGPoint(x: cell.center.x, y: cell.center.y)
            snapShot?.center = center
            snapShot?.alpha = 0.0
            tableView.addSubview(snapShot!)
            
            UIView.animate(withDuration: 0.25, animations: { 
                // Offset for gesture location.
                center.y = self.location.y
                self.snapShot?.center = center
                self.snapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.snapShot?.alpha = 0.98
                
                cell.alpha = 0.0
                
            }, completion: { finished in
                if finished && allowedToHideCell {
                    cell.isHidden = true
                }
            })
            
        case .changed:
            guard let indexPath = tableView.indexPathForRow(at: location) else { return }
            guard let sourceIndexPathTemp = sourceIndexPath else { return }
            guard let snapShot = snapShot else { return }
            
            location = sender.location(in: tableView)
            var center = snapShot.center
            center.y = location.y
            snapShot.center = center
            
            // Is destination valid and is it different from source?
            if indexPath != sourceIndexPathTemp {
                dataSource.swapElementsAtIndex(indexPath, withObjectAtIndex: sourceIndexPathTemp) // swap elements in datasource
                tableView.moveSection(sourceIndexPathTemp.section, toSection: indexPath.section) // swap cells in tableView
                sourceIndexPath = indexPath// update source so it is in sync with UI changes.
            }
            
        default:
            // end Animation and stop moving
            guard let sourceIndexPathTmp = sourceIndexPath else { return }
            guard let cell = tableView.cellForRow(at: sourceIndexPathTmp) else { return }
            
            cell.isHidden = false
            cell.alpha = 0.0
            
            allowedToHideCell = false
            
            UIView.animate(withDuration: 0.25, animations: {
                self.snapShot?.center = cell.center
                self.snapShot?.transform = .identity
                self.snapShot?.alpha = 0.0
                
                cell.alpha = 1.0
            }, completion: { _ in
                self.sourceIndexPath = nil
                self.snapShot?.removeFromSuperview()
                self.snapShot = nil
            })
        }
    }
    
    // MARK: Observers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHandler), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideHandler), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShowHandler(notification: NSNotification) {
        // Make sure you received a userInfo dict
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        if let keyboardRect = keyboardRect {
            // Adjust tableViews insets
            let keyboardHeight = keyboardRect.height
            let insetsFromNavbar = tableView.contentInset.top
            let insetsForTableView = UIEdgeInsets(top: insetsFromNavbar,left: 0,bottom: keyboardHeight, right: 0)
            
            tableView.contentInset = insetsForTableView
            tableView.scrollIndicatorInsets = insetsForTableView
            
            // The visible part of tableView, not hidden by keyboard
            var visibleRect = self.view.frame
            visibleRect.size.height -= keyboardHeight
            
            // scroll to the tapped cell
            if let rectToBeDisplayed = activeTableCell?.frame {
                if !visibleRect.contains(rectToBeDisplayed) {
                    tableView.scrollRectToVisible(rectToBeDisplayed, animated: true)
                }
            }
        }
    }
    
    @objc private func keyboardWillHideHandler(notification: NSNotification) {
        let newInset = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: 0, right: 0)
        tableView.contentInset = newInset
    }
}

