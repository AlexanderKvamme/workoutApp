//
//  ViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 11/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.light
        
        // testlabel
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        label.backgroundColor = UIColor.primary
        view.addSubview(label)
        label.text = "bam".uppercased()
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = UIColor.light
    }
}

