//
//  BoxCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class WorkoutBoxCell: UITableViewCell {
    
    let box: Box!
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // super.init
        
        // Box
        let boxFactory = BoxFactory.makeFactory(type: .HistoryBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent!)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(box)
        
        backgroundColor = .clear
        selectionStyle = .none
//        setUpViews()
        setupTestViews()
    }
    
    func setupTestViews() {
        let marginGuide = contentView.layoutMarginsGuide
        
        box.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            box.leftAnchor.constraint(equalTo: contentView.leftAnchor),
//            box.rightAnchor.constraint(equalTo: contentView.rightAnchor),

            marginGuide.topAnchor.constraint(equalTo: box.topAnchor),
            marginGuide.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            //box.heightAnchor.constraint(equalToConstant: box.intrinsicContentSize.height),
            
//            contentView.heightAnchor.constraint(equalToConstant: 160),
//            box.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: box.intrinsicContentSize.height),
//            box.heightAnchor.constraint(equalToConstant: box.frame.height),
            box.widthAnchor.constraint(equalToConstant: box.frame.width),
            ])
        
        // Compression resistance
        box.setContentCompressionResistancePriority(1000, for: .vertical)
        contentView.setContentCompressionResistancePriority(0, for: .vertical)
    }
    
    // MARK: - Helpers
    
    func setUpViews() {
        
        let marginGuide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            box.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            box.rightAnchor.constraint(equalTo: contentView.rightAnchor),
//            box.topAnchor.constraint(equalTo: marginGuide.topAnchor),
//            box.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor),
//            box.heightAnchor.constraint(equalToConstant: box.intrinsicContentSize.height),
    
            contentView.heightAnchor.constraint(equalToConstant: 160),
            
            box.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
//            box.heightAnchor.constraint(equalToConstant: 150),
            //box.heightAnchor.constraint(equalToConstant: box.frame.height),
            box.widthAnchor.constraint(equalToConstant: box.frame.width),
            ])
        
        // Compression resistance
        box.setContentCompressionResistancePriority(1000, for: .vertical)
        contentView.setContentCompressionResistancePriority(0, for: .vertical)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

