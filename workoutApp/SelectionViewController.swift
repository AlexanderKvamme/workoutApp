//
//  SelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

class SelectionViewController: UIViewController {
    
    var header: SelectionViewHeader!
    var buttons: [SelectionViewButton]!
    var alignmentRectangle = UIView() // Used to center stack between header and tab bar
    var stack: StackView!
    
    // button creation
    var buttonNames: [String] = []
    var buttonIndex = 0
    
    // Main initializer
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
    convenience init(header: SelectionViewHeader, fetchRequest: NSFetchRequest<Workout>) {
        self.init(header: header)
        var workoutTypes = [String]()
        
        // Fetch from Core Data
        do {
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            // Append all received types
            for r in results {
                if let type = r.type {
                    workoutTypes.append(type)
                }
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        // make buttons from unique workout names
        var workoutButtons = [SelectionViewButton]()
        let uniqueWorkoutTypes = Set(workoutTypes)
        
        for type in uniqueWorkoutTypes {
            
            let newButton = SelectionViewButton(header: type,
                subheader: "\(DatabaseFacade.countWorkoutsOfType(ofType: type)) exercises")
        
            // Set up button names etc
            newButton.button.tag = buttonIndex
            buttonIndex += 1
            buttonNames.append(type)
            
            // Replace any default target action
            newButton.button.removeTarget(nil, action: nil, for: .allEvents)
            newButton.button.addTarget(self, action: #selector(processButton), for: UIControlEvents.touchUpInside)

            workoutButtons.append(newButton)
        }
        
        buttons = workoutButtons
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        drawDiagonalLineThrough(stack)
    }
    
    // TODO: - Make work
    
    func processButton(button: UIButton) {
        let tappedWorkoutStyle = buttonNames[button.tag]
        // process string
        
        let vc = BoxTableViewController(workoutStyle: tappedWorkoutStyle)
        //let vc = TestTableViewController(nibName: nil, bundle: nil)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func drawDiagonalLineThrough(_ someView: UIView) {
        view.layoutSubviews()
        let verticalShift: CGFloat = 0
        let verticalStretch: CGFloat = 30
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: someView.frame.minX, y: someView.frame.maxY + verticalStretch - verticalShift))
        path.addLine(to: CGPoint(x: someView.frame.maxX, y: someView.frame.minY - verticalStretch - verticalShift))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.primary.cgColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = 3.0
        
        let line = UIView()
        line.layer.addSublayer(shapeLayer)
        view.addSubview(line)
        view.sendSubview(toBack: line)
        //view.layer.addSublayer(shapeLayer)
        //view.sendSubview(toBack: shapeLayer)
    }
    
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
