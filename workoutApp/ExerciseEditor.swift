//
//  ExerciseEditor.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Class

final class ExerciseEditor: UIViewController {

    // MARK: - Properties
    
    fileprivate var exercise: Exercise!
    fileprivate var currentExerciseStyle: ExerciseStyle!
    fileprivate var currentMuscle: Muscle!
    
    // Components
    fileprivate var header: TwoRowHeader!
    fileprivate var muscleSelecter: PickerLabelStack!
    fileprivate var exerciseStyleSelecter: PickerLabelStack!
    
    private var deletionBox: DeletionBox!
    private var footer: ButtonFooter!
    
    // Delegates
    var stringReceivedHandler: ((String) -> Void) = { _ in }
    weak var editorDataSource: ExerciseEditorDataSource?
    
    // MARK: - Initializers
    
    init(for exercise: Exercise) {
        super.init(nibName: nil, bundle: nil)
        self.exercise = exercise
        self.currentExerciseStyle = exercise.style
        self.currentMuscle = exercise.musclesUsed
        
        print("\nexercise to edit: ", exercise)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        
        // add components
        addHeader(forExercise: self.exercise)
        addTypeSelecter()
        addMuscleSelecter()
        addDeletionBox()
        addFooter()
        
        setLayout()
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Methods
    
    // Header

    private func addHeader(forExercise exercise: Exercise) {
        self.header = TwoRowHeader(topText: exercise.name ?? "HAD NO NAME", bottomText: "NEW NAME")
        view.addSubview(header)

        header.button.addTarget(self, action: #selector(editName), for: .touchUpInside)
    }
    
    // Delete button
    
    private func addDeletionBox() {
        self.deletionBox = DeletionBox(withText: "DELETE")
        view.addSubview(deletionBox)
   
        deletionBox.button.addTarget(self, action: #selector(deleteExercise), for: .touchUpInside)
    }
    
    // Layout
    
    private func setLayout() {
        // Header
        self.header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([header.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                                     header.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
                                     ])
        
        // Type
        self.exerciseStyleSelecter.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([exerciseStyleSelecter.topAnchor.constraint(equalTo: header.bottomAnchor),
                                     exerciseStyleSelecter.leftAnchor.constraint(equalTo: view.leftAnchor)])
        
        // Muscle
        self.muscleSelecter.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([muscleSelecter.topAnchor.constraint(equalTo: header.bottomAnchor),
                                     muscleSelecter.rightAnchor.constraint(equalTo: view.rightAnchor)])
        
        // Deletion
        deletionBox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([deletionBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     deletionBox.topAnchor.constraint(equalTo: muscleSelecter.bottomAnchor, constant: 20)])
        
        // Footer
        self.footer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     footer.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    func deleteExercise() {
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
        let inp = InputViewController(inputStyle: .text)
        inp.delegate = self
        
        // Returning string should update exercise and VC header
        stringReceivedHandler = { str in
            self.exercise.name = str
            self.header.setBottomText(str)
        }
        
        navigationController?.pushViewController(inp, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    // MARK: Style and muscle
    
    private func addTypeSelecter() {
        // Style
        guard let styleName = exercise.style?.name else {
            print("ERROR: exercise had no styleName")
            fatalError()
            return
        }
        // Type selecter
        self.exerciseStyleSelecter = PickerLabelStack(topText: "TYPE", bottomText: styleName)
        view.addSubview(exerciseStyleSelecter)

        exerciseStyleSelecter.button.addTarget(self, action: #selector(editExerciseStyle), for: .touchUpInside)
    }
    
    private func addMuscleSelecter() {
        guard let muscleName = exercise.musclesUsed?.name else {
            return
        }
        // Muscle selecter
        self.muscleSelecter = PickerLabelStack(topText: "MUSCLE", bottomText: muscleName)
        view.addSubview(muscleSelecter)
        
        muscleSelecter.button.addTarget(self, action: #selector(editMuscle), for: .touchUpInside)
    }
    
    // MARK: Footer
    
    private func addFooter() {
        footer = ButtonFooter(withColor: .dark)
        view.addSubview(footer)

        footer.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        footer.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
    }
    
    @objc private func dismissVC() {
        // dismiss without committing changes to core data
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    @objc private func approveAndDismissVC() {
        // Push changes to core data
        exercise.name = header.getBottomText()
        exercise.style = currentExerciseStyle
        print("setting : ", exercise.style)
        print("style : ", currentExerciseStyle)
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
            currentExerciseStyle = object as? ExerciseStyle
            exerciseStyleSelecter.setBottomText(object.name!)
        default:
            print("Received a pickable not yet implemented")
        }
    }
}

extension ExerciseEditor: isStringReceiver {
    // cannot store receiver in extension
}

