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
    
    // MARK: - Properties
    
    var label: UILabel!
    
    // MARK: - Initializer
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // Setup methods
    
    private func setupCell() {
        label = UILabel()
        label.text = "cellText"
        label.textAlignment = .center
        label.sizeToFit()
        addSubview(label)
        backgroundColor = .clear
        selectionStyle = .none
        
        // customize the label
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.textColor = UIColor.faded
        label.applyCustomAttributes(.more)
        
        setLabelConstraints()
    }
    
    // Public methods
    
    func getHeight() -> CGFloat {
        return 50
    }
    
    // Private methods
    private func setLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
}

