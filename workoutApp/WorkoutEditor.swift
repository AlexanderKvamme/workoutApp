//
//  WorkoutEditor.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/// Used to edit an existing Workout
class WorkoutEditor: WorkoutController {
    
    // MARK: - Properties
    
    private var currentWorkout: Workout!
    private var initialName: String!
    private var nameWasChanged = false
    private var styleWasChanged = false
    
    private lazy var footer: ButtonFooter = {
        let footer = ButtonFooter(withColor: .akDark)
        footer.frame.origin.y = self.view.frame.maxY - footer.frame.height
        footer.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        footer.approveButton.addTarget(self, action: #selector(approveModifications), for: .touchUpInside)
        return footer
    }()
    
    // MARK: - Initializaer
    
    init(with workout: Workout) {
        super.init(nibName: nil, bundle: nil)
        
        self.currentWorkout = workout
        self.currentMuscles = workout.getMuscles()
        self.currentWorkoutStyle = workout.workoutStyle
        self.initialName = workout.name
        self.currentExercises = workout.getExercises(includeRetired: false)
        
        setupHeader(for: currentWorkout)
        setupTypeSelecter()
        setupMuscleSelecter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .akLight
        addSubviewsAndConstraints()
        
        let btnRefresh = UIBarButtonItem(image: UIImage.chevronLeftSlim17, style: .plain, target: self, action: #selector(pop))
        navigationItem.leftBarButtonItem = btnRefresh
        navigationItem.leftBarButtonItem?.tintColor = .akDark
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.hideIt()
    }
    
    // MARK: Methods
    
    private func addSubviewsAndConstraints() {
        view.addSubview(header)
        view.addSubview(workoutStyleSelecter)
        view.addSubview(muscleSelecter)
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
        let musclesUsed = currentWorkout.getMuscles()
        self.muscleSelecter.setBottomText(musclesUsed.getName())
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
            let modal = CustomAlertView(type: .error, messageContent: errorMessage)
            modal.show(animated: true)
            return
        }
        
        // Save changes made to the workout
        if nameWasChanged {
            let newName = header.getBottomText()
            currentWorkout.setName(newName)
        }
        
        currentWorkout.setStyle(currentWorkoutStyle)
        currentWorkout.setMuscles(currentMuscles)
        currentWorkout.setExercises(currentExercises)
        DatabaseFacade.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
}

