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
    
    // Replace UIImageView with CollageView
    private let collageView: CollageView = {
        let collage = CollageView()
        collage.images = ["md-image-1", "md-image-2", "md-image-3", "md-image-4", "md-image-5"]
        collage.centerShapeSize = 240
        collage.baseDistance = 130
        collage.borderColor = .black
        collage.surroundingShapesCount = 5
        collage.surroundingShapeSizeRange = (120, 140)
        return collage
    }()
    
    let paintStrokeView = PaintStrokeView(frame: CGRect(x: 50, y: 100, width: 200, height: 100))
    
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

    private lazy var historyButton: UIButton = {
        var hSpace = CGFloat(16)
        var config = UIButton.Configuration.filled()
        config.title = "history"
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
        button.addTarget(self, action: #selector(pushHistoryController), for: .touchUpInside)
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
        
        // Setup collage first, then reset animation
        collageView.resetAnimation()
        paintStrokeView.play()
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
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-160)
            }
            
            // Update collageView constraints to fill remaining space
            collageView.snp.remakeConstraints { make in
                make.top.equalTo(header.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(buttonGrid.snp.top)
            }
            
            paintStrokeView.snp.remakeConstraints { make in
                make.edges.equalTo(collageView)
            }
        }
    }

    private func setupLayout() {
        view.addSubview(paintStrokeView)
        view.addSubview(header)
        view.addSubview(collageView)
        view.addSubview(badgeButton)
        view.addSubview(historyButton)

        // Header constraints using SnapKit
        header.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(Constant.components.SelectionVC.Header.spacingTop)
        }

        // Initial collageView constraints (will be updated in updateButtonGrid)
        collageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(header.snp.bottom).offset(60)
            make.leading.greaterThanOrEqualTo(view).offset(40)
            make.trailing.lessThanOrEqualTo(view).offset(-40)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-260)
        }

        // Badge button (top-right)
        badgeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view).offset(-20)
        }

        // History button (top-left)
        historyButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(view).offset(20)
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

    @objc private func pushHistoryController() {
        let historyVC = HistorySelectionViewController()
        navigationController?.pushViewController(historyVC, animated: true)
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
