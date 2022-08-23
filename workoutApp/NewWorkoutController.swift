//
//  NewWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class NewWorkoutController: WorkoutController {
    
    // MARK: - Initializer
    
    lazy var footer: ButtonFooter = {
        let f = ButtonFooter(withColor: .akDark)
        f.frame = CGRect(x: 0, y: f.frame.origin.y, width: f.frame.width, height: f.frame.height*2.5)
        f.frame.origin.y = self.view.frame.maxY - f.frame.height
        f.approveButton.addTarget(self, action: #selector(makeWorkoutAndDismissVC), for: .touchUpInside)
        f.approveButton.accessibilityIdentifier = "approve-button"
        f.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        f.cancelButton.accessibilityIdentifier = "cancel-button"
        return f
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        view.backgroundColor = .akLight
        
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
        // Add subviews
        view.addSubview(header)
        view.addSubview(workoutStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(restSelectionBox)
        view.addSubview(exerciseSelecter)
        view.addSubview(footer)
        // TODO: Add timer functionality, and show this box
        restSelectionBox.alpha = 0
    }
    
    @objc private func headerTapHandler() {
        // Make and present an inputViewController
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.setHeader("NAME OF YOUR WORKOUT?")
        workoutNamePicker.delegate = self
        
        stringReceivedHandler = { str in
            self.header.bottomLabel.text = str
        }
        navigationController?.pushViewController(workoutNamePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func makeWorkoutAndDismissVC() {
        // Present error modal if workout contains no exercises
        guard hasExercises else {
            let modal = CustomAlertView(type: .message, messageContent: "Add at least one exercise, please!")
            modal.show(animated: true)
            return
        }
        let workoutName = header.getBottomText()
        DatabaseFacade.makeWorkout(withName: workoutName, workoutStyle: currentWorkoutStyle, muscles: currentMuscles, exercises: currentExercises)
        DatabaseFacade.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
}

