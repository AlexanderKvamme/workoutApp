//
//  WorkoutPickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit


class ExercisePickerViewController: PickerViewController<Exercise>, NewExerciseReceiver {
    
    // MARK: - Properties
    
    var selectedExercises = [Exercise]()
    var selectedIndexPaths = [IndexPath]()
    var currentlyDisplayedMuscle: Muscle! // used to refresh the picker after returning from making new exercise
    
    // Delegates
    weak var exerciseDelegate: isExerciseReceiver?
    
    // MARK: - Initializers
    
    init(forMuscle muscle: Muscle, withPreselectedExercises preselectedExercises: [Exercise]?) {
        currentlyDisplayedMuscle = muscle
        
        let exercises = DatabaseFacade.fetchExercises(usingMuscle: muscle)!
        
        super.init(withPicksFrom: exercises, withPreselection: nil)

        // Choices
        selectionChoices = [Exercise]()
        selectionChoices = exercises
      
        // Preselect
        if let preselections = preselectedExercises {
            self.selectedExercises = preselections
        }
        addNewExerciseButton()
    }
    
    // MARK: - Life Cycle
    
    // ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        hidesBottomBarWhenPushed = true
        
        // Preselect
        for exercise in selectedExercises {
            selectExercise(exercise)
        }
        table.reloadData()
    }
    
    // MARK: - Methods
    
    // MARK: Delegate methods
    
    func receiveNewExercise(_ exercise: Exercise) {
        
        guard exercise.musclesUsed == currentlyDisplayedMuscle else {
            // only add if musclegroup matches the workouts musclegroup
            // TODO: Show modal error
            return
        }
        selectionChoices.append(exercise)
        selectedExercises.append(exercise)
        selectExercise(exercise)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helper methods
    
    func addNewExerciseButton() {
        let width: CGFloat = 25
        
        let img = UIImage(named: "newButton")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.tintColor = UIColor.faded
        button.alpha = Constant.alpha.faded
        button.setImage(img, for: .normal)
        view.addSubview(button)
        
        // Layout
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: header.topLabel.bottomAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: width),
            button.widthAnchor.constraint(equalToConstant: width),
            ])
        
        // On tap: present newExerciseController
        button.addTarget(self, action: #selector(newExerciseTapHandler), for: .touchUpInside)
    }
    
    @objc private func newExerciseTapHandler() {
    
        let newExerciseController = NewExerciseController(withPreselectedMuscle: currentlyDisplayedMuscle)
        newExerciseController.exercisePickerDelegate = self
        
        // Make presentable outside of navigationController, used for testing
        if let navigationController = navigationController {
            navigationController.pushViewController(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
        } else {
            present(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn, completion: nil)
        }
    }
    
    // MARK: Tableview Delegate Methods
    
    /// Takes a cell, and makes it look selected or not depending on if its located in the cache of selected indexPaths
    override func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            cell.label.font = fontWhenSelected
            cell.label.textColor = textColorWhenSelected
        } else {
            cell.label.font = fontWhenDeselected
            cell.label.textColor = textColorWhenDeselected
        }
    }
    
    private func selectExercise( _ exerciseToSelect: Exercise) {

        if let indexOfElement = selectionChoices.index(of: exerciseToSelect) {
            let indexPath = IndexPath(row: indexOfElement, section: 0)
            table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            selectedIndexPaths.append(indexPath)
        }
    }
    
    // Count selected rows to return to NewWorkoutViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // if tapped indexPath is already contained, remove from cache and unselect it
        if selectedIndexPaths.contains(indexPath){
            // deselect
            if let indexOfExercise = selectedIndexPaths.index(of: indexPath){
                selectedIndexPaths.remove(at: indexOfExercise)
                selectedExercises.remove(at: indexOfExercise)
            }
        } else {
            // exercise is not yet contained in the array, so append and make it look selected
            selectedIndexPaths.append(indexPath)
            selectedExercises.append(selectionChoices[indexPath.row])
        }
        
        // configure to look selected/deselected
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        configure(selectedCell, forIndexPath: indexPath)
    }
    
    // MARK: Exit methods
    
    override func confirmAndDismiss() {
        exerciseDelegate?.receive(selectedExercises)
        
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

