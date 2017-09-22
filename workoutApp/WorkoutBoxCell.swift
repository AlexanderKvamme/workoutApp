//
//  BoxCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import SwipeCellKit

class WorkoutBoxCell: SwipeTableViewCell {
    
    let box: Box!
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        // Box
        let boxFactory = BoxFactory.makeFactory(type: .WorkoutBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent!)
        
        box.isUserInteractionEnabled = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        addViewsAndConstraints()
    }
    
        required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViewsAndConstraints() {
        
        contentView.addSubview(box)
        let marginGuide = contentView.layoutMarginsGuide
        
        box.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            marginGuide.topAnchor.constraint(equalTo: box.topAnchor),
            marginGuide.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: box.intrinsicContentSize.height),
            box.widthAnchor.constraint(equalToConstant: box.frame.width),
            ])
        
        // Compression resistance
        box.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        contentView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 0), for: .vertical)
    }
    
    func setupContent(withWorkout workout: Workout) {
        guard let name = workout.name else { return }
        guard let styleName = workout.workoutStyle?.name else { return }
        
        box.setTitle(name)
        box.setSubHeader(styleName)

        if let content = box.content {
            content.setup(usingWorkout: workout)
        }
    }
}

