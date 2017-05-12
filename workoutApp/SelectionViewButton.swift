//
//  SelectionViewButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class selectionViewButton: UIView {
    
    var button = UIButton()
    var label = UILabel()
    
    let horizontalSpacing: CGFloat = 10
    
    init(header: String, subheader: String) {
        //super.init(frame: frame)
        
        // Prosjekt: - Stack og usynlig button
        
        let labelStack = UIStackView()
        let headerLabel = UILabel()
        let subheaderLabel = UILabel()
        
        // stabels
        
        headerLabel.text = header.uppercased()
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.dark
        headerLabel.sizeToFit()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subheaderLabel.text = subheader.uppercased()
        subheaderLabel.font = UIFont.custom(style: .medium, ofSize: .small)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = UIColor.dark
        subheaderLabel.sizeToFit()
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let combinedLabelHeight = subheaderLabel.frame.height + headerLabel.frame.height
        let width = Constant.UI.width
        let newFrame = CGRect(x: 0, y: 0, width: width, height: combinedLabelHeight)
    
        print(newFrame)
        super.init(frame: newFrame)
        
        addSubview(headerLabel)
        addSubview(subheaderLabel)
        
        headerLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        subheaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor).isActive = true
        subheaderLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        // Button
        
        let button = UIButton(frame: newFrame)
        addSubview(button)
        button.addTarget(self, action: #selector(doSomething), for: .touchUpInside)
        
//        backgroundColor = UIColor.medium
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        button.titleLabel?.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        button.titleLabel?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: (button.titleLabel?.bottomAnchor)!, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    // UI components
    func doSomething() {
        print("something")
    }
}
