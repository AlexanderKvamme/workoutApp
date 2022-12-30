//
//  TimerButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import UIKit

class TimerButton: UIView {
    
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
        label.font = .custom(style: .bold, ofSize: .medium)
        label.textColor = .akLight//.withAlphaComponent(.opacity.faded.rawValue)
        label.textAlignment = .center
        label.backgroundColor = .akDark
        label.layer.cornerRadius = 8
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(globalTimerHeight)
            make.width.equalTo(40)
        }
        
        let tr = UITapGestureRecognizer(target: self, action: #selector(insideTap))
        addGestureRecognizer(tr)
    }
    
    // MARK: - Timer
    
    
    @objc func insideTap() {
        let tappedNumber = Int(label.text!)!
        akt.delegate = delegate
        akt.startCountUpTo(tappedNumber)
    }
}
