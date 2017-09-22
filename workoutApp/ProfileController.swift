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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.hideSelectionIndicator(shouldAnimate: true)
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
        self.view.layoutSubviews()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .light
        view.layoutIfNeeded()
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        setupSettingsButton()
        setupHeader()
        setupScrollView()
        
        setupStackView()

        addWarnings(to: stackView)
        addGoals(to: stackView)
        addSuggestions(to: stackView)
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
        scrollView.contentSize = stackView.frame.size // enables/disable scrolling if needed
    }
    
    private func setupStackView() {
        stackView = UIStackView(frame: CGRect.zero)
        stackView.backgroundColor = .dark
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            ])
    }
    
    private func setupHeader() {
        header.text = "DASHBOARD"
        header.font = UIFont.custom(style: .bold, ofSize: .medium)
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
        settingsButton.setImage(UIImage(named: "wrench"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonHandler), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        // Layout
        let rightInset: CGFloat = 10
        let topInset: CGFloat = 30
        let buttonDiameter: CGFloat = 25
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -rightInset),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonDiameter),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonDiameter),
            ])
    }
    
    private func addGoals(to stackView: UIStackView) {
        let goalsController = GoalsController()
        addChildViewController(goalsController) // NOTE: Needed to make it work as its own viewController (with its own selectors)
        stackView.addArrangedSubview(goalsController.view)
    }
    
    // MARK: - Business Logic
    
    private func makeWarningBox(fromWarning warning: Warning) -> Warningbox? {
        var newBox: Warningbox? = nil
        newBox = Warningbox(withWarning: warning)
        newBox!.content?.xButton?.addTarget(self, action: #selector(xButtonHandler(_:)), for: .touchUpInside)
        return newBox
    }
    
    private func addWarnings(to stackView: UIStackView) {
        // Get sorted messages from Core data
        let arrayOfWarnings = DatabaseFacade.fetchWarnings()
        if let arrayOfWarnings = arrayOfWarnings {
            for warning in arrayOfWarnings {
                if let newWarningBox = makeWarningBox(fromWarning: warning) {
                    stackView.addArrangedSubview(newWarningBox)
                }
            }
        }
    }
    
    private func addSuggestions(to stackView: UIStackView) {    
        let suggestionController = SuggestionController()
        addChildViewController(suggestionController)
        stackView.addArrangedSubview(suggestionController.view)
    }
    
    func setDebugColors() {
        scrollView.backgroundColor = .yellow
    }
    
    // MARK: Handlers
    
    @objc func xButtonHandler(_ box: UIButton) {
        if let box = box.superview?.superview as? Warningbox {
            stackView.removeArrangedSubview(box)
            box.deleteWarning()
            box.removeFromSuperview()
        }
    }
    
    @objc private func settingsButtonHandler() {
        let preferencesController = PreferencesController()
        navigationController?.pushViewController(preferencesController, animated: true)
    }
}

