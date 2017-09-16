//
//  WorkoutEditor.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

/// Looks like the NewWorkoutController, but edits an existing Workout
class WorkoutEditor: WorkoutController {
    
    // MARK: - Properties
    
    private var currentWorkout: Workout!
    private var initialName: String!
    private var nameWasChanged = false
    
    private lazy var footer: ButtonFooter = {
        // Footer
        let footer = ButtonFooter(withColor: .darkest)
        footer.frame.origin.y = self.view.frame.maxY - footer.frame.height
        footer.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        footer.approveButton.addTarget(self, action: #selector(approveModifications), for: .touchUpInside)
        return footer
    }()
    
    // MARK: - Initializaer
    
    init(with workout: Workout) {
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
        
        self.currentWorkout = workout
        self.currentMuscle = workout.muscleUsed
        self.currentWorkoutStyle = workout.workoutStyle
        self.initialName = workout.name
        self.currentExercises = workout.getExercises()
        
        setupHeader(for: currentWorkout)
        setupTypeSelecter()
        setupMuscleSelecter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        addSubviewsAndConstraints()
    }
    
    // MARK: Methods
    
    private func addSubviewsAndConstraints() {
        view.addSubview(header)
        view.addSubview(workoutStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(restSelectionBox)
        view.addSubview(exerciseSelecter)
        view.addSubview(footer)
    }
    
    private func setupHeader(for workout: Workout) {
        let currentName = workout.name ?? "OLD NAME"
        header.setTopText(currentName)
        header.setBottomText("NEW NAME")
        header.button.removeTarget(self, action: nil, for: .allEvents)
        header.button.addTarget(self, action: #selector(editName), for: .touchUpInside)
    }
    
    func setupTypeSelecter() {
        let styleName = currentWorkout.workoutStyle?.name ?? "No Style"
        self.workoutStyleSelecter.setBottomText(styleName)
    }
    
    func setupMuscleSelecter() {
        let muscleName = currentWorkout.muscleUsed?.name ?? "No Muscle"
        self.muscleSelecter.setBottomText(muscleName)
    }
    
    @objc private func editName() {
        
        let inputController = InputViewController(inputStyle: .text)
        let nameBeforeChange: String = currentWorkout.name ?? "No Style"
        inputController.setHeader(nameBeforeChange)
        inputController.delegate = self
        
        // Returning string should update exercise and VC header
        stringReceivedHandler = { newName in
            if newName != nameBeforeChange {
                self.header.setBottomText(newName)
                self.nameWasChanged = true
            }
        }
        
        navigationController?.pushViewController(inputController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func approveModifications() {
        
        // Present error modal if workout contains no exercises
        guard hasExercises else {
            let errorMessage = "Add at least one exercise, please!"
            let modal = CustomAlertView(type: .message, messageContent: errorMessage)
            modal.show(animated: true)
            return
        }
        
        // Save changes made to the workout
        if nameWasChanged {
            let newName = header.getBottomText()
            currentWorkout.setName(newName)
        }
        
        currentWorkout.setStyle(currentWorkoutStyle)
        currentWorkout.setMuscle(currentMuscle)
        currentWorkout.setExercises(currentExercises)
        DatabaseFacade.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
}

