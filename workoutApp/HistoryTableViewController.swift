//
//  HistoryTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// FIXME: - Now this is a real big fix it. Make this table view functional display cells with the "history design"

class HistoryTableViewController: BoxTableViewController {
    
    let cellIdentifier = "HistoryBoxCell"
    // MARK: - Initializers
    
    override init(workoutStyleName: String) {
        super.init(workoutStyleName: workoutStyleName)
        self.title = "\(workoutStyleName) history".uppercased()
        self.workoutStyleName = workoutStyleName
        
        setUpNavigationBar()
    }
    
    /// Initialzer to set up table to show ALL avaiable history
    override init() {
        super.init()
        self.title = "ALL HISTORY"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    // viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationBar()
        // TableViewSetup
        dataSource.refreshDataSource()
        tableView.reloadData()
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        setupTableView()
        setupRefreshControl()
        resetRefreshControlAnimation()
    }
    
    // MARK: - Methods
    
    private func setupDataSource() {
        dataSource = HistoryTableViewDataSource(workoutStyleName: workoutStyleName)
        tableView.dataSource = dataSource
    }
    
        private func setupTableView() {
            tableView.delegate = self
            tableView.estimatedRowHeight = 115
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.register(HistoryBoxCell.self, forCellReuseIdentifier: cellIdentifier)
            tableView.separatorInset.left = 0
        }
    
    // MARK: - TableView delegate methods
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customRefreshView.label.alpha = customRefreshView.frame.height/100
    }
}

