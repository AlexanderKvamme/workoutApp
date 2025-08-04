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
    let subheaderContainer = UIView()
    let subheaderLabel = UILabel()
    var header: AKAnimatedCharactersView!
    
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
    
    // MARK: - Public Methods
    
    func play() {
        resetAnimation()
        
        header.startAnimation()
        UIView.animate(withDuration: 1) {
            self.subheaderContainer.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1).rotated(by: -.pi/64)
        }
    }
    
    func resetAnimation() {
        header.resetAnimation()
        subheaderContainer.transform = CGAffineTransform(translationX: 0, y: 10).scaledBy(x: 1.1, y: 1.1).rotated(by: 0)
        subheaderContainer.layoutIfNeeded()
    }
    
    // MARK: - Setup
    
    private func setupViews(header: String, subheader: String) {
        self.header = AKAnimatedCharactersView(
            text: header,
            font: UIFont(name: "PirataOne-Regular", size: 110)!,
            textColor: .black
        )
        
        
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
        addSubview(self.header)
        addSubview(subheaderContainer)
        subheaderContainer.addSubview(subheaderLabel)
        
        // Setup constraints with SnapKit
        self.header.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        subheaderContainer.snp.makeConstraints { make in
            make.centerX.equalTo(self.header)
            make.centerY.equalTo(self.header).offset(45)
        }
        
        subheaderLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
