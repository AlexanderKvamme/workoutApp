//
//  refreshControlView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class RefreshControlView: UIView {
    
    let label = UILabel()
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        label.text = "+"
        label.font = UIFont.custom(style: .bold, ofSize: .biggest)
        label.textColor = UIColor.darkest
        label.sizeToFit()

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.heightAnchor.constraint(equalTo: label.heightAnchor),
            label.widthAnchor.constraint(equalTo: label.widthAnchor),
            ])
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
