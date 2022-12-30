//
//  ExerciseCollectionViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class LiftCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var overlayingButton: UIButton!
    var repsField: UITextField!
    var isPerformed = false
    var initialRepValue: String {
        // Fetches last accepted Repvalue
        guard let indexPath = superTableCell.collectionView.indexPath(for: self) else { return "-2" }
        let valueFromDatasource = superTableCell.liftsToDisplay[indexPath.row].reps
        return String(valueFromDatasource)
    }
    
    weak var superTableCell: ExerciseCellBaseClass!
    
    // MARK: - Methods
    
    func getNextCell() -> LiftCell? {
        
        guard let tableCell = superTableCell as? ExerciseCellForWorkouts else {
            fatalError("Cannot getNextCell if not ExerciseCellForWorkouts")
        }
        
        var nextCell: LiftCell? = nil
        
        if let currentIndexPath = tableCell.collectionView.indexPath(for: self) {
            let refToNextCell = tableCell.getNextCell(fromIndexPath: currentIndexPath)
            nextCell = refToNextCell
        }
        return nextCell
    }
    
    @objc func focus() {
        // Focus on cell if its marked as performed, or
        guard let exerciseTableCell = superTableCell as? ExerciseCellForWorkouts else {
            print("ERROR: not focusable")
            return
        }
        
        guard isPerformed else {
            exerciseTableCell.getFirstFreeCell()?.forceFocus()
            return
        }
        
        exerciseTableCell.activeLiftCell = self
        showKeyboardOnRepsField()
    }
    
    @objc func showKeyboardOnRepsField() {
        // Make keyboard
        globalKeyboard.setKeyboardType(style: .reps)
        globalKeyboard.delegate = self
        
        // Present keyboard
        repsField.delegate = superTableCell as? ExerciseCellForWorkouts
        repsField.inputView = globalKeyboard
        repsField.becomeFirstResponder()
    }
    
    func forceFocus() {
        isPerformed = true
        focus()
    }
    
    func setPlaceholderVisuals(_ textField: UITextField) {
        // Make a placeholder in a nice color
        let color = UIColor.akDark.withAlphaComponent(.opacity.faded.rawValue)
        let font = UIFont.custom(style: .medium, ofSize: .big)
        textField.attributedPlaceholder = NSAttributedString(string: initialRepValue, attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: font])
        
        setInputtedStyle()
    }
    
    func validateFields() {
        validateRepsField()
    }
    
    private func validateRepsField() {
        // Has no text? - Return to initial value
        guard let newText = repsField.text else {
            repsField.text = initialRepValue
            isPerformed = false
            endEditing(true)
            return
        }
        // Has invalid number? - Return to initial value
        guard let newRepValue = Int16(newText) else {
            repsField.text = initialRepValue
            makeRepTextNormal()
            isPerformed = false
            endEditing(true)
            return
        }
        // Has new text and is valid number -> Save new Value
        saveRepsToDataSource(newRepValue)
        isPerformed = true
        setInputtedStyle()
        endEditing(true)
    }
    
    // MARK: API
    
    func setReps(_ n: Int16) {
        repsField.text = String(n)
    }
    
    // MARK: Helpers
    
    func OKHandler() {
        preconditionFailure("override in subclasses")
    }
    
    func makeRepTextNormal() {
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = .akDark
        repsField.alpha = Constant.alpha.faded
    }
    
    func setInputtedStyle() {
        repsField.font = UIFont.custom(style: .bold, ofSize: .big)
        repsField.textColor = .akDark
        repsField.alpha = 1
    }
    
    func saveRepsToDataSource(_ newValueAsInt16: Int16) {
        guard let indexPath = superTableCell.collectionView.indexPath(for: self) else { return }
        
        let lift = superTableCell.liftsToDisplay[indexPath.row]
        lift.reps = newValueAsInt16
        lift.hasBeenPerformed = true
        
        if lift.datePerformed == nil {
            lift.datePerformed = NSDate()
        }
    }
}

// MARK: - Extensions

// MARK: KeyboardDelegate Conformance

extension LiftCell: KeyboardDelegate {
    
    func buttonDidTap(keyName: String) {
        // Target active textField
        guard let activeTextField = UIResponder.currentFirst() as? UITextField else {
            preconditionFailure("No textfield to write in")
        }
        
        switch keyName {
        case "OK":
            OKHandler()
        case "B": // Back
            activeTextField.deleteBackward()
        default:
            activeTextField.insertText(keyName.uppercased())
        }
    }
}

