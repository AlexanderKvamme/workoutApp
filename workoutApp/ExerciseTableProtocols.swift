//
//  ExerciseTableProtocols.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

/*
 Protocol extension that returns nextCell if it has one, or nil
 */

protocol hasNextCell: class {
    func getNextCell(fromIndexPath: IndexPath) -> ExerciseSetCollectionViewCell?
}

protocol hasPreviousCell: class {
    func getPreviousCell(fromIndexPath: IndexPath) -> ExerciseSetCollectionViewCell?
}

extension hasPreviousCell where Self: ExerciseTableViewCell {
    // receives the indexPath of one of this TableViewCell's collectionViewCells, should either return the previous cell, or nil if it does not exist
    func getPreviousCell(fromIndexPath indexPath: IndexPath) -> ExerciseSetCollectionViewCell? {
        var ip = indexPath
        ip.row -= 1
        
        let previousCollectionViewCell = collectionView.cellForItem(at: ip) as? ExerciseSetCollectionViewCell
        if let previousCell = previousCollectionViewCell {
            return previousCell
        } else {
            print("there was no previous cell, so returning nil")
            return nil
        }
    }
}

extension hasNextCell where Self: ExerciseTableViewCell {
    
    // receives the indexPath of one of this TableViewCell's collectionViewCells, should either return the next cell, or make a new one if it doesnt exist, to allow for fast input of sets for the user
    func getNextCell(fromIndexPath indexPath: IndexPath) -> ExerciseSetCollectionViewCell? {
        var ip = indexPath
        ip.row += 1
        
        let nextCollectionViewCell = collectionView.cellForItem(at: ip) as? ExerciseSetCollectionViewCell
        if let nextCell = nextCollectionViewCell {
            return nextCell
        } else {
            print("there was no next cell, so returning nil")
            return nil
        }
    }
}
