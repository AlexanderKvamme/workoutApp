//
//  ExerciseCollectionViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/* Hver celle skal displaye en "Lift" fra databasen..
 
 Lift:
 - reps
 - weight
 
 Cellen skal vise bare reps, eller "reps og weight" */

class ExerciseSetCollectionViewCell: UICollectionViewCell, UITextFieldDelegate, KeyboardDelegate {
    
    var button: UIButton! // Button that covers entire cell, to handle taps
    var repsField: UITextField!
    var weightLabel: UILabel?
    var keyboard: Keyboard!
    
//    weak var ownedByTableViewCell: ExerciseTableViewCell!
    
    var initialRepValue: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        repsField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        repsField.text = "99"
        repsField.textAlignment = .center
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = UIColor.light
        repsField.alpha = Constant.alpha.faded
        repsField.clearsOnBeginEditing = true
        addSubview(repsField)
        
        button = UIButton(frame: repsField.frame)
        button.addTarget(self, action: #selector(tapHandler(sender:)), for: .touchUpInside)
        addSubview(button)
        
        //setDebugColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("cell deinit")
    }
    
    // MARK: - Keyboard delegate method
    
    func buttonDidTap(keyName: String) {
        switch keyName{
        case "OK":
            repsField.resignFirstResponder()
            textFieldDidEndEditing(repsField)
        case "B": // Back button
            repsField.deleteBackward()
            return
        default:
            repsField.insertText(keyName.uppercased())
        }
    }
    
    // MARK: - Textfield delegate methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let newValue = textField.text {
            if newValue == "" {
                textField.text = initialRepValue
                makeTextNormal()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("initially it was: ", textField.text)
        makeTextBold()
    }
    
    func tapHandler(sender: Any) {
        // FIXME: - acces containing tableViewCell, and use this to target next cell when they keyboard receives "->"
        print("cellDidTap")
        
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

        layoutIfNeeded()
    }
    
    public func setReps(_ n: Int16) {
        repsField.text = String(n)
        self.initialRepValue = String(n)
    }

    // Text Design
    
    private func makeTextNormal() {
        repsField.font = UIFont.custom(style: .medium, ofSize: .big)
        repsField.textColor = .light
        repsField.alpha = Constant.alpha.faded
    }
    
    private func makeTextBold() {
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

