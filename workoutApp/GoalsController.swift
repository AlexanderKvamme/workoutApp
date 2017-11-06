//
//  GoalsList.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Manages Goals, and is added to the ProfileController, along with a WarningController, and a SuggestionController
class GoalsController: UIViewController, isStringReceiver {

    // MARK: - Properties
    
    private var header = UIButton(frame: CGRect.zero)
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
        addGoals()
        setupView()
        setupReceiveHandler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addGoals()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        setupHeader()
        setupStack()
    }
    
    private func addGoals() {
        // Clear and refresh goals
        stackOfGoalButtons.removeArrangedSubviews()
        
        for goal in DatabaseFacade.getGoals() {
            let newButton = makeGoalButton(withGoal: goal)
            stackOfGoalButtons.addArrangedSubview(newButton)
        }
    }
    
    private func setupHeader() {
        header.setTitle("GOALS", for: .normal)
        header.titleLabel?.textColor = .dark
        header.setTitleColor(.dark, for: .normal)
        header.titleLabel?.font = UIFont.custom(style: .bold, ofSize: .big)
        header.titleLabel?.sizeToFit()
        header.sizeToFit()
        view.addSubview(header)
        
        // Long press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(headerLongPressHandler(_:)))
        header.addGestureRecognizer(longPressRecognizer)
        header.isUserInteractionEnabled = true
        
        // Layout
        header.translatesAutoresizingMaskIntoConstraints = false
        self.view.clipsToBounds = true
        view.setNeedsLayout()
    }

    private func setupStack() {
        let sideInsets: CGFloat = 40

        stackOfGoalButtons.spacing = 4
        stackOfGoalButtons.alignment = .leading
        stackOfGoalButtons.axis = .vertical
        stackOfGoalButtons.distribution = .equalSpacing
        stackOfGoalButtons.layoutMargins = UIEdgeInsets(top: 0, left: sideInsets, bottom: 0, right: sideInsets)
        stackOfGoalButtons.isLayoutMarginsRelativeArrangement = true
        stackOfGoalButtons.alpha = Constant.alpha.faded
        stackOfGoalButtons.sizeToFit()
        view.addSubview(stackOfGoalButtons)
        
        // Layout
        stackOfGoalButtons.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: header.topAnchor),
            view.leftAnchor.constraint(equalTo: header.leftAnchor),
            view.rightAnchor.constraint(equalTo: header.rightAnchor),
            stackOfGoalButtons.topAnchor.constraint(equalTo: header.bottomAnchor),
            stackOfGoalButtons.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackOfGoalButtons.rightAnchor.constraint(equalTo: view.rightAnchor),
            view.bottomAnchor.constraint(equalTo: stackOfGoalButtons.bottomAnchor),
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
        guard gesture.state == .began else {
            return
        }
        
        let goalPicker = InputViewController(inputStyle: .text)
        goalPicker.delegate = self
        
        navigationController?.pushViewController(goalPicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func goalLongPressHandler(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began, let sender = gesture.view else {
            return
        }
        
        stackOfGoalButtons.removeArrangedSubview(sender)
        sender.removeFromSuperview()
        if let aButton = sender as? GoalButton {
            aButton.deleteFromCoreData()
        }
    }
    
    /// Receives the text from a input view, and uses it to make a goal and append it.
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

