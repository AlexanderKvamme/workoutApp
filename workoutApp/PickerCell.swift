//
//  PickerCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Cell

class PickerCell: UITableViewCell {
    
    // alle klasser krever init
    var label: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        
        label = UILabel()
        label.text = "bam"
        label.textAlignment = .center
        label.sizeToFit()
        addSubview(label)
        backgroundColor = .clear
        selectionStyle = .none
        
        // customize
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.textColor = UIColor.faded
//        label.applyCustomAttributes(.more)
        
        setConstraints()
    }
    
    func setDebugColors() {
        label.backgroundColor = .yellow
        backgroundColor = UIColor.secondary
    }
    
    func setConstraints() {
        //label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        
    }
}
