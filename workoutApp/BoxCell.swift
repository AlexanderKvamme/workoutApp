//
//  BoxCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class WorkoutBoxCell: UITableViewCell {
    
    let box: Box = {
        // Box
        let boxFactory = BoxFactory.makeFactory(type: .HistoryBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        let box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent!)
        box.translatesAutoresizingMaskIntoConstraints = false
        
        return box
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // super.init
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setUpViews()
    }
    
    // MARK: - Helpers
    
    func setUpViews() {
        contentView.addSubview(box)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            box.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            box.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            box.topAnchor.constraint(equalTo: marginGuide.topAnchor),
            box.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor),
            box.heightAnchor.constraint(equalToConstant: box.frame.height),
            box.widthAnchor.constraint(equalToConstant: box.frame.width),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

