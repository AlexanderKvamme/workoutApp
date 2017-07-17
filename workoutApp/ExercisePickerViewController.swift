//
//  WorkoutPickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// TODO: - Add "newButton" to the pickerview

class ExercisePickerViewController: PickerViewController, NewExerciseReceiver {

    var selectedExerciseNames = [String]() {
        didSet {
            print("did set to \(selectedExerciseNames)")
        }
    }
    var selectedIndexPaths = [IndexPath]()
    var currentlyDisplayedMuscle: Muscle! // Store during init, used to refresh the picker after returning from making new exercise
    
    weak var exerciseDelegate: isExerciseNameReceiver?
    
    // ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        displayExercisesForMuscle(currentlyDisplayedMuscle)
        
        // Preselect
        for name in selectedExerciseNames {
            selectRow(withString: name)
        }
        table.reloadData()
    }
    
    // Initializer that takes a Muscle and sets the pickerVC to display exercises of this muscle

    init(forMuscle muscle: Muscle) {
        currentlyDisplayedMuscle = muscle
        
        let exercisesUsingSelectedMuscle = DatabaseFacade.fetchExercises(usingMuscle: muscle)
        
        var selectionChoices = [String]()
        if let exercisesUsingSelectedMuscle = exercisesUsingSelectedMuscle {
            for exercise in exercisesUsingSelectedMuscle {
                if let name = exercise.name {
                    selectionChoices.append(name)
                }
            }
        }
        
        // Pass on selectionChoices to super.init
        super.init(withChoices: selectionChoices, withPreselection: nil)
        
        hidesBottomBarWhenPushed = true
        addNewExerciseButton()
    }
    
    // Initialize with Muscle

    convenience init(forMuscle muscle: Muscle, withMultiplePreselections preselections: [String]?) {
        self.init(forMuscle: muscle)
        
        if let preselections = preselections {
            self.selectedExerciseNames = preselections
        }
    }
    
    // MARK: - Delegate methods
    
    func receiveNewExercise(_ exercise: Exercise) {
        // FIXME: - Update tableview to welcome this new exercise
        print("BEFORE RECEIVING")
        print("receiveNewExercise - selectionChoices : ", selectionChoices)
        print("receiveNewExercise - selectedExerciseNames : ", selectedExerciseNames)
        print("receiveNewExercise - selectedIndexPaths : ", selectedIndexPaths)
        
        if let name = exercise.name {
            print("*received \(name)*")
            selectionChoices.append(name)
            selectedExerciseNames.append(name)
            selectRow(withString: name)
        }
        print("AFTER RECEIVING:")
        print("receiveNewExercise - selectionChoices : ", selectionChoices)
        print("receiveNewExercise - selectedExerciseNames : ", selectedExerciseNames)
        print("receiveNewExercise - selectedIndexPaths : ", selectedIndexPaths)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func displayExercisesForMuscle(_ muscle: Muscle) {
        // fetches all exercises for this muscle, replaces selectionChoices with them, and reloads table
        guard let exercisesForThisMuscle = DatabaseFacade.fetchExercises(usingMuscle: muscle) else {
            print("Could not fetch exercises for \(String(describing: muscle.name))")
            return
        }
        
        // clear array to keep array uppdated
        selectedIndexPaths.removeAll()
        selectionChoices.removeAll()
        
        for e in exercisesForThisMuscle {
            if let name = e.name {
                selectionChoices.append(name)
            }
        }
        table.reloadData()
    }
    
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
        
        // Let taps present newExerciseController
        button.addTarget(self, action: #selector(newExerciseTapHandler), for: .touchUpInside)
    }
    
    @objc private func newExerciseTapHandler() {
    
        let nec = NewExerciseController(withPreselectedMuscle: currentlyDisplayedMuscle)
        nec.exercisePickerDelegate = self
        
        // Make presentable outside of navigationController, used for testing
        if let navigationController = navigationController {
            navigationController.pushViewController(nec, animated: true)
        } else {
            present(nec, animated: true, completion: nil)
        }
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
        // Takes a cell, and makes it look selected or not depending on if its located in the cache of selected indexPaths
        if selectedIndexPaths.contains(indexPath) {
            cell.label.font = fontWhenSelected
            cell.label.textColor = textColorWhenSelected
        } else {
            cell.label.font = fontWhenDeselected
            cell.label.textColor = textColorWhenDeselected
        }
    }
    
    override func selectRow(withString string: String) {
        // looks through the possible choices, finds the index of the one you want to select, retrieves the corresponding indexPath, and selects that indexPath
        if let indexOfElement = selectionChoices.index(of: string) {
            let indexPath = IndexPath(row: indexOfElement, section: 0)
            table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            selectedIndexPaths.append(indexPath)
        } else {
            print("ERROR could not find and select row")
        }
    }
    
    // Count selected rows to return to NewWorkoutViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        
        // if tapped indexPath is already contained, remove from cache and unselect it
        if selectedIndexPaths.contains(indexPath){
            if let location = selectedIndexPaths.index(of: indexPath){
                print("location: ", location)
                print("selIndexPaths: ", selectedIndexPaths)
                print("selectedExerciseNames: ", selectedExerciseNames)
                
                selectedIndexPaths.remove(at: location)
                selectedExerciseNames.remove(at: location)
            }
        } else {
            // is not already contained in the array, so append and make it look selected
            selectedIndexPaths.append(indexPath)
            selectedExerciseNames.append(selectionChoices[indexPath.row])
        }
        configure(selectedCell, forIndexPath: indexPath)
    }
    
    // MARK: - Exit
    
    override func confirmAndDismiss() {
        if selectedExerciseNames.count > 0 {
            let selectedWorkoutCount = String(selectedExerciseNames.count)
            delegate?.receive(selectedWorkoutCount)
            exerciseDelegate?.receiveExerciseNames(selectedExerciseNames)
            
        } else {
            delegate?.receive("0")
        }
        navigationController?.popViewController(animated: false)
    }
}

