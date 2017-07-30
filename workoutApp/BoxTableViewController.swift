//
//  BoxTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class BoxTableViewController: UITableViewController {
    
    let cellIdentifier: String = "BoxCell"
    var workoutStyleName: String!
    
    var customRefreshView: RefreshControlView!
    var dataSource: WorkoutTableViewDataSource!
    
    // Initializer
    
    init(workoutStyleName: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = "\(workoutStyleName) workouts".uppercased()
        self.workoutStyleName = workoutStyleName

        setUpNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Navbar setup
        navigationController?.setNavigationBarHidden(false, animated: true)
        removeBackButton()
        
        // TableViewSetup
        refreshControl?.endRefreshing()
        dataSource.refreshDataSource()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        super.viewDidLoad()
        
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
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetRefreshControlAnimation()
    }

    // MARK: - Refresh Control
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .clear
        refreshControl?.tintColor = .clear
        
        // Custom view
        customRefreshView = RefreshControlView()
        customRefreshView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        customRefreshView.frame = refreshControl!.bounds // <-- Why is this needed?
        customRefreshView.label.alpha = 0
        refreshControl?.addSubview(customRefreshView)
        
        refreshControl!.addTarget(self,
                                  action: #selector(BoxTableViewController.refreshControlHandler(sender:)),
                                  for: .valueChanged)
    }
    
    @objc private func refreshControlHandler(sender: UIRefreshControl) {
        // Make fontsize "pop" bigger
        customRefreshView.label.font = UIFont.custom(style: .bold, ofSize: .extreme)
        
        let newWorkoutVC = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutVC, animated: true)
    }
    
    private func resetRefreshControlAnimation() {
        customRefreshView.label.alpha = 0
        customRefreshView.label.font = UIFont.custom(style: .bold, ofSize: .biggest)
    }
    
    private func setupDataSource() {
        dataSource = WorkoutTableViewDataSource(workoutStyleName: workoutStyleName)
        tableView.dataSource = dataSource
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(WorkoutBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorInset.left = 0
    }

    private func removeBackButton(){
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }

    // Nav bar
    
    private func setUpNavigationBar() {
        let navButtonRight = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: navButtonRight, style: .done, target: self, action: #selector(xButtonHandler))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc private func xButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView delegate methods
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wo = dataSource.getWorkouts()
        if let wo = wo {
            let selectedWorkout = wo[indexPath.row]
            let detailedVC = ExerciseTableViewController(withWorkout: selectedWorkout)
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
}

