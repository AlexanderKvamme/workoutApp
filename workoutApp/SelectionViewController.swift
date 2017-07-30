//
//  SelectionViewController.swift
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

class SelectionViewController: UIViewController {
    
    var fetchRequestToDisplaySelectionsFrom: NSFetchRequest<NSFetchRequestResult>? // Used to fetch avaiable choices and display them as buttons
    var header: SelectionViewHeader!
    var buttons: [SelectionViewButton]!
    var alignmentRectangle = UIView() // Used to center stack and diagonalLineView between header and tab bar
    var diagonalLineView: UIView! // yellow line through the stack to create som visual tension
    var stack: StackView!
    // button creation
    var buttonNames = [String]()
    var buttonIndex = 0
    
    // MARK: - Initializers
    
    init(header: SelectionViewHeader) {
        self.header = header
        super.init(nibName: nil, bundle: nil)
    }
    
    // Initialize with manually created buttons
    init(header: SelectionViewHeader, buttons: [SelectionViewButton]) {
        self.header = header
        self.buttons = buttons
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
    
    // ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
//        // update with injected fetchRequest or manually added buttons
//        if let request = fetchRequestToDisplaySelectionsFrom {
//            updateStackWithEntriesFromCoreData(withRequest: request)
//        } else {
//            updateStackWithInsertedButtons()
//        }
//        stack.layoutIfNeeded()
//        
//        if buttonNames.count > 0 {
//            drawDiagonalLine()
//        }
//        
//        view.bringSubview(toFront: stack) // Bring it in front of diagonal line
//        view.layoutIfNeeded()
    }
    
    // ViewWillDisappear
    
//    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
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
    
    // methods to update stack
    
    private func updateStackWithInsertedButtons() {
        for button in self.buttons {
            stack.addArrangedSubview(button)
        }
    }
    
//    /** Sends new fetch and updates buttons */
//    private func updateStackWithEntriesFromCoreData(withRequest request: NSFetchRequest<NSFetchRequestResult>) {
//        let workoutStyles = getWorkoutStyles(withRequest: request)
//        
//        buttonIndex = 0
//        
//        for subview in stack.subviews {
//            subview.removeFromSuperview()
//        }
//        
//        // make buttons from unique workout names
//        var workoutButtons = [SelectionViewButton]()
//        let uniqueWorkoutTypes = Set(workoutStyles)
//        buttonNames = [String]()
//        
//        for type in uniqueWorkoutTypes {
//            guard let styleName = type.name else {
//                return
//            }
//            
//            let newButton = SelectionViewButton(header: styleName,
//                                                subheader: "\(DatabaseFacade.countWorkoutsOfType(ofStyle: styleName)) WORKOUTS")
//            
//            // Set up button names etc
//            newButton.button.tag = buttonIndex
//            buttonIndex += 1
//            buttonNames.append(styleName)
//            
//            // Replace any default target action (Default modal presentation)
//            newButton.button.removeTarget(nil, action: nil, for: .allEvents)
//            newButton.button.addTarget(self, action: #selector(buttonTapHandler), for: UIControlEvents.touchUpInside)
//            
//            workoutButtons.append(newButton)
//        }
//        
//        buttons = workoutButtons
//        
//        // Update stack
//        
//        for view in stack.arrangedSubviews {
//            view.removeFromSuperview()
//        }
//        
//        for button in buttons {
//            stack.addArrangedSubview(button)
//        }
//        
//        stack.setNeedsLayout()
//    }
    
    func buttonTapHandler(button: UIButton) {
        // Identifies which choice was selected and creates a BoxTableView to display
        let tappedWorkoutStyleName = buttonNames[button.tag]
        let boxTableViewController = BoxTableViewController(workoutStyleName: tappedWorkoutStyleName)
        
        navigationController?.pushViewController(boxTableViewController, animated: true)
    }
    
    // MARK: - Helpers
    
    private func drawRectAt(_ p: CGPoint) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        v.backgroundColor = .black
        v.center = p
        view.addSubview(v)
        v.layoutIfNeeded()
    }
    
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
    
    func drawDiagonalLine() {
        // Draw diagonal line
        diagonalLineView = getDiagonalLineView(sizeOf: stack)
        view.addSubview(diagonalLineView)
        
        diagonalLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            diagonalLineView.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor),
            diagonalLineView.centerXAnchor.constraint(equalTo: alignmentRectangle.centerXAnchor)
            ])
    }
}

