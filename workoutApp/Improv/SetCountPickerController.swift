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
    private let closeButton = UIButton.make(.x)
    
    // Flag to determine presentation style
    private let isModal: Bool
    
    // Completion handler to execute when a set count is selected
    private let completionHandler: (Int) -> Void
    
    // MARK: - Initializers
    init(skill: Skill, initialSelection: String = "1", isModal: Bool = false, completionHandler: @escaping (Int) -> Void) {
        self.skill = skill
        self.isModal = isModal
        self.completionHandler = completionHandler
        self.superStepper = SuperStepper(frame: stepperFrame, options: setOptions, initialSelection: initialSelection)
        superStepper.activeColor = .black
        
        super.init(nibName: nil, bundle: nil)
        
        // Configure for modal presentation if needed
        if isModal {
            modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.prefersGrabberVisible = true
                }
            }
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.hideIt()
        
        if !isModal {
            styleBackButton()
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        globalTabBar.showIt()
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
        startButton.setTitle("🏁", for: .normal)
        startButton.backgroundColor = .black
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = AKFont.round(.bold, 18)
        startButton.layer.cornerRadius = 12
        startButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        
        // Configure back button (for navigation)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.isHidden = isModal
        
        // Configure close button (for modal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        closeButton.isHidden = !isModal
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(superStepper)
        view.addSubview(startButton)
        view.addSubview(backButton)
        view.addSubview(closeButton)
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
            make.bottom.equalTo(startButton.snp.top).offset(-24)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(64)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        // Back button for navigation
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(48)
        }
        
        // Close button for modal
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.size.equalTo(32)
        }
    }
    
    // MARK: - Action Methods
    @objc private func startWorkout() {
        // Get the selected set count from the stepper
        guard let setCountText = superStepper.getCurrentValue() else {
            print("Error: Could not get set count from stepper")
            return
        }
        
        // Parse the set count
        guard let setCount = Int(setCountText) else {
            print("Error: Could not parse set count from \(setCountText)")
            return
        }
        
        // Dismiss based on presentation style
        if isModal {
            print("dismising")
            dismiss(animated: true) {
                self.completionHandler(setCount)
            }
        } else {
            print("popping")
            navigationController?.popViewController(animated: true)
            completionHandler(setCount)
        }
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
}
