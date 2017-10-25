//
//  SelectionViewHeader.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class SelectionViewHeader: UIView {
    
    var button = UIButton()
    var label = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    init(header: String, subheader: String) {
        let headerLabel = UILabel()
        let subheaderLabel = UILabel()
        
        headerLabel.text = header.uppercased()
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.secondary
        headerLabel.sizeToFit()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.applyCustomAttributes(.medium)
        
        subheaderLabel.text = subheader.uppercased()
        subheaderLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = UIColor.dark
        subheaderLabel.sizeToFit()
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: CGRect.zero)
        
        addSubview(headerLabel)
        addSubview(subheaderLabel)
        
        headerLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        subheaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor).isActive = true
        subheaderLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let combinedLabelHeight = subheaderLabel.frame.height + headerLabel.frame.height
        heightAnchor.constraint(equalToConstant: combinedLabelHeight).isActive = true
        widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

