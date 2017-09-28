//
//  ExerciseCollectionViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/* Every cell represents a "Lift"
 
 Lift:
 - reps
 - weight
 
 Cellen skal vise bare reps, eller "reps og weight" */

class ExerciseSetCollectionViewCell: UICollectionViewCell, UITextFieldDelegate, KeyboardDelegate {
    
    var button: UIButton! // Covers entire cell, to handle taps
    var repsField: UITextField!
    private var cellHasBeenEdited = false
    private var keyboard: Keyboard!
    var isPerformed = false // track if Lift should be tracked as completed
    var weightLabel: UILabel? // TODO
    weak var owner: ExerciseTableViewCell! // Allows for accessing the owner's .getNextCell() method
    
    var initialRepValue: String {
        if let indexPath = owner.collectionView.indexPath(for: self) {
            let dataSourceIndexToUpdate = indexPath.row
            let valueFromDatasource = owner.liftsToDisplay[dataSourceIndexToUpdate].reps
            return String(valueFromDatasource)
        }
        else {
            return "Error fetching initial rep"
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupRepsField()
        setupButtonCoveringCell()
        
        // Add long press gesture recognizer to edit cell
        let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCellHandler(_:)))
        button.addGestureRecognizer(longpressRecognizer)
        
        // Track changes in label
        repsField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        //setDebugColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    // Remove cell when user uses long press on it
    @objc private func longPressOnCellHandler(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began{
            print("\nLONG PRESS - GONNA DELETE CELL")
            let indexPathToRemove = self.owner.collectionView.indexPath(for: self)
            if let indexPathToRemove = indexPathToRemove {
                owner.liftsToDisplay.remove(at: indexPathToRemove.row)
                owner.collectionView.deleteItems(at: [indexPathToRemove])
                
                if let section = owner.owner.owner.tableView.indexPath(for: owner)?.section {

                    owner.owner.totalLiftsToDisplay[section].oneLinePrint()
                    let liftToRemove = owner.owner.totalLiftsToDisplay[section][indexPathToRemove.row]
                    owner.owner.totalLiftsToDisplay[section].remove(at: indexPathToRemove.row)
                    owner.owner.totalLiftsToDisplay[section].oneLinePrint()
                    DatabaseFacade.delete(liftToRemove)
                } else {
                    print("found no section")
                }
            }
        }
    }
    
    @objc private func textChanged() {
        self.cellHasBeenEdited = true
    }
    
    // MARK: - Helper
    
    private func printCollectionViewsReps() {
        print("Reps collection contains: ")
        for repValue in owner.liftsToDisplay {
            print(repValue.reps)
        }
        print()
    }
    
    // Setup functions
    
    private func setupButtonCoveringCell() {
        button = UIButton(frame: repsField.frame)
        button.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
        addSubview(button)
    }
    
    private func setupRepsField() {
        repsField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        repsField.text = "-1"
        repsField.textAlignment = .center
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = UIColor.light
        repsField.alpha = Constant.alpha.faded
        repsField.clearsOnBeginEditing = true
        addSubview(repsField)
    }
    
    // MARK: - Keyboard delegate method
    
    func buttonDidTap(keyName: String) {
        switch keyName{
        case "OK":
            OKButtonHandler()
        case "B": // Back button
            repsField.deleteBackward()
            return
        default:
            repsField.insertText(keyName.uppercased())
        }
    }
    
    // MARK: - Textfield delegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Make sure input is convertable to an integer for Core Data
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let newText = textField.text, let newValueAsInt16 = Int16(newText) {
            if cellHasBeenEdited && textField.text != "" && isPerformed {
                // if cell has been edited and textFieldDidEndEditing, Update data source with new value
                if let indexPath = owner.collectionView.indexPath(for: self) {
                    let dataSourceIndexToUpdate = indexPath.row
                    owner.liftsToDisplay[dataSourceIndexToUpdate].reps = newValueAsInt16

                    if owner.liftsToDisplay[dataSourceIndexToUpdate].datePerformed == nil {
                        owner.liftsToDisplay[dataSourceIndexToUpdate].datePerformed = NSDate()
                    }
                    owner.liftsToDisplay[dataSourceIndexToUpdate].hasBeenPerformed = true
                }
            } else { // textfield has not been editet and is not ""
                textField.text = initialRepValue
                makeTextNormal()
            }
        } else {
            print("ERROR: Text not convertible to Int or no text at all - NOT saving")
            // if no text at all make normal
            if isPerformed  {
                textField.text = initialRepValue
                makeTextBold()
            } else {
                textField.text = initialRepValue
                makeTextNormal()
            }
        }
        NotificationCenter.default.removeObserver(self, name: .keyboardsNextButtonDidPress, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        makeTextBold()
        
        // set field as active to make let the containing tableView scroll to active cell
        if owner.owner.owner.activeTableCell != owner {
            owner.owner.owner.activeTableCell = owner
        }
        
        // Make a placeholder in a nice color
        let color = UIColor.light
        let font = UIFont.custom(style: .medium, ofSize: .big)
        textField.attributedPlaceholder = NSAttributedString(string: initialRepValue, attributes: [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font: font])
        
        // Prepare for input
        NotificationCenter.default.addObserver(self, selector: #selector(nextButtonTapHandler), name: Notification.Name.keyboardsNextButtonDidPress, object: nil)
    }
    
    private func OKButtonHandler() {
        isPerformed = true
        endEditing(true)
    }
    
    @objc private func nextButtonTapHandler() {
        // mark as performed, find next available
        isPerformed = true
        
        if let nextAvailableCell = owner.getFirstFreeCell() {
            let ip = owner.collectionView.indexPath(for: nextAvailableCell)
            owner.collectionView.selectItem(at: ip, animated: true, scrollPosition: .centeredVertically)
            nextAvailableCell.tapHandler()
        } else {
            //Was nil, so there is no next. Make new cell, which is automatically selected
            owner.insertNewCell()
        }
    }
    
    func getNextCell() -> ExerciseSetCollectionViewCell? {
        var nextCell: ExerciseSetCollectionViewCell? = nil
        
        if let currentIndexPath = owner.collectionView.indexPath(for: self) {
            let refToNextCell = owner.getNextCell(fromIndexPath: currentIndexPath)
            nextCell = refToNextCell
        }
        return nextCell
    }
    
    func getPreviousCell() -> ExerciseSetCollectionViewCell? {
        var previousCell: ExerciseSetCollectionViewCell? = nil
        
        if let currentIndexPath = owner.collectionView.indexPath(for: self) {
            let refToPreviousCell = owner.getPreviousCell(fromIndexPath: currentIndexPath)
            previousCell = refToPreviousCell
        }
        return previousCell
    }
    
    @objc func tapHandler() {
        // - Display keyboard, make first responder, and scroll to the first cell in colleciton that isnt performed
        // If there are cells before this one, that are not performed, jump to the first one of these instead
        
        // If the cell is not previously performed, rather go to the first unperformed cell
        if !isPerformed {
            if let firstUnperformedCell = owner.getFirstFreeCell() {
                if firstUnperformedCell != self {
                    self.repsField.resignFirstResponder()
                    
                    firstUnperformedCell.tapHandler()
                    return
                }
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
    
    public func setReps(_ n: Int16) {
        repsField.text = String(n)
    }

    // Text manipulation
    
    func makeTextNormal() {
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = .light
        repsField.alpha = Constant.alpha.faded
    }
    
    func makeTextBold() {
        repsField.font = UIFont.custom(style: .bold, ofSize: .big)
        repsField.textColor = .light
        repsField.alpha = 1
    }
    
    // FIXME: - Finish implementing the weight label to allow weighted exercises
    
    func setWeight(_ n: Int16) {
        weightLabel = UILabel(frame: CGRect(x: repsField.frame.minX,
                                            y: repsField.frame.maxY,
                                            width: repsField.frame.width,
                                            height: 20))
        
        if let weightLabel = weightLabel {
            weightLabel.text = String(n)
            weightLabel.textAlignment = .center
            weightLabel.font = UIFont.custom(style: .medium, ofSize: .small)
            weightLabel.textColor = .light
            addSubview(weightLabel)
        }
    }
    
    func setDebugColors() {
        button.backgroundColor = .orange
        button.alpha = 0.5

        repsField.backgroundColor = .purple
        repsField.alpha = 0.5
        
        if let weightLabel = weightLabel {
            weightLabel.backgroundColor = .yellow
            weightLabel.alpha = 0.5
        }
    }
}

