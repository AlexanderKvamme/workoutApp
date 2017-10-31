//
//  GoalsList.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class GoalsController: UIViewController, isStringReceiver {

    // MARK: - Properties
    
    private var header = UILabel(frame: CGRect.zero)
    private var goals: [Goal]?
    private var stackOfGoalButtons: UIStackView = UIStackView()
    
    var stringReceivedHandler: ((String) -> Void) = { _ in }
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.goals = DatabaseFacade.fetchGoals()
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
        setupReceiveHandler()
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
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
    
    private func setupStack() {
        let sideInsets: CGFloat = 40

        stackOfGoalButtons.spacing = 4
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
    
    private func makeGoalButton(withGoal goal: Goal) -> GoalButton {
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
            let goalPicker = InputViewController(inputStyle: .text)
            goalPicker.delegate = self
  
            navigationController?.pushViewController(goalPicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
        }
    }
    
    @objc private func goalLongPressHandler(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        if let sender = gesture.view {
            stackOfGoalButtons.removeArrangedSubview(sender)
            sender.removeFromSuperview()
            if let aButton = sender as? GoalButton {
                aButton.deleteFromCoreData()
            }
        }
    }
    
    private func setupReceiveHandler() {
        stringReceivedHandler = { str in
            let goal = DatabaseFacade.makeGoal()
            goal.dateMade = Date() as NSDate
            goal.text = str
            
            let buttonFromGoal = self.makeGoalButton(withGoal: goal)
            self.goals?.append(goal)
            self.stackOfGoalButtons.addArrangedSubview(buttonFromGoal)
        }
    }
}

