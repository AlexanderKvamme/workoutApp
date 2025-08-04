//
//  SelectionViewHeader.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import AKKIT
import SnapKit

/// Header used in WorkoutSelectionView, HistorySelectionView
class SelectionViewHeader: UIView {
    
    // MARK: - Properties
    
    var button = UIButton()
    var label = UILabel()
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    init(header: String, subheader: String) {
        super.init(frame: CGRect.zero)
        setupViews(header: header, subheader: subheader)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews(header: String, subheader: String) {
        let headerLabel = UILabel()
        let subheaderContainer = UIView()
        let subheaderLabel = UILabel()
        
        // Configure header label
        headerLabel.text = header
        headerLabel.font = UIFont(name: "PirataOne-Regular", size: 110)
        headerLabel.textAlignment = .center
        headerLabel.textColor = .black
        
        // Configure subheader container with rounded background
        subheaderContainer.backgroundColor = UIColor.akBlue
        subheaderContainer.layer.cornerRadius = 8
        subheaderContainer.clipsToBounds = true
        
        // Configure subheader label
        subheaderLabel.text = subheader
        subheaderLabel.font = AKFont.fulbo(24)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = .white
        
        // Add subviews
        addSubview(headerLabel)
        addSubview(subheaderContainer)
        subheaderContainer.addSubview(subheaderLabel)
        
        // Setup constraints with SnapKit
        headerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        subheaderContainer.snp.makeConstraints { make in
            make.centerX.equalTo(headerLabel)
            make.centerY.equalTo(headerLabel).offset(45)
        }
        
        subheaderLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subheaderContainer.transform = subheaderContainer.transform.rotated(by: -.pi/64)
    }
}
