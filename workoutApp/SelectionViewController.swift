//
//  SelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

/// SelectionVC is a list of buttons to provide users with the ability to pick further predicates for which workouts/workoutlogs (if displaying history) to show. For example when displaying workouts, it displays the different styles. Normal, drop set, etc, while a historySelectionViewcontroller lets user see previously completed workouts in the form of a table listing out previous workoutLogs. SelectionViewController is the superclass of WorkoutSelectionViewController and HistorySelectionViewController, which both leads to different tableViews.

class SelectionViewController: UIViewController {
    
    var fetchRequestToDisplaySelectionsFrom: NSFetchRequest<NSFetchRequestResult>? // Fetch choice options
    var header: SelectionViewHeader!
    var buttons = [SelectionViewButton]()
    var alignmentRectangle = UIView() // Used to center stack and diagonalLineView between header and tab bar
    var diagonalLineView: UIView! // yellow line through the stack to create som visual tension
    var stack: UIStackView!
    var buttonNames = [String]()
    var buttonIndex = 0
    
    // MARK: - Initializers
    
    init(header: SelectionViewHeader) {
        self.header = header
        super.init(nibName: nil, bundle: nil)
    }
    
    // Initialize with fetchRequest
    convenience init(header: SelectionViewHeader, fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.init(header: header)
        self.fetchRequestToDisplaySelectionsFrom = fetchRequest
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    // ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupStack()
        setupLayout()
    }
    
    // ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.showSelectionIndicator()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        title = "" // Removes "Back" text in navbar
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        view.addSubview(header)
        view.addSubview(stack)
        
        // Header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
        
        // Stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // Position stack
        makeAlignmentRectangle()
        stack.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor, constant: 0).isActive = true
    }
    
    private func setupStack() {
        stack = UIStackView(frame: CGRect.zero)
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.alignment = UIStackView.Alignment.center
        stack.spacing = Constant.components.SelectionVC.Stack.spacing
    }

    // MARK: - Helpers
    
    /// Used to position stack properly in the middle of header and tabbar
    func makeAlignmentRectangle() {
        alignmentRectangle = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        alignmentRectangle.backgroundColor = .blue
        view.addSubview(alignmentRectangle)
        alignmentRectangle.alpha = 0.5
        alignmentRectangle.isHidden = true
        alignmentRectangle.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0).isActive = true
        alignmentRectangle.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        alignmentRectangle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        alignmentRectangle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        alignmentRectangle.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Draws yellow line through the stack
    func drawDiagonalLine() {
        diagonalLineView = TriangleView(frame: alignmentRectangle.frame)
        view.addSubview(diagonalLineView)
        
        diagonalLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            diagonalLineView.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor),
            diagonalLineView.centerXAnchor.constraint(equalTo: alignmentRectangle.centerXAnchor)
            ])
    }
}

