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
    
    private lazy var buttonGrid: ButtonGridView = {
        let items = [
            ButtonGridItem(title: "Muscle", color: .black, font: h2, action: createMuscleTapped),
            ButtonGridItem(title: "Exercise", color: .black, font: h2, action: createExerciseTapped),
            ButtonGridItem(title: "Workout", color: .black, font: h2, action: createWorkoutTapped),
            ButtonGridItem(title: "Skill", color: .black, font: h2, action: createSkillTapped)
        ]
        return ButtonGridView(items: items, buttonsPerRow: 2)
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
        
        view.addSubview(header)
        view.addSubview(buttonGrid)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonGrid.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            buttonGrid.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            buttonGrid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200)
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
