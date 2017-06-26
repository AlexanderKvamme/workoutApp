//
//  WorkoutPickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class WorkoutPickerViewController: PickerViewController {

    var numberOfSelectedWorkouts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            cell.label.font = fontWhenSelected
            cell.label.textColor = textColorWhenSelected
        } else {
//            cell.label.font = fontWhenDeselected
//            cell.label.textColor = textColorWhenDeselected
        }
    }
    
    // Count selected rows to return to NewWorkoutViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
            numberOfSelectedWorkouts -= 1
        } else {
            // remove previous selection
//            if let previousSelectedIndexPath = selectedIndexPath {
//                if let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath) as? PickerCell {
//                    configure(previousSelectedCell, forIndexPath: indexPath)
//                }
//            }
            // update selection
            selectedIndexPath = indexPath
        }
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        configure(selectedCell, forIndexPath: indexPath)
        currentlySelectedString = selectedCell.label.text
    }
    
    
    override func confirmAndDismiss() {
        if let currentlySelectedString = currentlySelectedString {
            delegate?.receive(currentlySelectedString)
        } else {
            delegate?.receive("NORMAL")
        }
        navigationController?.popViewController(animated: false)
    }
    
}
