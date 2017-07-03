//
//  ExerciseCollectionViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    
    var label: UILabel!
    
    init(labelText: String) {
        super.init(frame: CGRect.zero)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = labelText
        label.backgroundColor = .red
        label.text = "99"
        label.backgroundColor = .purple
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

