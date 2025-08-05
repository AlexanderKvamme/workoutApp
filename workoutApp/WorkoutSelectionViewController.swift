//
//  WorkoutSelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData
import SnapKit

fileprivate var workoutToAutomaticallyEnter: Int? = nil

/// WorkoutSelectionViewController is a list of buttons to provide users with the ability to pick further predicates for which workouts to show. For example when displaying workouts, it displays the different styles. Normal, drop set, etc.
class WorkoutSelectionViewController: SelectionViewController {

    var workoutButtons = [SelectionViewButton]()
    
    // Replace the stack with ButtonGridView
    private var buttonGrid: ButtonGridView?
    
    // Add UIImageView between header and buttons
    private let centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "collage")
        return imageView
    }()
    
    // Add badge button
    private lazy var badgeButton: UIButton = {
        var hSpace = CGFloat(16)
        var config = UIButton.Configuration.filled()
        config.title = "new"
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: hSpace, bottom: 4, trailing: hSpace)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = h3.withSize(18)
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(pushNewWorkoutController), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(header: AnimatedScreenHeader(header: "Start", subheader: "A workout"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateButtonGridWithEntriesFromCoreData()
        
        view.layoutIfNeeded()
        
        globalTabBar.showIt()
        header.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugEnterWorkout(workoutToAutomaticallyEnter)
    }
    
    // MARK: - Methods
    
    /// Sends new fetch and updates button grid
    private func updateButtonGridWithEntriesFromCoreData() {
        let workoutStyles = DatabaseFacade.fetchAllWorkoutStyles()
        
        // Clear existing data
        buttonNames = [String]()
        buttonIndex = 0
        
        // Remove existing button grid
        buttonGrid?.removeFromSuperview()
        buttonGrid = nil
        
        // Create ButtonGridItems from workout styles
        var gridItems: [ButtonGridItem] = []
        
        // Process workout styles
        for workoutStyle in workoutStyles where workoutStyle.getWorkoutDesignCount() > 0 {
            let styleName = workoutStyle.getName()
            
            let subheaderString: String = {
                let workoutsOfThisStyle = workoutStyle.getWorkoutDesignCount()
                return workoutsOfThisStyle > 1 ? "\(workoutsOfThisStyle) WORKOUTS" : "\(workoutsOfThisStyle) WORKOUT"
            }()
            
            let gridItem = ButtonGridItem(
                title: styleName,
                icon: nil,
                color: .black,
                font: h2 ?? UIFont.boldSystemFont(ofSize: 20)
            ) { [weak self] in
                self?.showWorkoutTable(for: styleName)
            }
            
            gridItems.append(gridItem)
            buttonNames.append(styleName)
            buttonIndex += 1
        }
        
        // Create button grid with dynamic layout
        buttonGrid = ButtonGridView(items: gridItems, buttonsPerRow: 2)
        
        if let buttonGrid = buttonGrid {
            view.addSubview(buttonGrid)
            
            // Button grid constraints using SnapKit
            buttonGrid.snp.makeConstraints { make in
                make.leading.greaterThanOrEqualTo(view).offset(40)
                make.trailing.lessThanOrEqualTo(view).offset(-40)
                make.centerX.equalTo(view)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-200)
            }
            
            // Update centerImageView constraints to fill remaining space
            centerImageView.snp.remakeConstraints { make in
                make.centerX.equalTo(view)
                make.top.equalTo(header.snp.bottom).offset(60)
                make.leading.greaterThanOrEqualTo(view).offset(40)
                make.trailing.lessThanOrEqualTo(view).offset(-40)
                make.bottom.lessThanOrEqualTo(buttonGrid.snp.top).offset(-60)
            }
        }
    }

    private func setupLayout() {
        view.addSubview(header)
        view.addSubview(centerImageView)
        view.addSubview(badgeButton)
        
        // Header constraints using SnapKit
        header.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(Constant.components.SelectionVC.Header.spacingTop)
        }
        
        // Initial centerImageView constraints (will be updated in updateButtonGrid)
        centerImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(header.snp.bottom).offset(60)
            make.leading.greaterThanOrEqualTo(view).offset(40)
            make.trailing.lessThanOrEqualTo(view).offset(-40)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-260) // Default bottom constraint
        }
        
        // Badge button constraints using SnapKit
        badgeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view).offset(-20)
        }
    }
    
    // Button Grid methods
    
    private func debugEnterWorkout(_ int: Int?) {
        guard let int = int, int < buttonNames.count else { return }
        showWorkoutTable(for: buttonNames[int])
    }
    
    @objc private func pushNewWorkoutController() {
        let newWorkoutController = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutController, animated: true)
    }
    
    private func showWorkoutTable(for workoutStyleName: String) {
        let boxTable = WorkoutTableViewController(workoutStyleName: workoutStyleName)
        navigationController?.pushViewController(boxTable, animated: true)
    }
    
    // Legacy method for compatibility
    @objc func ShowWorkoutTable(button: UIButton) {
        guard button.tag < buttonNames.count else { return }
        let tappedWorkoutStyleName = buttonNames[button.tag]
        showWorkoutTable(for: tappedWorkoutStyleName)
    }
}
