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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        print("in cell: Creating with exercise:", exercise.name)
        print("initializing cvCell")
        repsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        repsLabel.text = "99"
        repsLabel.textAlignment = .center
        repsLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        repsLabel.textColor = .light
        addSubview(repsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setReps(_ n: Int16) {
        repsLabel.text = String(n)
        
    }
    
    // FIXME: - Finish implementing the weight laabel to allow weighted exercises
    
    func setWeight(_ n: Int16) {
        weightLabel = UILabel(frame: CGRect(x: repsLabel.frame.minX,
                                            y: repsLabel.frame.maxY,
                                            width: repsLabel.frame.width,
                                            height: 20))
        
        if let weightLabel = weightLabel {
            
            weightLabel.text = String(n)
            weightLabel.textAlignment = .center
            weightLabel.font = UIFont.custom(style: .medium, ofSize: .small)
            weightLabel.textColor = .light
            addSubview(weightLabel)
        }
    }
}

