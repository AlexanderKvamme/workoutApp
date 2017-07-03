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
//    var collectionViewController: ExerciseSetCollectionViewController!
    var collectionViewOfSets: ExerciseSetCollectionView! // each cell contains a collectionviewcontroller
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        setupBox()
        setupConstraints()
    }
    
    convenience init(withExercise exercise: Exercise, andIdentifier cellIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: cellIdentifier)
        
        print("in cell: making lift collectionVC")
        collectionViewOfSets = ExerciseSetCollectionView(withExercise: exercise)
        collectionViewOfSets.frame = box.boxFrame.frame
        print("frame set: ", collectionViewOfSets.frame)
        addSubview(collectionViewOfSets)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
    }
    
    private func setupBox() {
        let boxFactory = BoxFactory.makeFactory(type: .ExerciseProgressBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        
        contentView.addSubview(box)
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: box.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: 10),
            contentView.widthAnchor.constraint(equalToConstant: Constant.UI.width),
                                    ])
    }
}

