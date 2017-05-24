//
//  SelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class SelectionViewController: UINavigationController {
    
    var header: SelectionViewHeader!
    var buttons: [SelectionViewButton]!
    var alignmentRectangle = UIView() // Used to center stack between header and tab bar
    var stack: StackView!
    
    init(header: SelectionViewHeader, buttons: [SelectionViewButton]) {
        self.header = header
        self.buttons = buttons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        navigationBar.isHidden = true
        
        //Stack View
        stack = StackView(frame: CGRect.zero)
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = Constant.layout.SelectionVC.Stack.spacing

        for button in buttons {
            stack.addArrangedSubview(button)
        }
        
        view.addSubview(header)
        view.addSubview(stack)
        
        setLayout()
        drawDiagonalLineThrough(stack)
    }
    
    private func drawDiagonalLineThrough(_ someView: UIView) {
        view.layoutSubviews()
        let verticalShift: CGFloat = 24
        let verticalStretch: CGFloat = 30
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: someView.frame.minX, y: someView.frame.maxY + verticalStretch - verticalShift))
        path.addLine(to: CGPoint(x: someView.frame.maxX, y: someView.frame.minY - verticalStretch - verticalShift))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.primary.cgColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = 3.0
        
        let line = UIView()
        line.layer.addSublayer(shapeLayer)
        view.addSubview(line)
        view.sendSubview(toBack: line)
        //view.layer.addSublayer(shapeLayer)
        //view.sendSubview(toBack: shapeLayer)
    }
    
    private func drawRectAt(_ p: CGPoint) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        v.backgroundColor = .black
        v.center = p
        view.addSubview(v)
        v.layoutIfNeeded()
    }
    
    private func setLayout() {
        
        // header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor,
                                    constant: Constant.layout.SelectionVC.Header.spacingTop).isActive = true
        
        // stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // Position stack
        makeAlignmentRectangle()
        stack.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor, constant: 0).isActive = true
    }
    
    private func makeAlignmentRectangle() {
        alignmentRectangle = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        alignmentRectangle.backgroundColor = .blue
        view.addSubview(alignmentRectangle)
        alignmentRectangle.alpha = 0.5
        alignmentRectangle.isHidden = true
        alignmentRectangle.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0).isActive = true
        alignmentRectangle.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        alignmentRectangle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        alignmentRectangle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        alignmentRectangle.translatesAutoresizingMaskIntoConstraints = false
    }
}
