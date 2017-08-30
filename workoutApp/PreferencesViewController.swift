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
    
    private lazy var header: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "PREFERENCES"
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.sizeToFit()
        label.center = self.view.center // lazy is executed once so reference to self is not stored
        
        return label
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        view.addSubview(header)
    }
}

