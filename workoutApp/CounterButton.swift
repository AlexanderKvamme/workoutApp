//
//  CounterButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import UIKit


class CounterButton: UIView {
    
    let akt = AKTimer()
    let label = UILabel()
    var delegate: AKTimerDelegate?
    
    init(_ text: String, timerDelegate: AKTimerDelegate) {
        super.init(frame: .zero)
        self.delegate = timerDelegate
        setup()
        label.text = text
        label.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        label.textAlignment = .left
        label.font = .custom(style: .bold, ofSize: .big)
        label.textColor = .akDark.withAlphaComponent(.opacity.faded.rawValue)
        label.textAlignment = .center
        label.backgroundColor = .akDark
        label.backgroundColor = .clear
        label.layer.cornerRadius = 8
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.adjustsFontSizeToFitWidth = true
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.height.equalTo(globalTimerHeight)
            make.width.equalTo(48)
        }
    }
    
}
