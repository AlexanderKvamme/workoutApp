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
    
    var dataSource: UITableViewDataSource!
    
    // Init
    init(workoutStyle: String) {
        super.init(nibName: nil, bundle: nil)
        self.workoutStyle = workoutStyle

        setUpNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeBackButton()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        super.viewDidLoad()
        removeBackButton()
        
        // Data source setup
        dataSource = WorkoutTableViewDataSource(workoutStyle: workoutStyle)
        tableView.dataSource = dataSource
        
        // Table view setup
        tableView.delegate = self
        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(WorkoutBoxCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorInset.left = 0
    }

    // MARK: - helpers

    private func removeBackButton(){
        // Remove "Back" text
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
}

