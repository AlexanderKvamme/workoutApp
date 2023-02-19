//
//  SummaryScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import UIKit


final class SummaryScreen: UIViewController {
    
    // MARK: - Properties
    
    let header = SummaryHeader()
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init(nibName: nil, bundle: nil)
        
        addSubviewsAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .akLight
    }
    
    // MARK: - Methods
    
    func addSubviewsAndConstraints() {
        view.addSubview(header)
        
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            make.centerX.equalToSuperview()
        }
    }
    
}
