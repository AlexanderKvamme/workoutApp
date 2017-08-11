//
//  GoalsList.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class GoalsController: UIViewController {
    
    // MARK: - Properties
    
    private var header = UILabel(frame: CGRect.zero)
    private var goals: [Goal]?
    private var stackOfGoalButtons: UIStackView = UIStackView()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if let goalsInCoreData = DatabaseFacade.fetchGoals() {
            self.goals = goalsInCoreData
        } else {
            // Make initial goals
            let exampleGoal1 = DatabaseFacade.makeGoal()
            exampleGoal1.dateMade = Date() as NSDate
            exampleGoal1.text = "Hold goals to delete a goal".uppercased()
            
            let exampleGoal2 = DatabaseFacade.makeGoal()
            exampleGoal2.dateMade = Date() as NSDate
            exampleGoal2.text = "Or hold header to create a new one".uppercased()
            
            self.goals = [exampleGoal1, exampleGoal2]
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        if let goals = goals {
            for goal in goals {
                let newButton = makeGoalButton(withGoal: goal)
                stackOfGoalButtons.addArrangedSubview(newButton)
            }
        }
        setupView()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        setupHeader()
        setupStack()
    }
    
    private func setupHeader() {
        header.text = "GOALS"
        header.textColor = .dark
        header.font = UIFont.custom(style: .bold, ofSize: .big)
        header.applyCustomAttributes(.medium)
        header.sizeToFit()
        view.addSubview(header)
        
        // Long press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(headerLongPressHandler(_:)))
        header.addGestureRecognizer(longPressRecognizer)
        header.isUserInteractionEnabled = true
        
        //Layout
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30)
            ])
    }
    
    private func setupStack() {
        let sideInsets: CGFloat = 40

        stackOfGoalButtons.spacing = 8
        stackOfGoalButtons.alignment = .leading
        stackOfGoalButtons.axis = .vertical
        stackOfGoalButtons.distribution = .equalSpacing
        stackOfGoalButtons.layoutMargins = UIEdgeInsets(top: 10, left: sideInsets, bottom: 0, right: sideInsets)
        stackOfGoalButtons.isLayoutMarginsRelativeArrangement = true
        stackOfGoalButtons.alpha = Constant.alpha.faded
        view.addSubview(stackOfGoalButtons)
        
        // Layout
        stackOfGoalButtons.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackOfGoalButtons.topAnchor.constraint(equalTo: header.bottomAnchor),
            stackOfGoalButtons.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackOfGoalButtons.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackOfGoalButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
//    private func makeGoalButton(withText text: String) -> UIButton {
    private func makeGoalButton(withGoal goal: Goal) -> GoalButton {
//        let button = GoalButton(frame: .zero)
        let button = GoalButton(withGoal: goal)
        
        guard let label = button.titleLabel else { return button }
        
        // Title Label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.preferredMaxLayoutWidth = 100
        label.lineBreakMode = .byWordWrapping
        
        // Text
        let attributedTitle = GoalsController.bulletedListItem(string: goal.text ?? "NO TEXT")
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // Layout
        label.sizeToFit()
        button.frame.size = label.frame.size
        button.layoutIfNeeded()
        
        // Long press to delete
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(goalLongPressHandler(_:)))
        button.addGestureRecognizer(longPressRecognizer)
        
        return button
    }
    
    // MARK: - Handlers
    
    @objc private func headerLongPressHandler(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
//            let newGoal = makeGoalButton(withText: "Let user make a real goal".uppercased())
            // Goal
            let newGoal = DatabaseFacade.makeGoal()
            newGoal.dateMade = Date() as NSDate
            newGoal.text = "let user input text".uppercased()
            
            // GoalButton
            let newGoalButton = makeGoalButton(withGoal: newGoal)
            goals?.append(newGoal)
            stackOfGoalButtons.addArrangedSubview(newGoalButton)
        }
    }
    
    @objc private func goalLongPressHandler(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            if let sender = gesture.view{
                
                // TODO: - Remove from Core data
                stackOfGoalButtons.removeArrangedSubview(sender)
                sender.removeFromSuperview()
                if let aButton = sender as? GoalButton {
                    print(" SUCCESS ")
                    aButton.deleteFromCoreData()
                    // find index and delete it
                    
                } else {
                    print(" FAIL ")
                }
            }
        }
    }
}

