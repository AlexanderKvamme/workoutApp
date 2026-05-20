//
//  ExerciseCountPickerController.swift
//  workoutApp
//
//  Created by Claude Code on 16/02/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import SnapKit

class ExerciseCountPickerController: UIViewController {

    // MARK: - Properties
    private let titleLabel = UILabel()
    private let stepperFrame = CGRect(x: 0, y: 0, width: 222, height: 64)
    private let exerciseOptions = Array(1...50).map { String($0) }
    private let superStepper: SuperStepper
    private let confirmButton = UIButton()
    private let closeButton = UIButton.make(.x)

    // Completion handler to execute when an exercise count is selected
    var onCountSelected: ((Int) -> Void)?

    // MARK: - Initializers
    init(initialSelection: String = "10") {
        self.superStepper = SuperStepper(frame: stepperFrame, options: exerciseOptions, initialSelection: initialSelection)
        superStepper.activeColor = .black

        super.init(nibName: nil, bundle: nil)

        // Configure for modal presentation
        modalPresentationStyle = .formSheet

        // For iOS 15+, use a smaller detent
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                // Use a smaller detent
                sheet.detents = [.custom { _ in return 280 }]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }

        // Set preferred content size for older iOS versions
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 280)
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        globalTabBar.showIt()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        // Configure title label
        titleLabel.text = "How many exercises?"
        titleLabel.font = AKFont.round(.black, 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        // Configure stepper
        superStepper.backgroundColor = .white
        superStepper.layer.cornerRadius = 12

        // Configure confirm button
        confirmButton.setTitle("Explore", for: .normal)
        confirmButton.backgroundColor = .black
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = AKFont.round(.bold, 18)
        confirmButton.layer.cornerRadius = 12
        confirmButton.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)

        // Configure close button
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)

        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(superStepper)
        view.addSubview(confirmButton)
        view.addSubview(closeButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(64)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.size.equalTo(24)
        }

        superStepper.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(superStepper.frame.size)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(superStepper.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
    }

    // MARK: - Action Methods
    @objc private func confirmSelection() {
        // Get the selected exercise count from the stepper
        guard let countText = superStepper.getCurrentValue() else {
            print("Error: Could not get count from stepper")
            return
        }

        // Parse the count
        guard let count = Int(countText) else {
            print("Error: Could not parse count from \(countText)")
            return
        }

        // Dismiss the modal and execute completion handler
        dismiss(animated: true) {
            self.onCountSelected?(count)
        }
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }
}
