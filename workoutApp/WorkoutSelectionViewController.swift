

//
//  WorkoutSelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

/*
 SelectionVC is a list of buttons to provide users with the ability to pick further predicates for which workouts to show. For example when displaying workouts, it displays the different styles. Normal, drop set, etc.
 */

class WorkoutSelectionViewController: SelectionViewController {
    
//    var fetchRequestToDisplaySelectionsFrom: NSFetchRequest<NSFetchRequestResult>? // Used to fetch avaiable choices and display them as buttons
//    var header: SelectionViewHeader!
//    var buttons: [SelectionViewButton]!
//    var alignmentRectangle = UIView() // Used to center stack and diagonalLineView between header and tab bar
//    var diagonalLineView: UIView! // yellow line through the stack to create som visual tension
//    var stack: StackView!
//    // button creation
//    var buttonNames = [String]()
//    var buttonIndex = 0
    
    // MARK: - Initializers
    
    init() {
        super.init(header: SelectionViewHeader(header: "Select", subheader: "Workout Style"))
        print("initializing historySelectionController via init()")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    // ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateStackWithEntriesFromCoreData()
        
        if buttonNames.count > 0 {
            drawDiagonalLine()
        }
        
        view.bringSubview(toFront: stack) // Bring it in front of diagonal line
        view.layoutIfNeeded()
    }
    
    // ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .light
        setupStack()
        setupLayout()
    }
    
    // MARK: - Methods
    
    private func setupLayout() {
        view.addSubview(header)
        view.addSubview(stack)
        
        // header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor,
                                    constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
        
        // stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // Position stack
        makeAlignmentRectangle()
        stack.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor, constant: 0).isActive = true
    }
    
    private func setupStack() {
        stack = StackView(frame: CGRect.zero)
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = Constant.components.SelectionVC.Stack.spacing
    }
    
    // Stack methods
    
    /** Sends new fetch and updates buttons */
    private func updateStackWithEntriesFromCoreData() {
        let workoutStyles = getUniqueWorkoutStyles() // getWorkoutStyles(withRequest: request)
        
        print(" got workoutStyles")
        print(workoutStyles.count)
        print(workoutStyles)
        
        buttonIndex = 0
        
        for subview in stack.subviews {
            subview.removeFromSuperview()
        }
        
        // make buttons from unique workout names
        var workoutButtons = [SelectionViewButton]()
        let uniqueWorkoutTypes = Set(workoutStyles)
        buttonNames = [String]()
        
        for type in uniqueWorkoutTypes {
            guard let styleName = type.name else {
                return
            }
            
            let newButton = SelectionViewButton(header: styleName,
                                                subheader: "\(DatabaseFacade.countWorkoutsOfType(ofStyle: styleName)) WORKOUTS")
            
            // Set up button names etc
            newButton.button.tag = buttonIndex
            buttonIndex += 1
            buttonNames.append(styleName)
            
            // Replace any default target action (Default modal presentation)
            newButton.button.removeTarget(nil, action: nil, for: .allEvents)
            newButton.button.addTarget(self, action: #selector(buttonTapHandler), for: UIControlEvents.touchUpInside)
            
            workoutButtons.append(newButton)
        }
        
        buttons = workoutButtons
        
        // Update stack
        stack.removeArrangedSubviews()
        
        for button in buttons {
            stack.addArrangedSubview(button)
        }
        
        addNewWorkoutButton()
        
        stack.layoutIfNeeded()
    }
    
    private func addNewWorkoutButton() {
        
        let plusButton = ReusableComponents.makePlusButton()
        
        if buttons.count > 0 {
            // Already has selection choices, so place button under the header
            view.addSubview(plusButton)
            plusButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                plusButton.heightAnchor.constraint(equalToConstant: 20),
                plusButton.widthAnchor.constraint(equalToConstant: 20),
                plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                plusButton.centerYAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
                ])
        } else {
            // add to stackView as only button
            stack.addArrangedSubview(plusButton)
        }
        
        // present newWorkoutController on tap
        plusButton.addTarget(self, action: #selector(plusButtonTapHandler), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapHandler() {
        let newWorkoutController = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutController, animated: true)
    }
    
//    func buttonTapHandler(button: UIButton) {
//        // Identifies which choice was selected and creates a BoxTableView to display
//        let tappedWorkoutStyleName = buttonNames[button.tag]
//        let boxTableViewController = BoxTableViewController(workoutStyleName: tappedWorkoutStyleName)
//        
//        navigationController?.pushViewController(boxTableViewController, animated: true)
//    }
    
    // MARK: - Helpers
    
//    private func getWorkoutStyles(withRequest request: NSFetchRequest<NSFetchRequestResult>) -> [WorkoutStyle] {
//        var workoutStyles = [WorkoutStyle]()
//        do {
//            let results = try DatabaseController.getContext().fetch(request)
//            // Append all received types
//            for r in results as! [Workout] {
//                if let workoutStyle = r.workoutStyle {
//                    workoutStyles.append(workoutStyle)
//                }
//            }
//        } catch let error as NSError {
//            print("error in SelectionViewController : ", error.localizedDescription)
//        }
//        return workoutStyles
//    }
}
