//
//  HexCompletionScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import Lottie
import SnapKit


// MARK: - HexCompletionScreen
class HexCompletionScreen: UIViewController {
    
    let hex = HexagonalView(frame: HEX_FRAME)
    let confettiView = ConfettiView(frame: UIScreen.main.bounds)

    // MARK: - Properties
    private let exercise: Exercise
    private var animatedTitleView: AnimatedTextView!
    private let descriptionLabel = UILabel()
    private let doneButton = GradientBorderButton(type: .system)
    private let checkMark: LottieAnimationView = {
        let anim = LottieAnimationView(asset: "checkmark-lottie")
        anim.currentFrame = 0  // Set the animation to start at frame 0
        anim.loopMode = .playOnce  // Or any other loop mode you prefer
        anim.animationSpeed = 1.0  // Normal speed
        anim.contentMode = .scaleAspectFit
        return anim
    }()
    private var subtitle = UILabel()
    private var body = UITextView()
    private var gradientBorderView = GradientBorderView()
    
    // MARK: - Initialization
    init(exercise: Exercise) {
        self.exercise = exercise
        super.init(nibName: nil, bundle: nil)
        hex.alpha = 0
        hex.fillColor = .black
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve // This will be overridden by our custom transition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        view.addSubview(confettiView)
        view.addSubview(hex)
        view.addSubview(checkMark)
        view.addSubview(body)
        view.addSubview(subtitle)
        view.addSubview(doneButton)
        setupHexView()
        setupAnimatedTitle()
        setupSubtitleLabel()
        setupBody()
        setupDoneButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        confettiView.removalPoint = doneButton.center
        confettiView.startConfettiCannon(at: CGPoint(x: HEX_FRAME.minX+HEX_WIDTH/2, y: HEX_FRAME.minY + HEX_WIDTH/2), keepOnScreen: true)
        
        // Start the animations
        animatedTitleView.animate()
        checkMark.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.doneButton.animateBorderInSimple(duration: 0.8) {
                self.pulseButton()
                self.doneButton.startRotatingGradient(duration: 4.0)
            }
        }
    }
    
    func pulseButton() {
        // First animate to a larger size with spring physics
        UIView.animate(withDuration: 0.4,
                      delay: 0,
                      usingSpringWithDamping: 0.5,  // Lower damping means more oscillation
                      initialSpringVelocity: 0.5,   // Initial velocity of the spring
                      options: [],
                      animations: {
            self.doneButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            // Then animate back to normal size with spring physics
            UIView.animate(withDuration: 0.4,
                          delay: 0,
                          usingSpringWithDamping: 0.6,
                          initialSpringVelocity: 0.3,
                          options: [],
                          animations: {
                self.doneButton.transform = .identity
            })
        }
    }
    
    // MARK: - UI Setup
    private func setupHexView() {
        checkMark.snp.makeConstraints { make in
            make.edges.equalTo(hex).inset(64)
        }
    }
    
    private func setupAnimatedTitle() {
        // Create the animated title view with "Success!" text
        animatedTitleView = AnimatedTextView(
            text: "Success!",
            font: AKFont.round(.black, 48),
            color: .black
        )
        
        view.addSubview(animatedTitleView)
        
        // Set constraints
        animatedTitleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animatedTitleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            animatedTitleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animatedTitleView.heightAnchor.constraint(equalToConstant: 60),
            animatedTitleView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            animatedTitleView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSubtitleLabel() {
        subtitle.text = "That was great!"
        subtitle.font = AKFont.round(.black, 24)
        subtitle.textAlignment = .center
        subtitle.textColor = .black
        subtitle.numberOfLines = 0

        subtitle.snp.makeConstraints { make in
            make.top.equalTo(hex.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }
    }
        
    func setupBody() {
        body.text = "The workout is saved and you can focus on other muscles or skills for a while. Check back to see when the hex components require work."
        body.font = AKFont.round(.medium, 20)
        body.textColor = .lightGray
        body.backgroundColor = .clear
        body.textAlignment = .center
        
        body.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(doneButton.snp.top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient border layout when view size changes
        doneButton.updateGradientBorderLayout()
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = AKFont.round(.bold, 18)
        doneButton.backgroundColor = .white
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.layer.cornerRadius = 20
        doneButton.addTarget(self, action: #selector(dismissScreen), for: .touchUpInside)
        
        // Configure the gradient border
        doneButton.borderWidth = 7.0
        doneButton.gradientColors = [.systemPurple, .systemCyan, .systemPurple, .systemPink]
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Start the rotation animation
        doneButton.startRotatingGradient()
    }
    
    
    // MARK: - Actions
    @objc private func dismissScreen() {
        print("tryna dismiss")
        dismiss(animated: true)
    }
}

// MARK: - HexTransitionDelegate
class HexTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private var originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HexTransitionAnimator(isPresenting: true, originFrame: originFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HexTransitionAnimator(isPresenting: false, originFrame: originFrame)
    }
}
