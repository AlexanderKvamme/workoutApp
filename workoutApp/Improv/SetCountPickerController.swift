//
//  SetCountPickerController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT

class SetCountPickerController: UIViewController {
    
    // MARK: - Properties
    private let skill: Skill
    private let titleLabel = UILabel()
    private let stepperFrame = CGRect(x: 0, y: 0, width: 222, height: 64)
    private let setOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private let superStepper: SuperStepper
    private let startButton = UIButton()
    private let backButton = UIButton.make(.back)
    
    // Completion handler to execute when a set count is selected
    private let completionHandler: (Int) -> Void
    
    // MARK: - Initializers
    init(skill: Skill, completionHandler: @escaping (Int) -> Void) {
        self.skill = skill
        self.completionHandler = completionHandler
        self.superStepper = SuperStepper(frame: stepperFrame, options: setOptions)
        
        superStepper.activeColor = .black
        superStepper.inactiveColor = .black

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Configure title label
        titleLabel.text = "How many sets?"
        titleLabel.font = AKFont.round(.black, 32)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        // Configure stepper
        superStepper.backgroundColor = .white
        superStepper.layer.cornerRadius = 12
        
        // Configure start button
        startButton.setTitle("Start Workout", for: .normal)
        startButton.backgroundColor = .black
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = AKFont.round(.bold, 18)
        startButton.layer.cornerRadius = 12
        startButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        
        // Configure back button
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(superStepper)
        view.addSubview(startButton)
        view.addSubview(backButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        superStepper.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(superStepper.frame.size)
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(superStepper.snp.bottom).offset(80)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(48)
        }
    }
    
    // MARK: - Action Methods
    @objc private func startWorkout() {
        // Get the selected set count from the stepper
        guard let setCountText = superStepper.getCurrentValue() else {
            print("Error: Could not get set count from stepper")
            return
        }
        
        // Parse the set count (assuming format like "3 sets")
        let components = setCountText.components(separatedBy: " ")
        guard let setCountString = components.first, let setCount = Int(setCountString) else {
            print("Error: Could not parse set count from \(setCountText)")
            return
        }
        
        // Execute the completion handler with the selected set count
//        navigationController?.popViewController(animated: false)
        completionHandler(setCount)
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
