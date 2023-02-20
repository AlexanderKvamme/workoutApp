//
//  SummaryScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT


final class SummaryScreen: UIViewController {
    
    // MARK: - Properties
    
    let header = SummaryHeader()
    let animationView = SummaryAnimationView()
    let summarySection = SummarySectionView()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.start()
    }
    
    // MARK: - Methods
    
    func addSubviewsAndConstraints() {
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(screenWidth)
        }
        
        view.addSubview(summarySection.view)
        summarySection.view.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
}
