//
//  SummaryScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT


final class SummaryScreen: UIViewController {
    
    // MARK: - Properties
    
    let header = SummaryHeader()
    let animationView = SummaryAnimationView()
    let summarySection = SummarySectionView()
    let dismissButton = BigButton()
    
    // MARK: - Initializers
    
    init(workout: WorkoutLog?) {
        super.init(nibName: nil, bundle: nil)
        
        addSubviewsAndConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .akLight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Methods
    
    func show() {
        UIApplication.shared.delegate?.window??.rootViewController?.present(self, animated: false)
    }
    
    private func setup() {
        modalPresentationStyle = .fullScreen
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissMe))
        dismissButton.addGestureRecognizer(dismissTap)
    }
    
    @objc private func dismissMe() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: false)
        }
    }
    
    private func addSubviewsAndConstraints() {
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.top.equalTo(header).offset(32)
            make.width.equalTo(screenWidth)
            make.height.equalTo(280)
        }
        
        view.addSubview(summarySection.view)
        summarySection.view.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(summarySection.view.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(32)
        }
    }
    
}
