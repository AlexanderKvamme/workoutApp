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
class AnimatedScreenHeader: UIView {
    
    // MARK: - Properties
    
    var button = UIButton()
    let subheaderContainer = UIView()
    let subheaderLabel = UILabel()
    var header: AKAnimatedCharactersView!
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    init(header: String, subheader: String, headerColor: UIColor = .akDark) {
        super.init(frame: CGRect.zero)
        setupViews(header: header, subheader: subheader, headerColor: headerColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func play() {
        resetAnimation()
        
        header.startAnimation()
        slideBadgeUp()
    }
    
    func slideBadgeUp() {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.4,        // Low damping = more bounce
            initialSpringVelocity: 1.5,         // High velocity = more dramatic
            options: [.curveEaseOut],
            animations: {
                self.subheaderContainer.transform = CGAffineTransform(rotationAngle: -.pi/64).scaledBy(x: 1, y: 1).translatedBy(x: 0, y: 0)
            }
        )
    }
    
    func resetAnimation() {
        header.resetAnimation()
        subheaderContainer.transform = CGAffineTransform(translationX: 0, y: 40).scaledBy(x: 1.1, y: 1.1).rotated(by: 0)
        subheaderContainer.layoutIfNeeded()
    }
    
    // MARK: - Setup
    
    private func setupViews(header: String, subheader: String, headerColor: UIColor = .akDark) {
        self.header = AKAnimatedCharactersView(
            text: header,
//            font: UIFont(name: "PirataOne-Regular", size: 110)!,
            font: Texturina(size: 80, boldness: 1200).uiFont,
            textColor: headerColor
        )
        
        
        // Configure subheader container with rounded background
        subheaderContainer.backgroundColor = .black
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
