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
class CreatorScreen: SelectionViewController {
        
    init() {
        super.init(header: AnimatedScreenHeader(header: "Create", subheader: " something "))
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        // No distribution - let buttons size themselves
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        // No distribution - let buttons size themselves
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bottomRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        // No distribution - let buttons size themselves
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var createWorkoutButton: FormFittingActionButton = {
        return FormFittingActionButton(
            title: "Workout",
            icon: "",
            color: .black,
            font: h2,
            action: createWorkoutTapped
        )
    }()
    
    private lazy var createExerciseButton: FormFittingActionButton = {
        return FormFittingActionButton(
            title: "Exercise",
            icon: "",
            color: .black,
            font: h2,
            action: createExerciseTapped
        )
    }()
    
    private lazy var createMuscleButton: FormFittingActionButton = {
        return FormFittingActionButton(
            title: "Muscle",
            icon: "",
            color: .black,
            font: h2,
            action: createMuscleTapped
        )
    }()
    
    private lazy var createSkillButton: FormFittingActionButton = {
        return FormFittingActionButton(
            title: "Skill",
            icon: "",
            color: .black,
            font: h2,
            action: createSkillTapped
        )
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
        header.play()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .akLight
        navigationItem.title = "Creator"
        
        // Add subviews
        view.addSubview(header)
        view.addSubview(containerStackView)
        
        // Arrange buttons in rows (form-fitting sizes)
        topRowStackView.addArrangedSubview(createMuscleButton)
        topRowStackView.addArrangedSubview(createExerciseButton)
        
        bottomRowStackView.addArrangedSubview(createWorkoutButton)
        bottomRowStackView.addArrangedSubview(createSkillButton)
        
        // Add rows to container
        containerStackView.addArrangedSubview(topRowStackView)
        containerStackView.addArrangedSubview(bottomRowStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view constraints - positioned towards bottom
            containerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            containerStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200)
        ])
    }
    
    // MARK: - Actions
    
    private func createWorkoutTapped() {
        let workoutCreator = NewWorkoutController()
        navigationController?.pushViewController(workoutCreator, animated: true)
    }
    
    private func createMuscleTapped() {
        let muscleCreator = MuscleCreatorScreen()
        navigationController?.pushViewController(muscleCreator, animated: true)
    }
    
    private func createSkillTapped() {
        let skillCreator = SkillCreatorScreen()
        navigationController?.pushViewController(skillCreator, animated: true)
    }
    
    private func createExerciseTapped() {
        let newExerciseController = ExerciseCreator(withPreselectedMuscle: [], showBackButton: true)
        newExerciseController.styleBackButton()
        
        newExerciseController.navigationController?.setNavigationBarHidden(false, animated: true)
        newExerciseController.navigationController?.navigationItem.hidesBackButton = false
        navigationController?.pushViewController(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
}
