//
//  SelectionViewHeader.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class selectionViewHeader: UIView {
    
    var button = UIButton()
    var label = UILabel()
    
    
    init(header: String, subheader: String) {
        let headerLabel = UILabel()
        let subheaderLabel = UILabel()
        
        headerLabel.text = header.uppercased()
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.secondary
        headerLabel.alpha = Constant.Alpha.faded
        headerLabel.sizeToFit()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subheaderLabel.text = subheader.uppercased()
        subheaderLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = UIColor.dark
        subheaderLabel.sizeToFit()
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let combinedLabelHeight = subheaderLabel.frame.height + headerLabel.frame.height
        let width = Constant.UI.width
        let newFrame = CGRect(x: 0, y: 0, width: width, height: combinedLabelHeight)
        
        super.init(frame: newFrame)
        
        addSubview(headerLabel)
        addSubview(subheaderLabel)
        
        headerLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        subheaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor).isActive = true
        subheaderLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
//        backgroundColor = UIColor.medium
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
