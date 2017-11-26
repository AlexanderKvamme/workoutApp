//
//  RegularLiftCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class UnweightedLiftCell: LiftCell {

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRepsField()
        setupButtonCoveringCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods

    // MARK: Setup methods
    
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
        repsField.accessibilityIdentifier = "repsField"
        addSubview(repsField)
    }
    
    // MARK: Overrides
    
    override func OKHandler() {
        validateFields()
    }
}

// MARK: - NextableLift conformance

extension UnweightedLiftCell: NextableLift {
    func NextHandler() {
        validateFields()
        goToNextCell()
    }
    
    private func goToNextCell() {
        guard let superTableCell = superTableCell as? ExerciseCellForWorkouts else {
            return
        }
        superTableCell.nextOrNewLiftCell()
    }
}

