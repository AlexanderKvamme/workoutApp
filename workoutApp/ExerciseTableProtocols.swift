//
//  ExerciseTableProtocols.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: - hasPreviousCell

/// Add this to ExerciseCell to let any LiftCell it contains in its collectionView, access the LiftCell to its right. if there is any. Should only be avaiable to ExerciseCellForWorkouts
protocol hasNextCell: class {
    func getNextCell(fromIndexPath: IndexPath) -> LiftCell?
}

extension hasNextCell where Self: ExerciseCellBaseClass {
    
    // receives the indexPath of one of this TableViewCell's collectionViewCells, should either return the next cell, or make a new one if it doesnt exist, to allow for fast input of sets for the user
    func getNextCell(fromIndexPath indexPath: IndexPath) -> LiftCell? {
        var ip = indexPath
        ip.row += 1
        
        let nextCollectionViewCell = collectionView.cellForItem(at: ip) as? LiftCell
        
        return nextCollectionViewCell ?? nil
    }
}

// MARK: - hasPreviousCell

protocol hasPreviousCell: class {
    func getPreviousCell(fromIndexPath: IndexPath) -> LiftCell?
}

extension hasPreviousCell where Self: ExerciseCellBaseClass {
    // receives the indexPath of one of this TableViewCell's collectionViewCells, should either return the previous cell, or nil if it does not exist
    func getPreviousCell(fromIndexPath indexPath: IndexPath) -> LiftCell? {
        var ip = indexPath
        ip.row -= 1
        
        let previousCollectionViewCell = collectionView.cellForItem(at: ip) as? LiftCell
        return previousCollectionViewCell ?? nil
    }
}


