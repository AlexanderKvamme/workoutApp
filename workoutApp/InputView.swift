//
//  InputView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class InputView: UIView {
    
    var header = UILabel()
    var textField = UITextField()
    var stack = UIStackView()
    
    init(inputStyle: CustomInputStyle) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constant.UI.width, height: 200))
        textField.frame = CGRect(x: 0, y: 0, width: Constant.UI.width, height: 100)
        
        // Set Default texts
        switch inputStyle{
        case .text:
            header.text = "HOW MUCH DO YOU EVEN LIFT?"
            textField.text = "03:00"
        case .time:
            header.text = "HOW MUCH DO YOU EVEN LIFT?"
            textField.text = "WorkoutName"
        case .weight:
            header.text = "HOW MUCH DO YOU EVEN LIFT?"
            header.numberOfLines = 2
            header.preferredMaxLayoutWidth = Constant.UI.width * 0.65
            header.textAlignment = .center
            textField.text = "32.5"
            textField.sizeToFit()
        }
        
        // TextField
        textField.textAlignment = .center
        textField.clearsOnBeginEditing = true
        textField.font = UIFont.custom(style: .bold, ofSize: .biggest)
        textField.textColor = .darkest
        
        // Header
        header.font = UIFont.custom(style: .bold, ofSize: .medium)
        header.textColor = .dark
        header.applyCustomAttributes(.medium)
        header.sizeToFit()
        
        // Stack
        stack = StackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = 10
        stack.addArrangedSubview(header)
        stack.addArrangedSubview(textField)
        
        addSubview(stack)
        setupStack()
        layoutIfNeeded()
        
        drawLine(throughView: textField)
        
//        setDebugColors()
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
    
    private func drawLine(throughView v: UIView) {
//        drawDiagonalLineThrough(v, inView: self)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: v.frame.minX, y: v.frame.maxY))
        path.addLine(to: CGPoint(x: v.frame.maxX, y: v.frame.minY))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.primary.cgColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = 3.0
        
        let line = UIView()
        line.backgroundColor = .green
        line.layer.addSublayer(shapeLayer)
        addSubview(line)
        
        line.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo:  v.topAnchor),
            line.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            line.leftAnchor.constraint(equalTo: v.leftAnchor),
            line.rightAnchor.constraint(equalTo: v.rightAnchor),
            ])
        line.center = v.center
        
//        NSLayoutConstraint.activate([
//            line.centerXAnchor.constraint(equalTo: v.centerXAnchor),
//            line.centerYAnchor.constraint(equalTo: v.centerYAnchor),
//            ])
        
        line.backgroundColor = .blue
        line.sizeToFit()
    }
}
