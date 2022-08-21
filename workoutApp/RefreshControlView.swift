//
//  refreshControlView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Refresh control used to let users make new workouts by pulling down on the workout table
class RefreshControlView: UIView {
    
    // MARK: - Properties
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "+"
        lbl.font = UIFont.custom(style: .bold, ofSize: .biggest)
        lbl.textColor = UIColor.akDark
        lbl.sizeToFit()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    // MARK: - Initializers
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupConstraints() {
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.heightAnchor.constraint(equalTo: label.heightAnchor),
            label.widthAnchor.constraint(equalTo: label.widthAnchor),
            ])
        setNeedsLayout()
    }
}

