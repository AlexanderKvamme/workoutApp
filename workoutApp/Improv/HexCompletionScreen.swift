//
//  HexCompletionScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT


// MARK: - HexCompletionScreen
class HexCompletionScreen: UIViewController {
    
    // MARK: - Properties
    private let exercise: Exercise
    let centerHexView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    
    // MARK: - Initialization
    init(exercise: Exercise) {
        self.exercise = exercise
        super.init(nibName: nil, bundle: nil)
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
    
    // MARK: - UI Setup
    private func setupHexView() {
        // Add the center hex view
        view.addSubview(centerHexView)
        centerHexView.translatesAutoresizingMaskIntoConstraints = false
        
        // Size the hex to be about 60% of the screen width
        let hexSize = UIScreen.main.bounds.width * 0.6
        
        NSLayoutConstraint.activate([
            centerHexView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerHexView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerHexView.widthAnchor.constraint(equalToConstant: hexSize),
            centerHexView.heightAnchor.constraint(equalToConstant: hexSize)
        ])
        
        // Create a hexagon shape layer
        let hexLayer = CAShapeLayer()
        hexLayer.path = HexagonPathCreator.createHexagonPath(in: CGRect(x: 0, y: 0, width: hexSize, height: hexSize)).cgPath
        hexLayer.fillColor = UIColor.green.cgColor
        centerHexView.layer.addSublayer(hexLayer)
        
        // Store a reference to the shape layer for animation purposes
        centerHexView.layer.mask = hexLayer
        centerHexView.backgroundColor = .green
    }
    
    private func setupLabels() {
        // Title Label
        titleLabel.text = exercise.getName()
        titleLabel.font = AKFont.round(.black, 24)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        centerHexView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerHexView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: centerHexView.topAnchor, constant: 40)
        ])
        
        // Description Label
        descriptionLabel.text = "Completed!"
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
        doneButton.setTitleColor(.green, for: .normal)
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
