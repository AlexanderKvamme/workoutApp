//
//  NewWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

class NewWorkoutController: WorkoutController {
    
    // MARK: - Initializer
    
    lazy var footer: ButtonFooter = {
        // Footer
        let footer = ButtonFooter(withColor: .darkest)
        footer.frame.origin.y = self.view.frame.maxY - footer.frame.height
        footer.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
        footer.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return footer
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
        
        currentMuscles = [DatabaseFacade.defaultMuscle]
        currentWorkoutStyle = DatabaseFacade.defaultWorkoutStyle
        
        header.button.addTarget(self, action: #selector(headerTapHandler), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        addSubviewsAndConstraints()
    }
    
    // MARK: Methods
    
    private func addSubviewsAndConstraints() {
        view.backgroundColor = .light
        
        view.addSubview(header)
        view.addSubview(workoutStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(restSelectionBox)
        view.addSubview(exerciseSelecter)
        view.addSubview(footer)
    }
    
    @objc private func headerTapHandler() {
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.setHeader("NAME OF YOUR WORKOUT?")
        workoutNamePicker.delegate = self
        
        stringReceivedHandler = { s in
            self.header.bottomLabel.text = s
        }
        
        navigationController?.pushViewController(workoutNamePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func approveAndDismissVC() {
        // Present error modal if workout contains no exercises
        guard hasExercises else {
            let errorMessage = "Add at least one exercise, please!"
            let modal = CustomAlertView(type: .message, messageContent: errorMessage)
            modal.show(animated: true)
            return
        }
        
        let workoutName = header.getBottomText()
        DatabaseFacade.makeWorkout(withName: workoutName, workoutStyle: currentWorkoutStyle, muscles: currentMuscles, exercises: currentExercises)
        DatabaseFacade.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
}

