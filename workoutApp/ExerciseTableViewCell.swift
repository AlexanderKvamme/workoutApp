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
    var collectionViewOfSets: ExerciseSetCollectionView! // each table view cell contains a collectionViewController
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        setupBox()
        setupConstraints()
    }
    
    convenience init(withExercise exercise: Exercise, andIdentifier cellIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: cellIdentifier)
        
        setupSetCollectionViews(exercise)
        print("setting up collectionView")
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSetCollectionViews(_ exercise: Exercise) {
        print("tryna setup make a collectionview from \(exercise.name)")
//        collectionViewOfSets = ExerciseSetCollectionViewController(withExercise: exercise)
        collectionViewOfSets = ExerciseSetCollectionView(withExercise: exercise)
        collectionViewOfSets.frame = box.boxFrame.frame // the graphic part of the box
        collectionViewOfSets.backgroundColor = .purple
        collectionViewOfSets.alpha = 0.5
        addSubview(collectionViewOfSets)
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

