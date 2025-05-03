//
//  CreatorScreenPicker.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 28/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import AKKIT
import UIKit

/// Screen that allows the user to select what type of entity to create
class CreatorScreen: UIViewController {
    
    // MARK: - Properties
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "CREATE NEW"
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createWorkoutButton: UIButton = {
        return createButton(withTitle: "Workout", action: #selector(createWorkoutTapped))
    }()
    
    private lazy var createMuscleButton: UIButton = {
        return createButton(withTitle: "Muscle", action: #selector(createMuscleTapped))
    }()
    
    private lazy var createExerciseButton: UIButton = {
        return createButton(withTitle: "Exercise", action: #selector(createExerciseTapped))
    }()
    
    private lazy var createSkillButton: UIButton = {
        return createButton(withTitle: "Skill", action: #selector(createSkillTapped))
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        globalTabBar.showIt()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .akLight
        navigationItem.title = "Creator"
        
        // Add subviews
        view.addSubview(headerLabel)
        view.addSubview(stackView)
        
        // Add buttons to stack view
        stackView.addArrangedSubview(createWorkoutButton)
        stackView.addArrangedSubview(createExerciseButton)
        stackView.addArrangedSubview(createMuscleButton)
        stackView.addArrangedSubview(createSkillButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header label constraints
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func createButton(withTitle title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.custom(style: .bold, ofSize: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
    // MARK: - Actions
    
    @objc private func createWorkoutTapped() {
        let workoutCreator = NewWorkoutController()
        navigationController?.pushViewController(workoutCreator, animated: true)
    }
    
    @objc private func createMuscleTapped() {
        
        let muscleCreator = MuscleCreatorScreen()
        navigationController?.pushViewController(muscleCreator, animated: true)
    }
    
    @objc private func createSkillTapped() {
        let skillCreator = SkillCreatorScreen()
        navigationController?.pushViewController(skillCreator, animated: true)
    }
    
    @objc private func createExerciseTapped() {
        let newExerciseController = ExerciseCreator(withPreselectedMuscle: [], showBackButton: true)
        newExerciseController.styleBackButton()
        
        newExerciseController.navigationController?.setNavigationBarHidden(false, animated: true)
        newExerciseController.navigationController?.navigationItem.hidesBackButton = false
        navigationController?.pushViewController(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
}

