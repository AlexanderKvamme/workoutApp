//
//  HistoryTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit


class HistoryTableViewController: BoxTableViewController {
    
    // MARK: - Initializers
    
    init(workoutStyleName: String?) {
        super.init(workoutStyleName: workoutStyleName, cellIdentifier: "HistoryBoxCell")
        tableView.register(HistoryBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        setUpNavigationBar(withTitle: self.workoutStyleName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
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
}

