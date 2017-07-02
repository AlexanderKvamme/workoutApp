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
    var workoutStyle = ""
    
    var customRefreshView: RefreshControlView!
    var dataSource: WorkoutTableViewDataSource!
    
    // Initializer
    
    init(workoutStyle: String) {
        super.init(nibName: nil, bundle: nil)
        self.workoutStyle = workoutStyle

        setUpNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("vwa")
        removeBackButton()
        refreshControl?.endRefreshing()
    }
    
    // View did load
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        super.viewDidLoad()
        print("vdl")
        
        setupDataSource()
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
    }
    
    // View Did Appear
    
    override func viewDidAppear(_ animated: Bool) {
        // Show SelectionIndicator over tab bar
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.showSelectionindicator()
        }
        print("vda")
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
        
        // custom view
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
        // Fontsize pops bigger
        customRefreshView.label.font = UIFont.custom(style: .bold, ofSize: .extreme)
        
        let newWorkoutVC = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutVC, animated: true)
    }
    
    private func resetRefreshControlAnimation() {
        customRefreshView.label.alpha = 0
        customRefreshView.label.font = UIFont.custom(style: .bold, ofSize: .biggest)
    }
    
    private func setupDataSource() {
        dataSource = WorkoutTableViewDataSource(workoutStyle: workoutStyle)
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
    
    func swipeHandler() {
        print("swiped")
    }
    
    private func setUpNavigationBar() {
        self.title = "\(workoutStyle) workouts".uppercased()
        let navButtonRight = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: navButtonRight, style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - TableView delegate methods
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selectedRowAt \(indexPath.row)")
        let wo = dataSource.getWorkouts()
        if let wo = wo {
            print("which is: ", wo[indexPath.row])
            let detailedVC = ExerciseTableViewController(withWorkout: wo[indexPath.row])
            navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
}

