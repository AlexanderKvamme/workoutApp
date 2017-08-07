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
        
        view.backgroundColor = .light
        
        setupSettingsButton()
        setupHeader()
        setupScrollView()
        setupStackView()
        
//        view.layoutIfNeeded()
//        stackView.frame = CGRect(x: 0, y: 0, width: 100, height: 3000)
        view.layoutIfNeeded()
        
        // End test
        print("END")
        for v in stackView.arrangedSubviews {
            print("end frame: ", v.frame)
        }
        print("stack frame: ", stackView.frame)
        print("scroll frame: ", scrollView.frame)
//        print("sc content frame: ", scrollView.)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        print("vdl")
        print("scrollview: ", scrollView.frame)
        print("stackView: ", stackView.frame)
        
        for v in stackView.arrangedSubviews { print(v) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupScrollView(){
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: 300, height: 900)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
        
        // Adding a testView
        
//        let testView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
//        testView.backgroundColor = .green
//        scrollView.addSubview(testView)
//        scrollView.contentSize = testView.frame.size
        
//        scrollView.addSubview(stackView)
    }
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = stackView.frame.size
    }
    
    private func setupStackView() {
        stackView = UIStackView(frame: CGRect.zero)
        stackView.backgroundColor = .dark
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        
        addWarnings(to: stackView)
        
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            ])
        
        scrollView.contentSize = CGSize(width: 200, height: 2000)
        stackView.clipsToBounds = true
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
        settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        settingsButton.backgroundColor = .darkest
        view.addSubview(settingsButton)
        
        let topRightInsets: CGFloat = 10
        let buttonDiameter: CGFloat = 30
        
        // Layout
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topRightInsets),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -topRightInsets),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonDiameter),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonDiameter),
            ])
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
        if let entirebox = input.superview?.superview {
            stackView.removeArrangedSubview(entirebox)
            entirebox.removeFromSuperview()
        }
    }
    
    func setDebugColors() {
        scrollView.backgroundColor = .yellow
    }
}

