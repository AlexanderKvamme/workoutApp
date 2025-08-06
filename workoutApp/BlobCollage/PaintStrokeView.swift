//
//  PaintStrokeView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/08/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import Lottie

class PaintStrokeView: UIView {
    
    // MARK: - Configuration Properties
    var strokeColor: UIColor = .akLightGray {
        didSet {
            updateTint()
        }
    }
    
    var animationDuration: TimeInterval = 2.0
    var loopMode: LottieLoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0
    
    // MARK: - Private Properties
    private var containerView: UIView?
    private var lottieView: LottieAnimationView?
    private var maskLottieView: LottieAnimationView?
    private var tintOverlay: UIView?
    private var isAnimating = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    convenience init(frame: CGRect, strokeColor: UIColor) {
        self.init(frame: frame)
        self.strokeColor = strokeColor
        updateTint()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView?.frame = bounds
        lottieView?.frame = bounds
        maskLottieView?.frame = bounds
        tintOverlay?.frame = bounds
    }
    
    // MARK: - Public Methods
    func play() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Reset both animations
        maskLottieView?.currentProgress = 0
        lottieView?.currentProgress = 0
        
        maskLottieView?.animationSpeed = animationSpeed
        lottieView?.animationSpeed = animationSpeed
        
        maskLottieView?.loopMode = loopMode
        lottieView?.loopMode = loopMode
        
        // Start both animations
        maskLottieView?.play()
        lottieView?.play { [weak self] completed in
            self?.isAnimating = false
        }
    }
    
    func stopDrawing() {
        maskLottieView?.pause()
        lottieView?.pause()
        isAnimating = false
    }
    
    func resetDrawing() {
        maskLottieView?.stop()
        lottieView?.stop()
        maskLottieView?.currentProgress = 0
        lottieView?.currentProgress = 0
        isAnimating = false
    }
    
    func pauseDrawing() {
        maskLottieView?.pause()
        lottieView?.pause()
    }
    
    func resumeDrawing() {
        if !isAnimating {
            play()
        } else {
            maskLottieView?.play()
            lottieView?.play()
        }
    }
    
    // Animate to a specific progress (0.0 to 1.0)
    func animateToProgress(_ progress: CGFloat, duration: TimeInterval = 1.0) {
        guard let lottieView = lottieView,
              let maskLottieView = maskLottieView else { return }
        
        let fromProgress = lottieView.currentProgress
        let toProgress = progress
        
        maskLottieView.play(fromProgress: fromProgress, toProgress: toProgress, loopMode: .playOnce)
        lottieView.play(fromProgress: fromProgress, toProgress: toProgress, loopMode: .playOnce)
    }
    
    // Set progress without animation
    func setProgress(_ progress: CGFloat) {
        maskLottieView?.currentProgress = progress
        lottieView?.currentProgress = progress
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        // Create container view
        let container = UIView()
        container.backgroundColor = .clear
        addSubview(container)
        self.containerView = container
        
        // Create mask Lottie view
        setupMaskLottieView()
        
        // Create visible Lottie view (invisible, just for timing)
        setupVisibleLottieView()
        
        // Create tint overlay
        setupTintOverlay()
        
        // Apply masking
        setupMasking()
    }
    
    private func setupMaskLottieView() {
        guard let container = containerView else { return }
        
        let maskLottie = LottieAnimationView(name: "paintstroke")
        maskLottie.contentMode = .scaleAspectFit
        maskLottie.loopMode = loopMode
        maskLottie.animationSpeed = animationSpeed
        maskLottie.currentProgress = 0
        maskLottie.backgroundColor = .clear
        
        self.maskLottieView = maskLottie
    }
    
    private func setupVisibleLottieView() {
        let lottieView = LottieAnimationView(name: "paintstroke")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = loopMode
        lottieView.animationSpeed = animationSpeed
        lottieView.currentProgress = 0
        lottieView.backgroundColor = .clear
        lottieView.alpha = 0 // Make it invisible, only used for timing
        
        addSubview(lottieView)
        self.lottieView = lottieView
    }
    
    private func setupTintOverlay() {
        guard let container = containerView else { return }
        
        let overlay = UIView()
        overlay.backgroundColor = strokeColor
        overlay.isUserInteractionEnabled = false
        
        container.addSubview(overlay)
        self.tintOverlay = overlay
    }
    
    private func setupMasking() {
        guard let container = containerView,
              let maskLottieView = maskLottieView else { return }
        
        // Use the mask Lottie view as a mask for the container
        container.mask = maskLottieView
    }
    
    private func updateTint() {
        tintOverlay?.backgroundColor = strokeColor
    }
}

// MARK: - Convenience Extensions
extension PaintStrokeView {
    
    // Animate drawing with custom completion
    func startDrawing(completion: @escaping (Bool) -> Void) {
        guard !isAnimating else {
            completion(false)
            return
        }
        
        play()
        
        // Use the Lottie completion callback
        lottieView?.play { completed in
            completion(completed)
        }
    }
    
    // Animate drawing from current position
    func continueDrawing() {
        guard let lottieView = lottieView,
              let maskLottieView = maskLottieView else { return }
        
        let currentProgress = lottieView.currentProgress
        
        maskLottieView.play(fromProgress: currentProgress, toProgress: 1.0, loopMode: .playOnce)
        lottieView.play(fromProgress: currentProgress, toProgress: 1.0, loopMode: .playOnce) { [weak self] _ in
            self?.isAnimating = false
        }
    }
    
    // Reverse the drawing animation
    func reverseDrawing() {
        guard let lottieView = lottieView,
              let maskLottieView = maskLottieView else { return }
        
        let currentProgress = lottieView.currentProgress
        
        maskLottieView.play(fromProgress: currentProgress, toProgress: 0.0, loopMode: .playOnce)
        lottieView.play(fromProgress: currentProgress, toProgress: 0.0, loopMode: .playOnce) { [weak self] _ in
            self?.isAnimating = false
        }
    }
}
