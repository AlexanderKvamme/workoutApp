//
//  UnweightedHistoryCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 07/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class UnweightedHistoryLiftCell: LiftCell {
    
    // MARK: - Properties
    
    var weightLabel: UILabel?

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupRepsField()
        setupButtonCoveringCell()
//        addLongPressRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // MARK: Handlers and recognizers
    
    
    // FIXME: - Deal with this
//    @objc override func longPressOnCellHandler(_ gesture: UILongPressGestureRecognizer) {
//        // TODO: let user edit or delete lifts here
//        if gesture.state == .began {
//            print("FIXME: Decide what to do")
//        }
//    }
    
    // MARK: Helper methods
    
//    private func addLongPressRecognizer() {
//        let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCellHandler(_:)))
//        overlayingButton.addGestureRecognizer(longpressRecognizer)
//    }
    
    // MARK: Setup functions
    
    private func setupButtonCoveringCell() {
        overlayingButton = UIButton(frame: repsField.frame)
        overlayingButton.addTarget(self, action: #selector(focus), for: .touchUpInside)
        addSubview(overlayingButton)
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
    
    // TODO: - Finish implementing the weight label to allow weighted exercises
    
    func setWeight(_ n: Int16) {
        weightLabel = UILabel(frame: CGRect(x: repsField.frame.minX, y: repsField.frame.maxY, width: repsField.frame.width, height: 20))
        
        if let weightLabel = weightLabel {
            weightLabel.text = String(n)
            weightLabel.textAlignment = .center
            weightLabel.font = UIFont.custom(style: .medium, ofSize: .small)
            weightLabel.textColor = .light
            addSubview(weightLabel)
        }
    }
}
