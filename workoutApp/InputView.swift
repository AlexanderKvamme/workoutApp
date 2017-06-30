//
//  InputView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/*
    The InputView class is a view, visible to the user, which shows a header and a textField where the user can input either time, weight, sets, .etc.
 */

class InputView: UIView {
    
    var header = UILabel()
    var textField = UITextField(frame: CGRect(x: 0, y: 0, width: Constant.UI.width, height: 100))
    var stack = UIStackView()
    
    init(inputStyle: CustomInputStyle) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constant.UI.width, height: 200))
        
        // Set Default texts
        switch inputStyle{
        case .text:
            header.text = "NAME OF YOUR WORKOUT?"
            textField.placeholder = "Fist Pumps"
        case .time:
            header.text = "HOW MUCH TIME WILL YOU REST?"
            textField.placeholder = "03:00"
        case .weight:
            header.text = "HOW MUCH DO YOU EVEN LIFT?"
            header.numberOfLines = 2
            header.preferredMaxLayoutWidth = Constant.UI.width * 0.65
            header.textAlignment = .center
            textField.placeholder = "32.5"
        }
        
        // TextField
        textField.textAlignment = .center
        textField.clearsOnBeginEditing = true
        textField.font = UIFont.custom(style: .bold, ofSize: .biggest)
        textField.textColor = .darkest
        textField.clipsToBounds = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: Constant.UI.width).isActive = true
        textField.autocapitalizationType = .allCharacters

        addSubview(textField)
        
        // Header
        header.font = UIFont.custom(style: .bold, ofSize: .medium)
        header.textColor = .dark
        header.applyCustomAttributes(.medium)
        header.sizeToFit()
        
//         Stack
        stack = StackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(0, for: .horizontal)
        
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.fill
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = 10
        stack.addArrangedSubview(header)
        stack.addArrangedSubview(textField)
        
        stack.autoresizesSubviews = false

        addSubview(stack)
        setupStack()
        layoutIfNeeded()
        
        // View to contain yellow diagonal line
        let diagonalLineView = UIView(frame: CGRect(x: 0, y: 0, width: 125, height: textField.frame.height))
        diagonalLineView.center = textField.center
        
        // Draw diagonalLine and send to the back
        let v = drawLine(throughView: diagonalLineView)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.heightAnchor.constraint(equalToConstant: v.frame.height),
            v.widthAnchor.constraint(equalToConstant: v.frame.width),
            v.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            v.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
                    ])
        sendSubview(toBack: v)
        
        // default to showing keyboard
        textField.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    public func setDebugColors() {
        backgroundColor = .red
        textField.backgroundColor = .green
        header.backgroundColor = .brown
    }
    
    private func setupStack() {
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
    }
    
    private func drawLine(throughView: UIView) -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: throughView.frame.width, height: throughView.frame.height))
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: v.frame.minX, y: v.frame.maxY))
        path.addLine(to: CGPoint(x: v.frame.maxX, y: v.frame.minY))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.primary.cgColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = 3.0
        shapeLayer.backgroundColor = UIColor.red.cgColor
        
        v.layer.addSublayer(shapeLayer)
        addSubview(v)
        
        return v
    }
}
