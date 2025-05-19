//
//  TimerAlertController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

class TimerAlertViewController: UIViewController {
    
    // MARK: - Properties
    private let circleView = UIView()
    private let timeLabel = UILabel()
    private var initialCircleSize: CGFloat = 10
    private var finalCircleSize: CGFloat = UIScreen.main.bounds.width * 3
    private var initialPosition = CGPoint.zero
    
    // MARK: - Initializers
    init(startPosition: CGPoint) {
        self.initialPosition = startPosition
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCircle()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.backgroundColor = .clear
        
        // Setup circle view
        circleView.backgroundColor = .systemGreen
        circleView.layer.cornerRadius = initialCircleSize / 2
        circleView.frame = CGRect(
            x: initialPosition.x - initialCircleSize / 2,
            y: initialPosition.y - initialCircleSize / 2,
            width: initialCircleSize,
            height: initialCircleSize
        )
        view.addSubview(circleView)
        
        // Setup time label
        timeLabel.text = "Time!"
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        timeLabel.textAlignment = .center
        timeLabel.alpha = 0
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Animation Methods
    private func animateCircle() {
        let screenHeight = UIScreen.main.bounds.height
        let dropDistance = screenHeight * 0.6
        
        // First animation: Small growth and drop
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            self.circleView.frame = CGRect(
                x: self.initialPosition.x - 50,
                y: self.initialPosition.y + dropDistance - 50,
                width: 100,
                height: 100
            )
            self.circleView.layer.cornerRadius = 50
        }, completion: { _ in
            // Second animation: Dramatic growth filling the screen
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                let newSize = self.finalCircleSize
                self.circleView.frame = CGRect(
                    x: self.view.center.x - newSize/2,
                    y: self.view.center.y - newSize/2,
                    width: newSize,
                    height: newSize
                )
                self.circleView.layer.cornerRadius = newSize/2
            }, completion: { _ in
                // Final animation: Show the "Time!" text
                UIView.animate(withDuration: 0.3, animations: {
                    self.timeLabel.alpha = 1.0
                    
                    // Add a pulse animation to the text
                    self.timeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.timeLabel.transform = CGAffineTransform.identity
                    }
                })
            })
        })
    }
    
    @objc private func handleTap() {
        // Animate dismissal
        UIView.animate(withDuration: 0.4, animations: {
            self.timeLabel.alpha = 0
            self.timeLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.circleView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}

// MARK: - Extension for ImprovWorkoutController
extension ImprovWorkoutController {
    
    // Update your alertDidTrigger method to use the new TimerAlertViewController
    func alertDidTrigger() {
        print("⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰")
        
        // Get the center point of the timer view in the main view's coordinate system
        let timerCenter = timerView.convert(timerView.center, to: view)
        
        // Create and present the timer alert view controller
        let timerAlertVC = TimerAlertViewController(startPosition: timerCenter)
        present(timerAlertVC, animated: false)
        
        // Optional: Play a sound alert
//        AudioServicesPlaySystemSound(1005) // System sound for timer
    }
    
    // Optional: Add a method to handle timer completion in case you want to call it from elsewhere
    func showTimerAlert() {
        alertDidTrigger()
    }
}
