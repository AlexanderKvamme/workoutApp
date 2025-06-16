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
    let starView = StarView()
    let starRatingView = StarRatingView(frame: CGRect(x: 0, y: 0, width: 300, height: 64))

    // MARK: - Properties
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
    init(skill: Skill) {
        super.init(nibName: nil, bundle: nil)
        
        let log = DatabaseFacade.makeWorkoutLog(ofSkill: skill)
        DatabaseFacade.saveContext()
        
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
        view.addSubview(starRatingView)
//        view.addSubview(starView)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.doneButton.animateBorderIn(duration: 0.8) {
                self.doneButton.startRotatingGradient(duration: 4.0)
            }
        }
        
        starRatingView.animateIn {
            print("Stars animation completed!")
        }
        
        // After some delay, set a rating (optional)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.starRatingView.setRating(5, animated: true)
        }
    }
    
    func pulseStar() {
        // First animate to a larger size with spring physics
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,  // Lower damping means more oscillation
                       initialSpringVelocity: 1,   // Initial velocity of the spring
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
        
//        starView.snp.makeConstraints { make in
//            make.edges.equalTo(hex).inset(42)
//        }
    }
    
    private func setupAnimatedTitle() {
        // Create the animated title view with "Success!" text
        animatedTitleView = AnimatedTextView(
            text: "Success!",
            font: AKFont.round(.black, 48),
            color: .black,
            flashPercentage: 100
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
        
        starRatingView.snp.makeConstraints { make in
            make.top.equalTo(animatedTitleView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(32)
        }
    }
    
    private func setupSubtitleLabel() {
        subtitle.text = "That was great!"
        subtitle.font = AKFont.round(.black, 30)
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
        body.isEditable = false
        body.isUserInteractionEnabled = false
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
        doneButton.setTitle(" Dismiss ".uppercased(), for: .normal)
        doneButton.titleLabel?.font = AKFont.round(.bold, 24)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 20
        doneButton.addTarget(self, action: #selector(dismissScreen), for: .touchUpInside)
        
        // Configure the gradient border
        doneButton.borderWidth = 4.0
//        doneButton.gradientColors = [UIColor(hexString: "#B8BDFC"), UIColor(hexString: "#5474F7"), UIColor(hexString: "#4002F7")]
        doneButton.gradientColors = [UIColor(hexString: "#D8B4FE"), UIColor(hexString: "#A855F7"), UIColor(hexString: "#7E22CE")]
        doneButton.gradientColors = [UIColor(hexString: "#C8A2F5"), UIColor(hexString: "#9747FF"), UIColor(hexString: "#6B21A8")]
        doneButton.gradientColors = [UIColor(hexString: "#D0BFFF"), UIColor(hexString: "#8B5CF6"), UIColor(hexString: "#4C1D95")]
        doneButton.gradientColors = [UIColor(hexString: "#E9D5FF")  , UIColor(hexString: "#7E22CE")]
        doneButton.gradientColors = [UIColor(hexString: "#000000"), UIColor(hexString: "#1A1A1A"), UIColor(hexString: "#333333")]
        doneButton.gradientColors = [UIColor(hexString: "#000000"), UIColor(hexString: "#222222"), UIColor(hexString: "#444444")]
        doneButton.gradientColors = [.akOrange, .akDarkOrange]
//        doneButton.gradientColors = [UIColor(hexString: "#FFCB80"), UIColor(hexString: "#FFB54C"), UIColor(hexString: "#FF9500")]
        doneButton.gradientColors = [.black]

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        
        // Start the rotation animation
        doneButton.startRotatingGradient()
    }
    
    // MARK: - Actions
    @objc private func dismissScreen() {
        dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }
//        navigationController?.popToRootViewController(animated: true)
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
