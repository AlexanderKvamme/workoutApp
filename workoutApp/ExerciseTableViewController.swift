//
//  ExerciseTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ExerciseTableViewController: UITableViewController {

    var currentWorkout: Workout! // The workout that contains the exercises this tableVC is displaying
    var dataSource: ExerciseTableViewDataSource!
    var myWorkoutLog: WorkoutLog! // used in the end
    var exercisesToLog: [ExerciseLog]! // make an array of ExerciseLogs, and every time a tableViewCell.liftsToDisplay is updated, add it to here
    var activeTableCell: UITableViewCell?
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        dataSource = ExerciseTableViewDataSource(workout: currentWorkout) // Make datasource out of the provided Workout
        tableView.dataSource = dataSource
        dataSource.owner = self
        
        // delegate setup
        tableView.delegate = self
        tableView.register(ExerciseTableViewCell.self, forCellReuseIdentifier: "exerciseCell")
        
        setupTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let verticalSpacingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        verticalSpacingView.backgroundColor = .light
        return verticalSpacingView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView didSelect at: \(indexPath)")
    }
    
    // MARK: - Methods
    
    @objc private func saveButtonHandler() {
        // FIXME: - remember call deleteTrackedData on datasource from the dismissbutton
        print("*GONNA DELEGATE SAVING TO THE DATASOURCE*")
        dataSource.saveWorkout()
    }
    
    private func setupNavigationBar() {
        if let name = currentWorkout.name {
            self.title = name.uppercased()
        } else {
            print("error setting navbar title")
        }
        let navButtonRight = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: navButtonRight, style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightButton
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Helper methods
    
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
        
        setupFooter()
        tableView.reloadData()
    }
    
    private func setupFooter() {
        let footerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let footer = ExerciseTableFooter(frame: footerFrame)
        footer.saveButton.addTarget(self, action: #selector(saveButtonHandler), for: .touchUpInside)
        
        footer.backgroundColor = .dark
        view.backgroundColor = .dark
        tableView.tableFooterView = footer
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowHandler),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideHandler),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func setDebugColors() {
        view.backgroundColor = .green
        tableView.tableFooterView?.backgroundColor = .yellow
        tableView.backgroundColor = .red
    }
    
    // MARK: - Handlers
    
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
            let insetsForTableView = UIEdgeInsets(top: insetsFromNavbar,
                left: 0,
                bottom: keyboardHeight,
                right: 0)
            
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
        let newInset = UIEdgeInsets(top: tableView.contentInset.top,
                                    left: 0, bottom: 0, right: 0)
        tableView.contentInset = newInset
    }
}

