//
//  ExerciseTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import SnapKit

// FIXME: This must be done better
//let globalTimerWidth: CGFloat = 220
let globalTimerWidth: CGFloat = Constant.UI.width - 48 - 24
let globalTimerHeight: CGFloat = 32
let globalCancelTimerWidth: CGFloat = 44


class CounterManager: AKTimerDelegate {
    
    var tickHandler: ((Int) -> ())?
    
    func statusDidChange(to status: AKTimerStatus) {
        
        switch status {
        case .ticking(let current, let target):
            tickHandler?(current)
        case .inactive:
            print("bam would show timer buttons")
        case .done:
            print("bam would also show timer buttons")
        }
    }
}

extension UIBarButtonItem {

    static func menuButton(_ target: Any?, action: Selector, image: UIImage, size: CGFloat, tint: UIColor) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = tint
        button.transform = CGAffineTransform(translationX: -16, y: 0)

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: size).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: size).isActive = true
        return menuBarItem
    }
}

/// This TableView is the actual workout when the user is working out
class ActiveWorkoutController: UITableViewController {
    
    // MARK: - Properties
    
    var activeTableCell: UITableViewCell? // used by cell to make correct collectionView.label firstResponder
    private var currentWorkout: Workout!
    private var dataSource: ExerciseTableDataSource!
    private var myWorkoutLog: WorkoutLog!
    private var timerBar = AKTimerStatusBar(time: 0)
    private var snapShot: UIView?
    private var location: CGPoint!
    private var sourceIndexPath: IndexPath!
    private lazy var counter = CounterButton("0", timerDelegate: self)
    private var counterManager = CounterManager()
    private var akCounter = AKTimer()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(restartCounter), name: Notification.Name.didEndEditingActiveWorkoutField, object: nil)
    }
    
    @objc private func restartCounter() {
        akCounter.startCountUpTo(3)
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
        
        addTimerButtons()
        
        akCounter.delegate = counterManager
        counterManager.tickHandler = { currentValue in
            self.counter.label.text = "\(currentValue)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        enableSwipeBackGesture(false)
    }
    
    // MARK: - Methods
    
    private func addTimerButtons() {
        navigationItem.titleView = nil
        
        let spacerView = UIView()
        let one = UIBarButtonItem(customView: TimerButton("1", timerDelegate: self))
        let two = UIBarButtonItem(customView: TimerButton("2", timerDelegate: self))
        let three = UIBarButtonItem(customView: TimerButton("3", timerDelegate: self))
        
        let hStack = UIStackView(arrangedSubviews: [one.customView!, two.customView!, three.customView!])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 8
        navigationItem.titleView = hStack
        
        // Timer
        let timerItem = UIBarButtonItem(customView: counter)
        navigationItem.leftBarButtonItem = timerItem
    }
    
    private func addTimerBar(target: TimeInterval) {
        navigationItem.leftBarButtonItems = nil
        navigationItem.rightBarButtonItem = nil
        
        let timerBar = AKTimerStatusBar(time: target)
        timerBar.delegate = self
        timerBar.heightAnchor.constraint(equalToConstant: globalTimerHeight).isActive = true
        timerBar.widthAnchor.constraint(equalToConstant: globalTimerWidth).isActive = true

        // This will assing your custom view to navigation title.
        navigationItem.titleView = timerBar
        timerBar.startAnimation(seconds: target) {
            self.addTimerButtons()
            self.addExitButtonToNavBar()
            Audioplayer.play(.congratulations)
        }
    }
    
    // MARK: setup methods
    
    private func enableSwipeBackGesture(_ b: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = b
    }
    
    private func setupNavigationBar() {
        // FIXME: Update the header
        if let name = currentWorkout.name {
            self.title = name.uppercased()
            self.title = ""
        }
        
        globalTabBar?.hideIt()
        addExitButtonToNavBar()
    }
    
    private func setupTable() {
        // tableview setup
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .akLight
        
        setupTableFooter()
        tableView.reloadData()
    }
    
    private func addExitButtonToNavBar() {
        // Right navBar button
        let topinset = 12.0
        let menuBtn = UIButton(type: .custom)
        menuBtn.contentVerticalAlignment = .center
        menuBtn.contentHorizontalAlignment = .center
        menuBtn.imageView?.contentMode = .scaleAspectFit
        menuBtn.setImage(.close24.withTintColor(.akDark), for: .normal)
        menuBtn.contentEdgeInsets = UIEdgeInsets(top: topinset, left: 0, bottom: topinset, right: 16)
        menuBtn.addTarget(self, action: #selector(xButtonHandler), for: UIControl.Event.touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.rightBarButtonItem = menuBarItem
        self.navigationItem.hidesBackButton = true
    }
    
    private func setupTableFooter() {
        let footerFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64)
        let footer = ExerciseTableFooter(frame: footerFrame)
        footer.saveButton.accessibilityIdentifier = "footer-save-button"
        footer.saveButton.addTarget(self, action: #selector(saveButtonHandler), for: .touchUpInside)
        
        view.backgroundColor = .akLight
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
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "You will no close the exit and save this workout in your history.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: "Save and exit",
            style: .destructive,
            handler: { _ in
                self.dataSource.saveWorkoutLog()
                self.presentingBoxTable?.shouldUpdateUponAppearing = true
        }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { _ in
            // Do nothing on cancel
        }))
        present(alert,
                animated: true,
                completion: nil
        )
    }
    
    @objc private func xButtonHandler() {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "The progress of this workout will be lost",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: "Delete and exit",
            style: .destructive,
            handler: { _ in
                self.dataSource.deleteAssosciatedLiftsExerciseLogsAndWorkoutLogs()
                self.navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
        }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { _ in
            // Do nothing on cancel
        }))
        present(alert,
                animated: true,
                completion: nil
        )
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHandler), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideHandler), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowHandler(notification: NSNotification) {
        // Make sure you received a userInfo dict
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
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

extension ActiveWorkoutController: AKTimerStatusBarDelegate {
    func statusBarDidFinish(_ bool: Bool) {
        addTimerButtons()
    }
}

// FIXME: This is where the active vc handles the timer ticks
// FIXME: Do more shit here
extension ActiveWorkoutController: AKTimerDelegate {
    func statusDidChange(to status: AKTimerStatus) {
        switch status {
        case .ticking(let current, let target):
            if current == 0 {
                addTimerBar(target: TimeInterval(target))
            }
            timerBar.update(current, target)
        case .inactive:
            print("bam would show timer buttons")
        case .done:
            print("bam would also show timer buttons")
            addTimerButtons()
        }
    }
}

