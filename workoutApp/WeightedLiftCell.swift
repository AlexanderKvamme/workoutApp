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
    var initialWeightValue: String {
        guard let indexPath = tableCell.collectionView.indexPath(for: self) else {
            fatalError()
        }
        
        let dataSourceIndexToUpdate = indexPath.row
        let valueFromDatasource = tableCell.liftsToDisplay[dataSourceIndexToUpdate].weight
        return String(valueFromDatasource).replacingOccurrences(of: ".0", with: "")
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        let newFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        super.init(frame: newFrame)
        
        setupViewsAndConstraints()
        addLongPressRecognizer(to: overlayingButton)
        // setDebugColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupViewsAndConstraints() {
        setupRepsField()
        setupWeightField()
        setupView()
        setupOverlayingButton()
    }

    // MARK: Setup methods
    
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
        weightField.delegate = self
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
    
    // MARK: TextField Delegate
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextButtonTapHandler), name: Notification.Name.keyboardsNextButtonDidPress, object: nil)
        
        switch textField {
        case weightField:
            showWeightKeyboard()
            prepareWeightFieldForEditing()
        case repsField:
            super.textFieldDidBeginEditing(textField)
        default:
            fatalError("TextField out of scope")
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        validateRepsField()
        validateWeightField()
        
        NotificationCenter.default.removeObserver(self, name: .keyboardsNextButtonDidPress, object: nil)
    }
    
    // MARK: Helpers
    
    @objc internal override func nextButtonTapHandler() {
        // mark as performed, find next available
        guard let activeField = UIResponder.currentFirst() else {
            fatalError("Neither fields were selected")
        }
        
        switch activeField {
        case weightField:
            validateRepsField()
            validateWeightField()
            goToNextCell()
        case repsField:
            weightField.becomeFirstResponder()
        default:
            return
        }
    }
    
    private func goToNextCell() {
        // If there is no next cell, make one
        guard let nextCell = tableCell.getFirstFreeCell() else {
            tableCell.insertNewCell()
            return
        }

        // Go to next cell
        let ip = tableCell.collectionView.indexPath(for: nextCell)
        tableCell.collectionView.selectItem(at: ip, animated: true, scrollPosition: .centeredVertically) // Scroll
        nextCell.repsFieldTapHandler()
    }
    
    
    
    func prepareWeightFieldForEditing() {
        // Setup placeholder
        let color = UIColor.light
        let newString = String(initialWeightValue).replacingOccurrences(of: ".0", with: "")// remove .0

        weightField.attributedPlaceholder = NSAttributedString(string: newString, attributes: [NSAttributedStringKey.foregroundColor : color])
    
        makeWeightTextBold()
    }
    
    public func setWeight(_ n: Double) {
        let newString = String(n).replacingOccurrences(of: ".0", with: "")
        weightField.text = newString
    }
    
    @objc func showWeightKeyboard() {
        // Make keyboard
        let screenWidth = Constant.UI.width
        let keyboard = Keyboard(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        keyboard.setKeyboardType(style: .weight)
        keyboard.delegate = self
        
        // Present keyboard
        weightField.inputView = keyboard
        weightField.delegate = self
        weightField.becomeFirstResponder()
    }
    
    // Private Helpers
    
    private func saveWeightToDataSource(_ double: Double) {
    
        guard let indexPath = tableCell.collectionView.indexPath(for: self) else {
            fatalError("Unable to retrieve indexPath")
        }
        
        let liftRow = indexPath.row
        // FIXME: store reference to this lift
        tableCell.liftsToDisplay[liftRow].weight = double
        tableCell.liftsToDisplay[liftRow].hasBeenPerformed = true
        
        // Keeps lifts in order
        if tableCell.liftsToDisplay[liftRow].datePerformed == nil {
            tableCell.liftsToDisplay[liftRow].datePerformed = NSDate()
        }
    }
    
    private func setupOverlayingButton() {
        
        overlayingButton = UIButton()
        overlayingButton.addTarget(self, action: #selector(repsFieldTapHandler), for: .touchUpInside)
        addSubview(overlayingButton)
        
        overlayingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overlayingButton.leftAnchor.constraint(equalTo: leftAnchor),
            overlayingButton.rightAnchor.constraint(equalTo: rightAnchor),
            overlayingButton.topAnchor.constraint(equalTo: topAnchor),
            overlayingButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    
    override func OKButtonHandler(onField textField: UITextField) {
        switch textField {
        case repsField:
            isPerformed = true
            endEditing(true)
        case weightField:
            validateRepsField()
            validateWeightField()
            endEditing(true)
        default:
            fatalError("Unsupported fields")
        }
    }
    
    // MARK: API
    
    func makeWeightTextBold() {
        weightField.font = UIFont.custom(style: .bold, ofSize: .medium)
        weightField.textColor = .light
        weightField.alpha = 1
    }
    
    // MARK: Helper methods
    
    private func validateWeightField() {
        // Save if convertible to Double
        if let text = weightField.text, let newWeight = Double(text) {
            saveWeightToDataSource(newWeight)
            weightField.text = String(newWeight).replacingOccurrences(of: ".0", with: "")
            makeWeightTextBold()
        } else {
            weightField.text = initialWeightValue
        }
    }
    
    // MARK: Debug methods
    
    override func setDebugColors() {
        super.setDebugColors()
        weightField.backgroundColor = .green
        weightField.alpha = 0.5
    }
}

