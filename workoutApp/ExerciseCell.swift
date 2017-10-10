//
//  ExerciseCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

/*
 ExerciseTableViewCell is one cell in a table of exercises. So each cell represents one exercise, and contains any number of sets to be performed for the exercise.
 */

class ExerciseCell: UITableViewCell, UICollectionViewDelegate {

    // MARK: - Properties
    
    var liftsToDisplay: [Lift]!
    var collectionView: UICollectionView!
    var currentCellExerciseLog: ExerciseLog! // each cell in this item, displays the Exercise, and all the LiftLog
    var box: ExerciseTableCellBox!
    
    weak var owner: ExerciseTableViewDataSource!
    
    // MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func getIndexPath() -> IndexPath? {
        if let indexPath = owner.owner.tableView.indexPath(for: self) {
            return indexPath
        } else {
            print("ERROR: - Could not find indexPath")
        }
        return nil
    }
    
    @objc @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    // MARK: - setup methods
    
    private func setupCell() {
        backgroundColor = .light
    }
    
    func setupBox(forExercise exercise: Exercise) {
        var boxFactory: BoxFactory!
        
        switch exercise.isWeighted() {
        case true:
            boxFactory = BoxFactory.makeFactory(type: .TallExerciseTableCellBox)
        case false:
            boxFactory = BoxFactory.makeFactory(type: .ExerciseTableCellBox)
        }
        
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        switch exercise.isWeighted(){
        case true:
            box = TallExerciseTableCellBox(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        case false:
            box = ShortExerciseTableCellBox(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        }
        
        contentView.addSubview(box)
    }
}

