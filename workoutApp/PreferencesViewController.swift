//
//  PreferencesViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        print("initializing")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light

        let header = UILabel(frame: .zero)
        header.text = "PREFERENCES"
        header.font = UIFont.custom(style: .bold, ofSize: .big)
        header.sizeToFit()
        header.center = view.center
        
        view.addSubview(header)
    }
}

