//
//  SetCountPickerController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import SnapKit

class SetCountPickerController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private let pickerTitle: String
    private let titleLabel = UILabel()
    private let stepperFrame = CGRect(x: 0, y: 0, width: 222, height: 64)
    private let setOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private let superStepper: SuperStepper
    private let startButton = UIButton()
    private let closeButton = UIButton.make(.x)
    private let sheetView = UIView()
    private let grabberView = UIView()
    private let sheetInset: CGFloat = 20
    private let sheetHeight: CGFloat = 280
    private let deviceLikeCornerRadius: CGFloat = 44
    private var sheetBottomConstraint: Constraint?
    private var shouldRestoreTabBar = true
    
    // Completion handler to execute when a set count is selected
    private let completionHandler: (Int) -> Void
    
    // MARK: - Initializers
    init(title: String = "", initialSelection: String = "9", completionHandler: @escaping (Int) -> Void) {
        self.pickerTitle = title
        self.completionHandler = completionHandler
        self.superStepper = SuperStepper(frame: stepperFrame, options: setOptions, initialSelection: initialSelection)
        superStepper.activeColor = .black
        
        super.init(nibName: nil, bundle: nil)
        
        // Custom inset bottom sheet so we can match the device-like corner radius
        // while keeping a 20pt margin around the sheet.
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 280)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.hideIt()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldRestoreTabBar {
            globalTabBar.showIt()
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Configure sheet
        sheetView.backgroundColor = .akLight
        sheetView.layer.cornerRadius = deviceLikeCornerRadius
        sheetView.layer.cornerCurve = .continuous
        sheetView.layer.masksToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSheetPan(_:)))
        panGesture.delegate = self
        sheetView.addGestureRecognizer(panGesture)
        
        let backdropTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap(_:)))
        backdropTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(backdropTapGesture)
        
        // Configure grabber
        grabberView.backgroundColor = .systemGray3
        grabberView.alpha = 0.5
        grabberView.layer.cornerRadius = 2.5
        
        // Configure title label
        titleLabel.text = "How many sets?"
        titleLabel.font = AKFont.round(.black, 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        // Configure stepper
        superStepper.backgroundColor = .white
        superStepper.layer.cornerRadius = 12
        
        // Configure start button
        startButton.setTitle(nil, for: .normal)
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        startButton.setImage(UIImage(systemName: "play.fill", withConfiguration: symbolConfiguration), for: .normal)
        startButton.backgroundColor = .black
        startButton.tintColor = .white
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = AKFont.round(.bold, 18)
        startButton.layer.cornerRadius = 12
        startButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        
        // Configure close button
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(sheetView)
        sheetView.addSubview(grabberView)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(superStepper)
        sheetView.addSubview(startButton)
        sheetView.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        sheetView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sheetInset)
            sheetBottomConstraint = make.bottom.equalToSuperview().offset(-sheetInset).constraint
            make.height.equalTo(sheetHeight)
        }
        
        grabberView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(68)
            make.height.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }
        
        superStepper.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(superStepper.frame.size)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(superStepper.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Action Methods
    @objc private func startWorkout() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        shouldRestoreTabBar = false
        
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
        
        // Dismiss the modal and execute completion handler
        dismiss(animated: true) {
            self.completionHandler(setCount)
        }
    }
    
    @objc private func dismissModal() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss(animated: true)
    }
    
    @objc private func handleBackdropTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: view)
        guard !sheetView.frame.contains(tapLocation) else { return }
        dismiss(animated: true)
    }
    
    @objc private func handleSheetPan(_ gesture: UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: view).y
        let velocityY = gesture.velocity(in: view).y
        
        switch gesture.state {
        case .changed:
            // Follow downward drags. Upward drags get a tiny resistance so the
            // sheet still feels draggable without leaving its intended position.
            let offset = translationY > 0 ? translationY : translationY * 0.15
            sheetBottomConstraint?.update(offset: -sheetInset + offset)
            view.layoutIfNeeded()
        case .ended, .cancelled:
            if translationY > 90 || velocityY > 900 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
                    self.sheetBottomConstraint?.update(offset: -self.sheetInset)
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
