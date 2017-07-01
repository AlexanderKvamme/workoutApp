//
//  ExerciseTableViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    var header: UILabel!
    var box: Box!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .red
        setupConstraints()
        setupHeader()
        setupBox()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHeader() {
        header = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        header.text = "Some Header".uppercased()
        header.sizeToFit()
        header.backgroundColor = .purple
        addSubview(header)
    }
    
    private func setupBox() {
        // Box
        let boxFactory = BoxFactory.makeFactory(type: .ExerciseProgressBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent!)
        view.addSubView(box)
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([heightAnchor.constraint(equalToConstant: 200),
                                    widthAnchor.constraint(equalToConstant: Constant.UI.width),
                                    
                                    
                                    ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
