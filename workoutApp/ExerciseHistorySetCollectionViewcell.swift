//
//  ExerciseHistorySetCollectionViewcell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/* Every cell represents a "Lift"
 
 Lift:
 - reps
 - weight (optional)
 
*/

class ExerciseHistorySetCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var button: UIButton! // Button that covers entire cell, to handle taps
    var repsField: UITextField!
    var weightLabel: UILabel? // TODO: - Let users work out with weights
    weak var owner: ExerciseHistoryTableViewCell! // Makes the containincells data accessible
    
    // Computed properties
    var initialRepValue: String {
        if let indexPath = owner.collectionView.indexPath(for: self) {
            let dataSourceIndexToUpdate = indexPath.row
            let valueFromDatasource = owner.liftsToDisplay[dataSourceIndexToUpdate].reps
            return String(valueFromDatasource)
        } else {
            return "Error fetching initial rep"
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupRepsField()
        setupButtonCoveringCell()
        addLongPressRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    // MARK: Handlers and recognizers
    
    @objc func tapHandler() {
        print("tapped")
    }
    
    // Remove cell when user uses long press on it
    @objc private func longPressOnCellHandler(_ gesture: UILongPressGestureRecognizer) {
        // TODO: Maybe let user edit or delete lifts here
        if gesture.state == .began {
            print("Long press detected: Decide what to do")
        }
    }
    
    // MARK: Helper methods
    
    private func addLongPressRecognizer() {
        let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCellHandler(_:)))
        button.addGestureRecognizer(longpressRecognizer)
    }
    
    // MARK: Setup functions
    
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
    
    public func setReps(_ n: Int16) {
        repsField.text = String(n)
    }
    
    // DEBUG: Text methods
    
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
    
    // TODO: - Finish implementing the weight label to allow weighted exercises
    
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
    
    // MARK: Print methods
    
    private func printCollectionViewsReps() {
        print("Reps collection contains: ")
        for repValue in owner.liftsToDisplay {
            print(repValue.reps)
        }
        print()
    }
    
    // MARK: Debug methods
    
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

