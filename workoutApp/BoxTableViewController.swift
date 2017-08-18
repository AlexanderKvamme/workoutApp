//
//  BoxTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class BoxTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var workoutStyleName: String?
    var cellIdentifier: String
    var customRefreshView: RefreshControlView!
    var dataSource: isBoxTableViewDataSource!
    
    // MARK: - Initializers
    
    init(workoutStyleName: String?, cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
        self.workoutStyleName = workoutStyleName
        super.init(nibName: nil, bundle: nil)
        setUpNavigationBar(withTitle: workoutStyleName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show SelectionIndicator over tab bar
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.showSelectionindicator()
        }
        refreshControl?.endRefreshing()
        dataSource.refreshDataSource()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetRefreshControlAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showNavigationBar()
    }
    
    // MARK: - Methods
    
    func setupTableView() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset.left = 0
    }

    // MARK: Refresh Control
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .clear
        refreshControl?.tintColor = .clear
        
        // Custom view
        customRefreshView = RefreshControlView()
        customRefreshView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        customRefreshView.frame = refreshControl!.bounds // <-- Why is this needed?
        customRefreshView.label.alpha = 0
        refreshControl?.addSubview(customRefreshView)
        
        refreshControl!.addTarget(self, action: #selector(BoxTableViewController.refreshControlHandler(sender:)), for: .valueChanged)
    }
    
    @objc private func refreshControlHandler(sender: UIRefreshControl) {
        // Make fontsize "pop" bigger
        customRefreshView.label.font = UIFont.custom(style: .bold, ofSize: .extreme)
        
        let newWorkoutVC = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutVC, animated: true)
    }
    
    func resetRefreshControlAnimation() {
        customRefreshView.label.alpha = 0
        customRefreshView.label.font = UIFont.custom(style: .bold, ofSize: .biggest)
    }

    // MARK: Navigationbar
    
    func setUpNavigationBar(withTitle title: String?) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let name = title {
            self.title = "\(name) History".uppercased()
        } else {
            self.title = "All History".uppercased()
        }
        refreshControl?.endRefreshing()
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        refreshControl?.endRefreshing()
    }
    
    func removeBackButton(){
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    // MARK: TableView delegate methods
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
    }
}

