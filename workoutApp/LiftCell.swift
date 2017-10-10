//
//  ExerciseCollectionViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class LiftCell: UICollectionViewCell, UITextFieldDelegate, KeyboardDelegate {
    
    // MARK: - Properties
    
    var overlayingButton: UIButton!
    var repsField: UITextField!
    var keyboard: Keyboard!
    var isPerformed = false

    weak var tableCell: ExerciseTableCell!
    
    var initialRepValue: String {
        guard let indexPath = tableCell.collectionView.indexPath(for: self) else { return "-2" }
        let valueFromDatasource = tableCell.liftsToDisplay[indexPath.row].reps
        return String(valueFromDatasource)
        
        /*
         if let indexPath = owner.collectionView.indexPath(for: self) {
         let dataSourceIndexToUpdate = indexPath.row
         let valueFromDatasource = owner.liftsToDisplay[dataSourceIndexToUpdate].reps
         return String(valueFromDatasource)
         } else {
         return "Error fetching initial rep"
         }
         */
    }
    
    // MARK: - Keyboard delegate method
    
    func buttonDidTap(keyName: String) {
        // Target active textField
        guard let activeTextField = UIResponder.currentFirst() as? UITextField else {
            preconditionFailure("No textfield to write in")
        }
   
        switch keyName{
        case "OK":
            OKButtonHandler(onField: activeTextField)
        case "B": // Back
            activeTextField.deleteBackward()
            return
        default:
            activeTextField.insertText(keyName.uppercased())
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // set field as active to make let the containing tableView scroll to active cell
        if tableCell.owner.owner.activeTableCell != tableCell {
            tableCell.owner.owner.activeTableCell = tableCell
        }
        // Make a placeholder in a nice color
        let color = UIColor.light
        let font = UIFont.custom(style: .medium, ofSize: .big)
        textField.attributedPlaceholder = NSAttributedString(string: initialRepValue, attributes: [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font: font])
        // Prepare for input
        NotificationCenter.default.addObserver(self, selector: #selector(nextButtonTapHandler), name: Notification.Name.keyboardsNextButtonDidPress, object: nil)
        
        makeRepTextBold()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Make sure input is convertable to an integer for Core Data
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateRepsField()
        
        NotificationCenter.default.removeObserver(self, name: .keyboardsNextButtonDidPress, object: nil)
    }
    
    func validateRepsField() {
        // Has no text? - Return to initial value
        guard let newText = repsField.text, newText != "" else {
            repsField.text = initialRepValue
            isPerformed = true
            makeRepTextBold()
            return
        }
        // Has invalid number? - Return to initial value
        guard let newRepValue = Int16(newText) else {
            repsField.text = initialRepValue
            makeRepTextNormal()
            return
        }
        // Has new text and is valid number -> Save new Value
        saveRepsToDataSource(newRepValue)
        isPerformed = true
        makeRepTextBold()
    }
   
    func OKButtonHandler(onField textField: UITextField) {
        endEditing(true)
    }
    
    @objc func nextButtonTapHandler() {
        // mark as performed, find next available
        isPerformed = true
        
        if let nextAvailableCell = tableCell.getFirstFreeCell() {
            let ip = tableCell.collectionView.indexPath(for: nextAvailableCell)
            tableCell.collectionView.selectItem(at: ip, animated: true, scrollPosition: .centeredVertically)
            nextAvailableCell.repsFieldTapHandler()
        } else {
            //Was nil, so there is no next. Make new cell, which is automatically selected
            tableCell.insertNewCell()
        }
    }
    
    // MARK: - Navigation Methods
    
    func getNextCell() -> LiftCell? {
        
        var nextCell: LiftCell? = nil
        
        if let currentIndexPath = tableCell.collectionView.indexPath(for: self) {
            let refToNextCell = tableCell.getNextCell(fromIndexPath: currentIndexPath)
            nextCell = refToNextCell
        }
        return nextCell
    }
    
    func getPreviousCell() -> LiftCell? {
        var previousCell: LiftCell? = nil
        
        if let currentIndexPath = tableCell.collectionView.indexPath(for: self) {
            let refToPreviousCell = tableCell.getPreviousCell(fromIndexPath: currentIndexPath)
            previousCell = refToPreviousCell
        }
        return previousCell
    }
    
    // MARK: Gestures
    
    func addLongPressRecognizer(to btn: UIButton) {
        let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCellHandler(_:)))
        btn.addGestureRecognizer(longpressRecognizer)
    }
    
    @objc func longPressOnCellHandler(_ gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == UIGestureRecognizerState.began else {
            return
        }
        
        guard let indexPathToRemove = self.tableCell.collectionView.indexPath(for: self) else {
            assertionFailure("Could not access indexPath")
            return
        }
        
        tableCell.liftsToDisplay.remove(at: indexPathToRemove.row)
        tableCell.collectionView.deleteItems(at: [indexPathToRemove])
        
        if let section = tableCell.owner.owner.tableView.indexPath(for: tableCell)?.section {
            
            tableCell.owner.totalLiftsToDisplay[section].oneLinePrint()
            let liftToRemove = tableCell.owner.totalLiftsToDisplay[section][indexPathToRemove.row]
            tableCell.owner.totalLiftsToDisplay[section].remove(at: indexPathToRemove.row)
            tableCell.owner.totalLiftsToDisplay[section].oneLinePrint()
            DatabaseFacade.delete(liftToRemove)
        }
    }

    // MARK: API
    
    func setReps(_ n: Int16) {
        repsField.text = String(n)
    }
    
    // MARK: Helpers
    
    @objc func repsFieldTapHandler() {
        // If the cell is not previously performed, go to the first unperformed cell
        if !isPerformed {
            guard let firstUnperformedCell = tableCell.getFirstFreeCell() else { return }
            if firstUnperformedCell != self {
                self.repsField.resignFirstResponder()
                firstUnperformedCell.repsFieldTapHandler()
                return
            }
        }
        
        // Custom keyboard for inputting time and weight
        let screenWidth = Constant.UI.width
        let keyboard = Keyboard(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        keyboard.setKeyboardType(style: .reps)
        repsField.inputView = keyboard
        keyboard.delegate = self
        
        // Present keyboard
        repsField.inputView = keyboard
        repsField.delegate = self
        repsField.becomeFirstResponder()
        
        setNeedsLayout()
    }

    func makeRepTextNormal() {
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = .light
        repsField.alpha = Constant.alpha.faded
    }
    
    func makeRepTextBold() {
        repsField.font = UIFont.custom(style: .bold, ofSize: .big)
        repsField.textColor = .light
        repsField.alpha = 1
    }
    
    func saveRepsToDataSource(_ newValueAsInt16: Int16) {
        guard let indexPath = tableCell.collectionView.indexPath(for: self) else { return }
        
        let lift = tableCell.liftsToDisplay[indexPath.row]
        lift.reps = newValueAsInt16
        lift.hasBeenPerformed = true
        
        if lift.datePerformed == nil {
            lift.datePerformed = NSDate()
        }
    }
    
    func setDebugColors() {
        // Overlaying Button
        overlayingButton.backgroundColor = .green
        overlayingButton.alpha = 0.1
        // Reps
        repsField.backgroundColor = .purple
        repsField.alpha = 0.5
    }
}

