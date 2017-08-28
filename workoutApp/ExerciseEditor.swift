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
    
    fileprivate var exercise: Exercise!
    fileprivate var exerciseStyle: ExerciseStyle!
    fileprivate var currentMuscle: Muscle!
    fileprivate var initialName: String!
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
        let selector = PickerLabelStack(topText: "TYPE", bottomText: "NAME")
        selector.button.addTarget(self, action: #selector(editExerciseStyle), for: .touchUpInside)
        
        return selector
    }()
    
    private var deletionBox: DeletionBox = {
        let deletionBox = DeletionBox(withText: "DELETE")
        deletionBox.button.addTarget(self, action: #selector(deleteExercise), for: .touchUpInside)
        
        return deletionBox
    }()
    
    private var footer: ButtonFooter = {
        let f = ButtonFooter(withColor: .dark)
        f.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        f.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
        
        return f
    }()
    
    // Delegates
    var stringReceivedHandler: ((String) -> Void) = { _ in }
    weak var editorDataSource: ExerciseEditorDataSource?
    
    // MARK: - Initializers
    
    init(for exercise: Exercise) {
        super.init(nibName: nil, bundle: nil)
        self.exercise = exercise
        self.exerciseStyle = exercise.style
        self.currentMuscle = exercise.musclesUsed
        self.initialName = exercise.name
        
        guard let exerciseName = exercise.name, let muscleName = currentMuscle.name, let exerciseStyleName = exerciseStyle.name else {
            return
        }
        
        // Set labels with current exercise/muscle/style
        header.setTopText(exerciseName)
        muscleSelecter.setBottomText(muscleName)
        exerciseStyleSelecter.setBottomText(exerciseStyleName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        
        addSubViewsAndConstraints()
        
        view.layoutIfNeeded() // WHAT?
    }
    
    // MARK: - Methods
    private func addSubViewsAndConstraints() {
        
        view.addSubview(header)
        view.addSubview(deletionBox)
        view.addSubview(exerciseStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(footer)
        
        // Header
        self.header.translatesAutoresizingMaskIntoConstraints = false
        self.exerciseStyleSelecter.translatesAutoresizingMaskIntoConstraints = false
        self.muscleSelecter.translatesAutoresizingMaskIntoConstraints = false
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
            
            // Deletion
            deletionBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deletionBox.topAnchor.constraint(equalTo: muscleSelecter.bottomAnchor, constant: 20),
            
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
        let allMuscles = DatabaseFacade.fetchMuscles()
        let musclePicker = PickerController(withPicksFrom: allMuscles, withPreselection: exercise.musclesUsed!)
        musclePicker.pickableReceiver = self
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func editExerciseStyle() {
        let allStyles = DatabaseFacade.fetchExerciseStyles()
        let stylePicker = PickerController(withPicksFrom: allStyles, withPreselection: exercise.style!)
        stylePicker.pickableReceiver = self
        navigationController?.pushViewController(stylePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
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
        
        exercise.style = exerciseStyle
        exercise.musclesUsed = currentMuscle
        DatabaseFacade.saveContext()
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

extension ExerciseEditor: PickableReceiver {
    func receivePickable(_ object :PickableEntity) {
        // update current exercise with the new object
        switch object {
        case is Muscle:
            currentMuscle = object as? Muscle
            muscleSelecter.setBottomText(object.name!)
        case is ExerciseStyle:
            exerciseStyle = object as? ExerciseStyle
            exerciseStyleSelecter.setBottomText(object.name!)
        default:
            print("Received a pickable not yet implemented")
        }
    }
}

extension ExerciseEditor: isStringReceiver {
    // cannot store receiver in extension
}

