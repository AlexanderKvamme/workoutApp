//
//  BoxTableViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import SwipeCellKit

class BoxTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    lazy var wrenchImage: UIImage = {
        let resizedImage = UIImage.wrenchIcon.resize(maxWidthHeight: 36)!
        
        return resizedImage
    }()
    
    lazy var customRefreshView: RefreshControlView = {
        let view = RefreshControlView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = refreshControl!.bounds // <-- Why is this needed?
        view.label.alpha = 0
        
        return view
    }()
    
    lazy var ximage: UIImage = {
        return UIImage.xmarkIcon
    }()
    
    var workoutStyleName: String?
    var cellIdentifier: String
    
    // MARK: - Initializers
    
    init(workoutStyleName: String?, cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
        self.workoutStyleName = workoutStyleName
        super.init(nibName: nil, bundle: nil)
        
        setUpNavigationBar(withTitle: self.workoutStyleName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        view.backgroundColor = .light
        super.viewDidLoad()
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        if let name = title {
            var suffix = ""
            switch type(of: self) {
            case is WorkoutLogHistoryTableViewController.Type:
                suffix = "HISTORY"
            case is WorkoutTableViewController.Type:
                suffix = "WORKOUTS"
            default:
                break
            }
            self.title = "\(name.uppercased()) \(suffix)"
        } else {
            self.title = "ALL HISTORY"
        }
        refreshControl?.endRefreshing()
        removeBackButton()
    }
    
    private func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        refreshControl?.endRefreshing()
    }
    
    func removeBackButton(){
        guard let topItem = self.navigationController?.navigationBar.topItem else {
            return
        }
        topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func showSelectionIndicator() {
        guard let customTabBarController = self.tabBarController as? CustomTabBarController else {
            return
        }
        customTabBarController.showSelectionIndicator()
    }
    
    // MARK: SwipeCellKit
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        let myStyle = SwipeExpansionStyle(target: .percentage(0.5), additionalTriggers: [], elasticOverscroll: true, completionAnimation: .bounce)
        var options = SwipeTableOptions()
        options.expansionStyle = myStyle
        options.backgroundColor = .light
        options.transitionStyle = .border
        
        return options
    }
}

