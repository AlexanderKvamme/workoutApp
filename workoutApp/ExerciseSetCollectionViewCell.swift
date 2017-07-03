//
//  ExerciseCollectionViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
/*
 Hver celle skal displaye en "Lift" fra databasen..
 
 Lift:
 - reps
 - weight
 
 Cellen skal vise bare reps, eller "reps og weight"
 */
class ExerciseSetCollectionViewCell: UICollectionViewCell {
    
    var repsLabel: UILabel!
    var weightLabel: UILabel?
    
//    let lift = Lift()
//    lift.set
    
    init(withExercise exercise: Exercise ) {
        super.init(frame: CGRect.zero)
        
        print("initializing cell with exercise:", exercise.name)
        repsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        repsLabel.backgroundColor = .red
        repsLabel.text = "99"
        repsLabel.backgroundColor = .purple
        addSubview(repsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

