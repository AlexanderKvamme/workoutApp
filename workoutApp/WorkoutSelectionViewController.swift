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
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "workout-bg"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var badgeButton: UIButton = makeGlassButton(title: "new", action: #selector(pushNewWorkoutController))
    private lazy var historyButton: UIButton = makeGlassButton(title: "history", action: #selector(pushHistoryController))

    private func makeGlassButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 4, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = h3.withSize(18)
            return outgoing
        }
        config.background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        config.background.cornerRadius = 12

        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(header: AnimatedScreenHeader(header: "Start", subheader: "A workout", headerColor: .white))
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

            buttonGrid.snp.makeConstraints { make in
                make.leading.greaterThanOrEqualTo(view).offset(40)
                make.trailing.lessThanOrEqualTo(view).offset(-40)
                make.centerX.equalTo(view)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-160)
            }

        }
    }

    private func setupLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(header)
        view.addSubview(badgeButton)
        view.addSubview(historyButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        header.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(Constant.components.SelectionVC.Header.spacingTop)
        }

        badgeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view).offset(-20)
        }

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
