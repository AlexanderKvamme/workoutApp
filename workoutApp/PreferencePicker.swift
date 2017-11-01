//
//  PreferencesSegmentController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Contains a header and some sort of picking device for selecting between settings such as kg/lbs/grams

final class PreferencePicker: UIViewController {

    // MARK: - Properties
    
    let header: UILabel = {
        let label = UILabel()
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.textColor = .dark
        return label
    }()
    
    lazy var stack: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        
        return stackView
    }()
    
    let userPreference: UserPreference
    
    // MARK: - Initializers
    
    init(withPreference userPreference: UserPreference) {
        self.userPreference = userPreference
        
        super.init(nibName: nil, bundle: nil)
        setHeader(to: userPreference.preferenceName)
        setupPreferenceChoiceLabels(forPreference: userPreference)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        addSubviewsAndConstraints()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupPreferenceChoiceLabels(forPreference: userPreference)
    }
    
    // MARK: - Methods
    
    // MARK: Private methods
    
    private func addSubviewsAndConstraints() {
        // Add to view
        view.addSubview(header)
        view.addSubview(stack)
        
        // Set constraints
        view.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60),
            view.widthAnchor.constraint(equalToConstant: 300),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            stack.topAnchor.constraint(equalTo: header.bottomAnchor),
            ])
    }
    
    private func setupPreferenceChoiceLabels(forPreference preference: UserPreference) {
        let choices = preference.choices
        stack.removeArrangedSubviews()
        
        guard let currentlySelectedChoice = UserDefaultsFacade.getActiveSelection(for: preference) else {
            fatalError("No active selection in user defaults")
        }
        
        for str in choices {
            // Make label
            let btn = UIButton()
            btn.setTitle(str, for: .normal)
            btn.sizeToFit()
            
            // Make bold if selected
            if str == currentlySelectedChoice {
                btn.titleLabel?.font = UIFont.custom(style: .medium, ofSize: .medium)
                btn.setTitleColor(.dark, for: .normal)
                btn.titleLabel?.textColor = .dark
            } else {
                btn.setTitleColor(.dark, for: .normal)
                btn.titleLabel?.alpha = Constant.alpha.faded
                btn.titleLabel?.font = UIFont.custom(style: .medium, ofSize: .medium)
            }
            
            stack.addArrangedSubview(btn)
        }
        
        view.addSubview(stack)
    }
    
    private func addGestureRecognizer() {
        let gr = UITapGestureRecognizer(target: self, action: #selector(controllerWasTapped(_:)))
        view.addGestureRecognizer(gr)
    }
    
    private func setHeader(to str: String) {
        self.header.text = str.uppercased()
        self.header.applyCustomAttributes(.medium)
        self.header.sizeToFit()
    }
    
    private func setDebugColors() {
        header.backgroundColor = .blue
        view.backgroundColor = .red
    }
    
    // Gesture handlers
    
    @objc private func controllerWasTapped(_ gesture: UIGestureRecognizer) {
    
        let point = gesture.location(in: stack)
        
        for btn in stack.subviews {

            guard btn.frame.contains(point), let btn = btn as? UIButton, let str = btn.titleLabel?.text else {
                    fatalError("Could not unwrap label's text")
            }
            UserDefaultsFacade.setSelection(forPreference: userPreference, to: str)
            setupPreferenceChoiceLabels(forPreference: userPreference)
        }
    }
}

