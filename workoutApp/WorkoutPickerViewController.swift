//
//  WorkoutPickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// TODO: - Add "newButton" to the pickerview

class ExercisePickerViewController: PickerViewController {

    var selectedExerciseNames = [String]()
    var selectedIndexPaths = [IndexPath]()
    
    weak var exerciseDelegate: isExerciseNameReceiver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for name in selectedExerciseNames {
            selectRow(withString: name)
        }
    }
    
    // Override initializer to take an [String] instead of just String.
    
    override init(withChoices choices: [String], withPreselection preselection: String?) {
        super.init(withChoices: choices, withPreselection: preselection)
        selectionChoices = choices
        hidesBottomBarWhenPushed = true
        addNewExerciseButton()
    }

    // Initializer with multiple preselections
    
    convenience init(choices: [String], withMultiplePreselections preselections: [String]?) {
        self.init(withChoices: choices, withPreselection: nil)
        
        if let preselections = preselections {
            self.selectedExerciseNames = preselections
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func addNewExerciseButton() {
        
        let width: CGFloat = 25
        
        let img = UIImage(named: "newButton")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.tintColor = UIColor.faded
        button.alpha = Constant.alpha.faded
        button.setImage(img, for: .normal)
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: header.topLabel.bottomAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: width),
            button.widthAnchor.constraint(equalToConstant: width),
            ])
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
            print(selectionChoices)
        }
    }
    
    // Count selected rows to return to NewWorkoutViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        
        // if tapped indexPath is already contained, remove from cache and unselect it
        if selectedIndexPaths.contains(indexPath){
            if let location = selectedIndexPaths.index(of: indexPath){
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

