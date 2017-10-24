//
//  WeightedLiftCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class WeightedLiftCell: LiftCell {
    
    // MARK: - Properties

    var weightField: UITextField!
    var initialWeightAsString: String {
        return String(initialWeight).replacingOccurrences(of: ".0", with: "")
    }
    var initialWeight: Double {
        guard let indexPath = superTableCell.collectionView.indexPath(for: self) else { fatalError() }
        let dataSourceIndexToUpdate = indexPath.row
        return superTableCell.liftsToDisplay[dataSourceIndexToUpdate].weight
    }
    
    override var superTableCell: ExerciseCellBaseClass! {
        didSet {
            if let superduper = superTableCell as? ExerciseCellForWorkouts {
                weightField.delegate = superduper
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        let newFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        super.init(frame: newFrame)
        
        setupViewsAndConstraints()
        weightField.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // MARK: Setup methods
    
    private func setupViewsAndConstraints() {
        setupRepsField()
        setupWeightField()
        setupView()
        setupButtonCoveringCell()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: repsField.topAnchor),
            bottomAnchor.constraint(equalTo: weightField.bottomAnchor),
            leftAnchor.constraint(equalTo: repsField.leftAnchor),
            rightAnchor.constraint(equalTo: repsField.rightAnchor),
            ])
    }
    
    private func setupRepsField() {
        repsField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        repsField.text = "-1"
        repsField.textAlignment = .center
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = UIColor.light
        repsField.alpha = Constant.alpha.faded
        repsField.clearsOnBeginEditing = true
        addSubview(repsField)
    }
    
    private func setupWeightField() {
        
        weightField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        weightField.text = "-1"
        weightField.clearsOnBeginEditing = true
        weightField.textAlignment = .center
        weightField.font = UIFont.custom(style: .medium, ofSize: .medium)
        weightField.textColor = UIColor.light
        weightField.backgroundColor = .clear
        weightField.alpha = Constant.alpha.faded
        weightField.sizeToFit()

        addSubview(weightField)
        
        weightField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weightField.topAnchor.constraint(equalTo: repsField.bottomAnchor, constant: -10),
            weightField.centerXAnchor.constraint(equalTo: repsField.centerXAnchor),
            weightField.heightAnchor.constraint(equalToConstant: weightField.frame.height),
            weightField.widthAnchor.constraint(equalTo: repsField.widthAnchor),
            ])
    }
    
    private func setupButtonCoveringCell() {
        overlayingButton = UIButton(frame: frame)
        overlayingButton.addTarget(self, action: #selector(focus), for: .touchUpInside)
        addSubview(overlayingButton)
    }
    
    // MARK: API
    
    public func setWeight(_ n: Double) {
        let newString = String(n).replacingOccurrences(of: ".0", with: "")
        weightField.text = newString
    }
    
    @objc func showKeyboardOnWeightField() {
        // Make keyboard
        let screenWidth = Constant.UI.width
        let keyboard = Keyboard(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        keyboard.setKeyboardType(style: .weight)
        keyboard.delegate = self
        weightField.inputView = keyboard
        weightField.becomeFirstResponder()
    }
    
    // MARK: Helper methods
    
    override func setPlaceholderVisuals(_ textField: UITextField) {
        
        switch textField {
        case repsField:
            super.setPlaceholderVisuals(textField)
        case weightField:
            setPlaceholderVisualsOnWeightField()
            makeWeightTextBold()
        default:
            return
        }
    }
    
    private func setPlaceholderVisualsOnWeightField(){
        let color = UIColor.light
        let font = UIFont.custom(style: .medium, ofSize: .medium)
        weightField.attributedPlaceholder = NSAttributedString(string: initialWeightAsString, attributes: [NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font: font])
    }
    
    private func saveWeightToDataSource(_ double: Double) {
        
        print("saveWeightToDataSource()")
    
        guard let indexPath = superTableCell.collectionView.indexPath(for: self) else {
            fatalError("Unable to retrieve indexPath")
        }
        
        let liftRow = indexPath.row
        superTableCell.liftsToDisplay[liftRow].weight = double
        superTableCell.liftsToDisplay[liftRow].hasBeenPerformed = true
        
        // Keeps lifts in order
        if superTableCell.liftsToDisplay[liftRow].datePerformed == nil {
            superTableCell.liftsToDisplay[liftRow].datePerformed = NSDate()
        }
    }
    
    override func OKHandler() {
        validateFields()
    }
    
    override func validateFields() {
        validateRepsField()
        validateWeightField()
    }
 
    private func validateRepsField() {
        // Has no text? - Return to initial value
        guard let newText = repsField.text, newText != "" else {
            weightField.isUserInteractionEnabled = true
            repsField.text = initialRepValue
            isPerformed = true
            saveRepsToDataSource(Int16(initialWeight))
            makeRepTextBold()
            makeWeightTextBold()
            endEditing(true)
            return
        }
        // Has invalid number? - Return to initial value
        guard let newRepValue = Int16(newText) else {
            repsField.text = initialRepValue
            makeRepTextNormal()
            makeWeightTextBold()
            return
        }
        // Has new text and is valid number: Save new Value
        weightField.isUserInteractionEnabled = true
        saveRepsToDataSource(newRepValue)
        isPerformed = true
        makeRepTextBold()
        makeWeightTextBold()
        endEditing(true)
    }
    
    private func validateWeightField() {
        // Save if convertible to Double
        if let text = weightField.text, let newWeight = Double(text) {
            saveWeightToDataSource(newWeight)
            weightField.text = String(newWeight).replacingOccurrences(of: ".0", with: "")
            makeWeightTextBold()
        } else {
            weightField.text = initialWeightAsString
        }
        endEditing(true)
    }
    
    func makeWeightTextBold() {
        weightField.font = UIFont.custom(style: .bold, ofSize: .medium)
        weightField.textColor = .light
        weightField.alpha = 1
    }
    
    // MARK: Debug methods
    
    override func setDebugColors() {
        super.setDebugColors()
        weightField.backgroundColor = .green
        weightField.alpha = 0.5
    }
}

extension WeightedLiftCell: NextableLift {
    func NextHandler() {
        // mark as performed, find next available
        guard let activeField = UIResponder.currentFirst() else {
            fatalError("Neither fields were selected")
        }
        
        validateFields()
        
        // Go to next field or cell
        switch activeField {
        case weightField:
            goToNextCell()
        case repsField:
            showKeyboardOnWeightField()
        default:
            return
        }
    }
    
    private func goToNextCell() {
        // If there is no next cell, make one
        (superTableCell as? ExerciseCellForWorkouts)?.nextOrNewLiftCell()
    }
}