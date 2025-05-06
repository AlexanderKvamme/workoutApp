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


// MARK: - HexCompletionScreen
class HexCompletionScreen: UIViewController {
    
    let hex = HexagonalView(frame: HEX_FRAME)
    let confettiView = ConfettiView(frame: UIScreen.main.bounds)

    // MARK: - Properties
    private let exercise: Exercise
    let centerHexView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    private let checkMark: LottieAnimationView = {
//        imageView.tintColor = .white
        let anim = LottieAnimationView(asset: "checkmark-lottie")
        anim.currentFrame = 0  // Set the animation to start at frame 0
        anim.loopMode = .playOnce  // Or any other loop mode you prefer
        anim.animationSpeed = 1.0  // Normal speed
        anim.contentMode = .scaleAspectFit
        return anim
    }()
    private var subtitle = UILabel()
    
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
        setupHexView()
        setupLabels()
        setupDoneButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        confettiView.startConfettiCannon(at: CGPoint(x: HEX_FRAME.minX+HEX_WIDTH/2, y: HEX_FRAME.minY + HEX_WIDTH/2), keepOnScreen: true)
        checkMark.play()
    }
    
    // MARK: - UI Setup
    private func setupHexView() {
        // Add the center hex view
        view.addSubview(centerHexView)
        centerHexView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confettiView)
        view.addSubview(hex)
        view.addSubview(checkMark)
        
        // Size the hex to be about 60% of the screen width
        let hexSize = UIScreen.main.bounds.width * 0.75
        
        centerHexView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(hexSize)
        }
        
        checkMark.snp.makeConstraints { make in
            make.edges.equalTo(hex).inset(64)
        }
        
    }
    
    private func setupLabels() {
        // Title Label
        titleLabel.text = "Success!"
        titleLabel.font = AKFont.round(.black, 48)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        
        subtitle.text = "That was some real nice work!"
        subtitle.font = AKFont.round(.black, 24)
        subtitle.textAlignment = .center
        subtitle.textColor = .black
        subtitle.numberOfLines = 0

        centerHexView.addSubview(titleLabel)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(hex.snp.bottom)
            make.left.right.equalToSuperview().inset(24)
        }
        
        // Description Label
        descriptionLabel.text = ""
        descriptionLabel.font = AKFont.round(.medium, 18)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        centerHexView.addSubview(descriptionLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: centerHexView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: centerHexView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: centerHexView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = AKFont.round(.bold, 18)
        doneButton.backgroundColor = .white
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.layer.cornerRadius = 20
        doneButton.addTarget(self, action: #selector(dismissScreen), for: .touchUpInside)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
