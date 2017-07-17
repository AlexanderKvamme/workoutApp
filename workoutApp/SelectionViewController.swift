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
    
    // Input
    var fetchRequestToDisplaySelectionsFrom: NSFetchRequest<NSFetchRequestResult>!
    
    var header: SelectionViewHeader!
    var buttons: [SelectionViewButton]!
    var alignmentRectangle = UIView() // Used to center stack between header and tab bar
    var stack: StackView!
    
    // button creation
    var buttonNames: [String] = []
    var buttonIndex = 0
    
    // MARK: - Initializers
    init(header: SelectionViewHeader) {
        self.header = header
        super.init(nibName: nil, bundle: nil)
    }
    
    // Init with manually created buttons
    init(header: SelectionViewHeader, buttons: [SelectionViewButton]) {
        self.header = header
        self.buttons = buttons
        super.init(nibName: nil, bundle: nil)
    }
    
    // Init with fetchRequest
    
    convenience init(header: SelectionViewHeader, fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.init(header: header)
        self.fetchRequestToDisplaySelectionsFrom = fetchRequest
        
        setupSelectionChoices()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Show TabBar selection indicator
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if fetchRequestToDisplaySelectionsFrom != nil {
            updateSelectionChoices()
        }
        view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        //Stack View
        stack = StackView(frame: CGRect.zero)
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = Constant.components.SelectionVC.Stack.spacing

        for button in buttons {
            stack.addArrangedSubview(button)
        }
        
        view.addSubview(header)
        view.addSubview(stack)
        
        setLayout()
        drawDiagonalLineThrough(stack, inView: view)
    }
    
    // MARK: - Methods
    
    func updateSelectionChoices() {
        setupSelectionChoices()
    }
    
    func setupSelectionChoices() {
        var workoutStyles = [WorkoutStyle]()
        
        // Fetch from Core Data
        
        do {
            print("fetchRequest was: \(self.fetchRequestToDisplaySelectionsFrom)")
            let results = try DatabaseController.getContext().fetch(fetchRequestToDisplaySelectionsFrom)
            // Append all received types
            for r in results as! [Workout] {
                if let workoutStyle = r.workoutStyle {
                    workoutStyles.append(workoutStyle)
                }
            }
        } catch let error as NSError {
            print("error in SelectionViewController : ", error.localizedDescription)
        }
        
        // make buttons from unique workout names
        var workoutButtons = [SelectionViewButton]()
        let uniqueWorkoutTypes = Set(workoutStyles)
        
        for type in uniqueWorkoutTypes {
            guard let styleName = type.name else {
                print("error finding style name")
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
    }
    
    // TODO: - Make work
    
    func buttonTapHandler(button: UIButton) {
        // Identifies which choice was selected and creates a BoxTableView to display
        let tappedWorkoutStyle = buttonNames[button.tag]
        
        // process string
        let boxTableViewController = BoxTableViewController(workoutStyleName: tappedWorkoutStyle)
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
    
    private func setLayout() {
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
    
    private func makeAlignmentRectangle() {
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
}
