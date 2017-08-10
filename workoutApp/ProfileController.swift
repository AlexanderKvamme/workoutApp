//
//  ProfileController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 03/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


final class ProfileController: UIViewController {
    
    // MARK: - Properties
    
    private var settingsButton = UIButton()
    private var stackView = UIStackView()
    private var scrollView = UIScrollView()
    private var header = UILabel()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        view.layoutIfNeeded()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupSettingsButton()
        setupHeader()
        setupScrollView()
        
        setupStackView()
        setupGoalsController()
    }
    
    private func setupScrollView(){
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = stackView.frame.size // enables/disable scrolling
    }
    
    private func setupStackView() {
        stackView = UIStackView(frame: CGRect.zero)
        stackView.backgroundColor = .dark
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        addWarnings(to: stackView)
        
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            ])
    }
    
    private func setupHeader() {
        header.text = "DASHBOARD"
        header.font = UIFont.custom(style: .bold, ofSize: .medium   )
        header.textColor = .dark
        header.textAlignment = .center
        header.sizeToFit()
        view.addSubview(header)
        
        // Layout
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.bottomAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 0),
            header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            header.rightAnchor.constraint(equalTo: settingsButton.rightAnchor, constant: 0),
            ])
    }
    
    private func setupSettingsButton() {
        settingsButton = UIButton(frame: CGRect.zero)
        let image: UIImage = UIImage(named: "settingsButtonRounded")!
        settingsButton.setImage(image, for: .normal)
        view.addSubview(settingsButton)
        
        let topRightInsets: CGFloat = 10
        let buttonDiameter: CGFloat = 20
        
        // Layout
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topRightInsets),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -topRightInsets),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonDiameter),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonDiameter),
            ])
    }
    
    private func setupGoalsController() {
        let goalStrings = ["Hold Header to make labels".uppercased(),
                           "Hold labels to complete".uppercased()]
        
        let goalsController = GoalsController(withGoals: goalStrings)
        addChildViewController(goalsController) // NOTE: Needed to make it work as its own viewController (with its own selectors)
        stackView.addArrangedSubview(goalsController.view)
    }
    
    // MARK: - Business Logic
    
    private func addWarnings(to stackView: UIStackView) {
        for i in 0..<3 {
            let box = Warningbox(withWarning: "Warning number \(i)")
            box.content?.xButton?.addTarget(self, action: #selector(xButtonHandler(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(box)
        }
    }
    
    func xButtonHandler(_ input: Warningbox) {
        // remove from stack and superview
        guard let entirebox = input.superview?.superview else { return }
        
        stackView.removeArrangedSubview(entirebox)
        entirebox.removeFromSuperview()
    }
    
    func setDebugColors() {
        scrollView.backgroundColor = .yellow
    }
}

