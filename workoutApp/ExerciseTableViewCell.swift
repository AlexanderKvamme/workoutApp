//
//  ExerciseTableViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    var box: Box!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .red
        setupBox()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBox() {
        // Box
        let boxFactory = BoxFactory.makeFactory(type: .ExerciseProgressBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        addSubview(box)
        
        box.setTitle("Real Exercise")
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
//        box.translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([
            // Cell
            topAnchor.constraint(equalTo: box.topAnchor),
            bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: 10),
            widthAnchor.constraint(equalToConstant: Constant.UI.width),
//            heightAnchor.constraint(equalToConstant: 50),
            
            // Box
//            box.widthAnchor.constraint(equalToConstant: 300),
//            box.heightAnchor.constraint(equalToConstant: 100),
//            box.centerXAnchor.constraint(equalTo: centerXAnchor),
//            box.centerYAnchor.constraint(equalTo: centerYAnchor),
                                    ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

