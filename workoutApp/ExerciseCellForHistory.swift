//
//  ExerciseHistoryCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/*
 ExerciseTableViewCell is one cell in a table of exercises. So each cell represents one exercise, and contains any number of sets to be performed for the exercise.
 */

class ExerciseCellForHistory: ExerciseCellBaseClass, LiftCellManager {
    
    private var exerciseLogToDisplay: ExerciseLog!

    // MARK: - Initializers
    
    init(withExerciseLog exerciseLog: ExerciseLog, andLifts lifts: [Lift], andIdentifier cellIdentifier: String) {
        super.init(style: .default, reuseIdentifier: cellIdentifier)

        exercise = exerciseLog.getDesign()
        liftsToDisplay = lifts
        exerciseLogToDisplay = exerciseLog
        
        setupBox(forExercise: exerciseLog.getDesign())
        setupConstraints()
        setupCollectionView()
        addLongpressRecognizer()
        
        selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func getIndexPath() -> IndexPath? {
        if let indexPath = owner?.owner.tableView.indexPath(for: self) {
            return indexPath
        } else {
            print("ERROR: - Could not find indexPath")
        }
        return nil
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        box.translatesAutoresizingMaskIntoConstraints = false
        
        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: box.topAnchor, constant: -verticalInsetForBox),
            contentView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: verticalInsetForBox),
            contentView.widthAnchor.constraint(equalToConstant: Constant.UI.width),
            ])
        
        // the box
        NSLayoutConstraint.activate([
            box.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            box.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            box.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: 0),
            ])
    }
}
extension ExerciseCellForHistory {
    
    override func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            return
        }
        print("would handle in ECFH")
    }
}

// MARK: UICollectionViewDataSource
extension ExerciseCellForHistory: UICollectionViewDataSource {
    
    // numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let liftToDisplay = liftsToDisplay[indexPath.row]
        
        var cell: LiftCell!
        
        if self.exercise.isWeighted() {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.weighted, for: indexPath) as! WeightedLiftCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.unweighted, for: indexPath) as! UnweightedLiftCell
        }
        cell.superTableCell = self
        
        let liftIsPerformed = liftToDisplay.hasBeenPerformed
        
        let repFromLift = liftToDisplay.reps
        cell.setReps(repFromLift)
        cell.isPerformed = liftIsPerformed
        
        if let c = cell as? WeightedLiftCell {
            c.setWeight(liftToDisplay.weight)
            c.weightField.isUserInteractionEnabled = false
            if liftIsPerformed {
                c.makeWeightTextBold()
            }
        }
        
        // Make bold if it is performed
        if liftIsPerformed {
            cell.setInputtedStyle()
        }
        
        return cell
    }
}

