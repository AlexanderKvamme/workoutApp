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
    
    private lazy var createTypeButton: UIButton = {
        return createButton(withTitle: "Type", action: #selector(createTypeTapped))
    }()
    
    private lazy var createMuscleButton: UIButton = {
        return createButton(withTitle: "Muscle/Skill", action: #selector(createMuscleTapped))
    }()
    
    private lazy var createExerciseButton: UIButton = {
        return createButton(withTitle: "Exercise", action: #selector(createExerciseTapped))
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
        view.backgroundColor = .white
        navigationItem.title = "Creator"
        
        // Add subviews
        view.addSubview(headerLabel)
        view.addSubview(stackView)
        
        // Add buttons to stack view
        stackView.addArrangedSubview(createWorkoutButton)
        stackView.addArrangedSubview(createTypeButton)
        stackView.addArrangedSubview(createMuscleButton)
        stackView.addArrangedSubview(createExerciseButton)
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
//        let creatorScreen = CreatorScreen()
//        creatorScreen.currentMuscles = []  // Initialize with empty array
//        creatorScreen.currentWorkoutStyle = DatabaseFacade.fetchWorkoutStyles().first
//        navigationController?.pushViewController(creatorScreen, animated: true)
    }
    
    @objc private func createTypeTapped() {
        let typeCreator = TypeCreatorScreen()
        navigationController?.pushViewController(typeCreator, animated: true)
    }
    
    @objc private func createMuscleTapped() {
        let muscleCreator = MuscleCreatorScreen()
        navigationController?.pushViewController(muscleCreator, animated: true)
    }
    
    @objc private func createExerciseTapped() {
        let exerciseCreator = ExerciseCreatorScreen()
        navigationController?.pushViewController(exerciseCreator, animated: true)
    }
}

// Placeholder classes for the different creator screens
// You'll need to implement these separately

class TypeCreatorScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Create Type"
    }
}

class MuscleCreatorScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Create Muscle/Skill"
    }
}

class ExerciseCreatorScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Create Exercise"
    }
}
