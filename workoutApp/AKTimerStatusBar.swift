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
        // Keep the container transparent so the X does not sit on a white/glass pill.
        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true
        
        // Fill view
        fillView.backgroundColor = .akDark
        addSubview(fillView)
        
        // Animate from left
        self.fillView.frame = CGRect(x: 0, y: 0, width: 0, height: 500)
        
        // Cancel button
        // Keep the tap target, but don't draw a separate button background over the timer.
        cancelButtonBackground.backgroundColor = .clear
        cancelButtonBackground.tintColor = .akLight
        cancelButton.image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        cancelButton.tintColor = .akLight
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
            self.fillView.frame = CGRect(x: 0, y: 0, width: globalTimerWidth, height: globalTimerHeight)
        } completion: { bool in completion() }
    }
}

