//
//  ViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 11/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit


class PreferencesController: UIViewController {

    // MARK: - Properties
    
    private lazy var header: PickerHeader = {
        let label = PickerHeader(text: "PREFERENCES")
        label.setTopColor(.akDark)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var footer: ApproveButtonFooter = {
        let f = ApproveButtonFooter(withColor: .dark)
        f.translatesAutoresizingMaskIntoConstraints = false
        f.approveButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return f
    }()
    
    private var preferencePickers: [PreferencePicker]
    
    // MARK: - Initializers
    
    init() {
        var preferencePickers = [PreferencePicker]()
        
        for preference in UserPreferenceHolder.preferences {
            let preferencePicker = PreferencePicker(withPreference: preference)
            preferencePickers.append(preferencePicker)
        }
        
        self.preferencePickers = preferencePickers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addSubViewsAndConstraints()
        addPreferenceControllers()
    }

    // MARK: - Methods

    // Private methods
    
    private func addSubViewsAndConstraints() {
        // Add subviews
        view.addSubview(header)
        view.addSubview(footer)
        
        // Constraints
        NSLayoutConstraint.activate([

            header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.headers.pickerHeader.topSpacing),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
    
    private func setupView() {
        view.backgroundColor = .akLight
    }
    
    private func addPreferencePicker(for preferencePicker: PreferencePicker) {
        
        guard let index = preferencePickers.index(of: preferencePicker) else {
            fatalError()
        }
        
        // Add to view
        addChild(preferencePicker)
        view.addSubview(preferencePicker.view)
        
        // Make Constraints
        preferencePicker.view.translatesAutoresizingMaskIntoConstraints = false
        var topConstraint = NSLayoutConstraint()
        
        // Constraint to header or to the preferenceController aboves
        if index == 0 {
            topConstraint = preferencePicker.view.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100)
        } else {
            topConstraint = preferencePicker.view.topAnchor.constraint(equalTo: preferencePickers[index-1].view.bottomAnchor)
        }
        
        NSLayoutConstraint.activate([
            preferencePicker.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            topConstraint,
            ])
    }
    
    private func addPreferenceControllers() {
        // Add preferenceControllers
        for preferencePicker in preferencePickers {
            addPreferencePicker(for: preferencePicker)
        }
    }
    
    @objc private func dismissVC() {
        UserDefaults.standard.synchronize()
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

