//
//  ExerciseEditor.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: Class

final class ExerciseEditor: UIViewController {
    
    // MARK: - Properties
    
    fileprivate var exercise: Exercise
    fileprivate var currentExerciseStyle: ExerciseStyle
    fileprivate var currentMuscles: [Muscle]
    fileprivate var currentMeasurementStyle: MeasurementStyle
    fileprivate var initialName: String
    fileprivate var didChangeName = false

    // Components
    fileprivate var header: TwoRowHeader = {
        let headerLabelStack = TwoRowHeader(topText: "Current exercise name", bottomText: "NEW NAME")
        headerLabelStack.button.addTarget(self, action: #selector(editName), for: .touchUpInside)
        
        return headerLabelStack
    }()
    
    fileprivate var muscleSelecter: PickerLabelStack = {
        let selecter = PickerLabelStack(topText: "MUSCLE", bottomText: "NAME")
        selecter.button.addTarget(self, action: #selector(editMuscle), for: .touchUpInside)
        
        return selecter
    }()
    
    fileprivate var exerciseStyleSelecter: PickerLabelStack = {
        let selecter = PickerLabelStack(topText: "STYLE", bottomText: "NAME")
        selecter.button.addTarget(self, action: #selector(editExerciseStyle), for: .touchUpInside)
        
        return selecter
    }()
    
    fileprivate var measurementStyleSelecter: PickerLabelStack = {
        let selecter = PickerLabelStack(topText: "MEASUREMENT", bottomText: "NAME")
        selecter.button.addTarget(self, action: #selector(editMeasurementStyle), for: .touchUpInside)
        
        return selecter
    }()
    
    private var deletionBox: DeletionBox = {
        let deletionBox = DeletionBox(withText: "DELETE")
        deletionBox.button.addTarget(self, action: #selector(deleteExercise), for: .touchUpInside)
        
        return deletionBox
    }()
    
    private var footer: ButtonFooter = {
        let footer = ButtonFooter(withColor: .dark)
        footer.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        footer.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
        return footer
    }()
    
    // Delegates
    var stringReceivedHandler: ((String) -> Void) = { _ in }
    weak var editorDataSource: ExerciseEditorDataSource?
    
    // MARK: - Initializers
    
    init(for exercise: Exercise) {
        
        self.exercise = exercise
        self.currentExerciseStyle = exercise.getExerciseStyle()
        self.currentMeasurementStyle = exercise.getMeasurementStyle()
        self.currentMuscles = exercise.getMuscles()
        self.initialName = exercise.getName()
        
        super.init(nibName: nil, bundle: nil)
        
        // Set labels with current exercise/muscle/styletM        header.setTopText(exercise.getName())
        muscleSelecter.setBottomText(currentMuscles.getName())
        exerciseStyleSelecter.setBottomText(currentExerciseStyle.getName())
        measurementStyleSelecter.setBottomText(currentMeasurementStyle.getName())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        
        addSubViewsAndConstraints()
    }
    
    // MARK: - Methods
    private func addSubViewsAndConstraints() {
        
        view.addSubview(header)
        view.addSubview(exerciseStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(measurementStyleSelecter)
        view.addSubview(deletionBox)
        view.addSubview(footer)
        
        // Header
        self.header.translatesAutoresizingMaskIntoConstraints = false
        self.exerciseStyleSelecter.translatesAutoresizingMaskIntoConstraints = false
        self.muscleSelecter.translatesAutoresizingMaskIntoConstraints = false
        self.measurementStyleSelecter.translatesAutoresizingMaskIntoConstraints = false
        self.deletionBox.translatesAutoresizingMaskIntoConstraints = false
        self.footer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            
            // Type
            exerciseStyleSelecter.topAnchor.constraint(equalTo: header.bottomAnchor),
            exerciseStyleSelecter.leftAnchor.constraint(equalTo: view.leftAnchor),
            
            // Muscle
            muscleSelecter.topAnchor.constraint(equalTo: header.bottomAnchor),
            muscleSelecter.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            // Measurement style
            measurementStyleSelecter.topAnchor.constraint(equalTo: exerciseStyleSelecter.bottomAnchor),
            measurementStyleSelecter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Deletion
            deletionBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deletionBox.topAnchor.constraint(equalTo: measurementStyleSelecter.bottomAnchor, constant: 20),
            
            // Footer
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
    
    // MARK: Data management
    
    @objc private func deleteExercise() {
        editorDataSource?.removeFromDataSource(exercise: exercise)
        DatabaseFacade.delete(exercise)
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    @objc private func editMuscle() {
        print("will edit muscle")
        let musclePicker = MusclePickerController(withPreselectedMuscles: currentMuscles)
        musclePicker.muscleReceiver = self
        print("gonna show musclepicker")
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func editExerciseStyle() {
        let allStyles = DatabaseFacade.getExerciseStyles()
        print("allStles: ", allStyles)
        let stylePicker = PickerController(withPicksFrom: allStyles, withPreselection: exercise.style!)
        stylePicker.pickableReceiver = self
        navigationController?.pushViewController(stylePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func editMeasurementStyle() {
        print("would edit MeasurementStyle")
        let allMeasurementStyles = DatabaseFacade.fetchMeasurementStyles()
        let measurementStylePicker = PickerController(withPicksFrom: allMeasurementStyles, withPreselection: exercise.measurementStyle!)
        measurementStylePicker.pickableReceiver = self
        
        navigationController?.pushViewController(measurementStylePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func editName() {
        let inputController = InputViewController(inputStyle: .text)
        inputController.delegate = self
        
        // Returning string should update exercise and VC header
        stringReceivedHandler = { str in
            self.exercise.name = str
            self.header.setBottomText(str)
            
            if str != self.initialName {
                self.didChangeName = true
            }
        }
        
        navigationController?.pushViewController(inputController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    // MARK: Exit methods
    
    @objc private func dismissVC() {
        // dismiss without committing changes to core data
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    @objc private func approveAndDismissVC() {
        // Push changes to core data
        if self.didChangeName {
            exercise.name = header.getBottomText()
        }
        
        exercise.style = currentExerciseStyle
        exercise.setMuscles(currentMuscles)
        exercise.measurementStyle = currentMeasurementStyle
        DatabaseFacade.saveContext()
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

extension ExerciseEditor: PickableReceiver {
    func receive(pickable: PickableEntity) {
        
        // update current exercise with the new object
        switch pickable {
        case is ExerciseStyle:
            guard let receivedExerciseStyle = pickable as? ExerciseStyle else { fatalError() }
            currentExerciseStyle = receivedExerciseStyle
            exerciseStyleSelecter.setBottomText(receivedExerciseStyle.getName())
        case is MeasurementStyle:
            guard let receivedMeasurementStyle = pickable as? MeasurementStyle else { fatalError() }
            currentMeasurementStyle = receivedMeasurementStyle
            measurementStyleSelecter.setBottomText(receivedMeasurementStyle.getName())
        default:
            preconditionFailure("Received a pickable not yet implemented")
        }
    }
}

extension ExerciseEditor: MuscleReceiver {
    func receive(muscles: [Muscle]) {
        currentMuscles = muscles
        muscleSelecter.setBottomText(muscles.getName())
        print("received muscles: ", muscles)
    }
}

extension ExerciseEditor: isStringReceiver {
    // cannot store receiver in extension
}

