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
    
    var button: UIButton! // Button that covers entire cell, to handle taps
    var repsLabel: UILabel!
    var weightLabel: UILabel?
    
//    let lift = Lift()
//    lift.set
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        repsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        repsLabel.text = "99"
        repsLabel.textAlignment = .center
        repsLabel.font = UIFont.custom(style: .medium, ofSize: .big)
        repsLabel.textColor = UIColor.light
        repsLabel.alpha = Constant.alpha.faded
        addSubview(repsLabel)
        
        button = UIButton(frame: repsLabel.frame)
        button.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
        addSubview(button)
        
        //setDebugColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapHandler() {
        print("tapped button: \(repsLabel.text)")
    }
    
    public func setReps(_ n: Int16) {
        repsLabel.text = String(n)
    }
    
    @objc private func markPerformed() {
        repsLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        repsLabel.textColor = .light
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
    
    func setDebugColors() {
        button.backgroundColor = .orange
        button.alpha = 0.5

        repsLabel.backgroundColor = .purple
        repsLabel.alpha = 0.5
        
        if let weightLabel = weightLabel {
            weightLabel.backgroundColor = .yellow
            weightLabel.alpha = 0.5
        }
    }
}

