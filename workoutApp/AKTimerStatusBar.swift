//
//  AKTimerStatusBar.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import UIKit


final class AKTimerStatusBar: UIView {
    
    var fillView = UIView()
    var cancelButtonBackground = UIButton()
    var cancelButton = UIImageView()
    var time: TimeInterval
    var delegate: AKTimerStatusBarDelegate?
    
    init(time: TimeInterval) {
        self.time = time
        
        super.init(frame: .zero)
        
        // Background view
        backgroundColor = .akDark.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true
        
        // Fill view
        fillView.backgroundColor = .akDark
        addSubview(fillView)
        
        // Animate from left
        self.fillView.frame = CGRect(x: 0, y: 0, width: 0, height: 500)
        
        // Cancel button
        cancelButtonBackground.backgroundColor = .akDark
        cancelButton.image = UIImage.close24.withTintColor(.akLight)
        cancelButton.contentMode = .scaleAspectFit
        cancelButton.isUserInteractionEnabled = false
        cancelButtonBackground.addTarget(self, action: #selector(cancelTimer), for: .touchUpInside)
        
        addSubview(cancelButtonBackground)
        addSubview(cancelButton)
        cancelButtonBackground.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(globalCancelTimerWidth)
        }
        cancelButton.snp.makeConstraints { make in
            make.edges.equalTo(cancelButtonBackground).inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ current: Int, _ target: Int) {
        let _: CGFloat = CGFloat(current)/CGFloat(target)*100
    }
    
    @objc func cancelTimer() {
        delegate?.statusBarDidFinish(false)
    }
    
    func startAnimation(seconds: TimeInterval, completion: @escaping (()->())) {
         UIView.animate(withDuration: time, delay: 0, options: []) {
            self.fillView.frame = CGRect(x: 0, y: 0, width: globalTimerWidth - globalCancelTimerWidth, height: globalTimerHeight)
        } completion: { bool in completion() }
    }
}

