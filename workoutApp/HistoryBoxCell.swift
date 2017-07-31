//
//  BoxCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit


class HistoryBoxCell: UITableViewCell {
    
    let box: Box!
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        // Box
        let boxFactory = BoxFactory.makeFactory(type: .HistoryBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent!)
        box.isUserInteractionEnabled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(box)
        
        backgroundColor = .clear
        selectionStyle = .none
        setupTestViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTestViews() {
        let marginGuide = contentView.layoutMarginsGuide
        
        box.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            marginGuide.topAnchor.constraint(equalTo: box.topAnchor),
            marginGuide.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: box.intrinsicContentSize.height),
            box.widthAnchor.constraint(equalToConstant: box.frame.width),
            ])
        
        // Compression resistance
        box.setContentCompressionResistancePriority(1000, for: .vertical)
        contentView.setContentCompressionResistancePriority(0, for: .vertical)
    }
}

