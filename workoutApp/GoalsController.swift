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
    private var goals: [String]?
    private var goalStack: UIStackView = UIStackView()
    
    // MARK: - Initializers
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(withGoals goals: [String]) {
        self.init()
        self.goals = goals
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        if let goals = goals {
            for goalString in goals{
                let newButton = makeGoalButton(withText: goalString)
                goalStack.addArrangedSubview(newButton)
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

        goalStack.spacing = 8
        goalStack.alignment = .leading
        goalStack.axis = .vertical
        goalStack.distribution = .equalSpacing
        goalStack.layoutMargins = UIEdgeInsets(top: 10, left: sideInsets, bottom: 0, right: sideInsets)
        goalStack.isLayoutMarginsRelativeArrangement = true
        goalStack.alpha = Constant.alpha.faded
        view.addSubview(goalStack)
        
        // Layout
        goalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            goalStack.topAnchor.constraint(equalTo: header.bottomAnchor),
            goalStack.leftAnchor.constraint(equalTo: view.leftAnchor),
            goalStack.rightAnchor.constraint(equalTo: view.rightAnchor),
            goalStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
    private func makeGoalButton(withText text: String) -> UIButton {
        let button = GoalsButton(frame: .zero)
        
        guard let label = button.titleLabel else { return button }
        
        // Title Label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.preferredMaxLayoutWidth = 100
        label.lineBreakMode = .byWordWrapping
        
        // Text
        let attributedTitle = GoalsController.bulletedListItem(string: text)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // Layout
        label.sizeToFit()
        button.frame.size = label.frame.size
        button.layoutIfNeeded()
        
        // Long press to delete
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(gestureHandler(_:)))
        button.addGestureRecognizer(longPressRecognizer)
        
        return button
    }
    
    // MARK: - Handlers
    
    @objc private func headerLongPressHandler(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            let newGoal = makeGoalButton(withText: "Let user make a real goal".uppercased())
            goalStack.addArrangedSubview(newGoal)
        }
    }
    
    @objc private func gestureHandler(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            if let sender = gesture.view{
                goalStack.removeArrangedSubview(sender)
                sender.removeFromSuperview()
            }
        }
    }
}

