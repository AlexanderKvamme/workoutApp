//
//  ProfileController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 03/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


final class ProfileController: UIViewController {
    
    // MARK: - Properties
    
    private var settingsButton = UIButton()
    private var messageButton = UIButton()
    private var stackView = UIStackView()
    private var scrollView = UIScrollView()
    private var header = UILabel()    
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = ""
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
        // TODO: Add preferences and show preferenceIcon
        // setupHeader()
        setupScrollView()
        setupStackView()

        addWarnings(to: stackView)
        addGoals(to: stackView)
        addSuggestions(to: stackView)
        
        setupSettingsButton()
        setupMessageButton()
    }
    
    private func setupScrollView(){
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isScrollEnabled = true
        
        scrollView.clipsToBounds = true
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
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
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        
        stackView.clipsToBounds = true
        
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
    
    private func setupMessageButton() {
        messageButton = UIButton(frame: CGRect.zero)
        messageButton.setImage(UIImage.messageIcon, for: .normal)
        messageButton.imageView?.contentMode = .scaleAspectFit
        messageButton.addTarget(self, action: #selector(mailDeveloper), for: .touchUpInside)
        
        view.addSubview(messageButton)
        
        // Layout
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            messageButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            messageButton.widthAnchor.constraint(equalToConstant: 25),
            messageButton.heightAnchor.constraint(equalToConstant: 25),
            ])
    }
    
    private func setupSettingsButton() {
        settingsButton = UIButton(frame: CGRect.zero)
        settingsButton.setImage(UIImage(named: "wrench"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonHandler), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        // Layout
        let buttonDiameter: CGFloat = 25
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonDiameter),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonDiameter),
            ])
        
        settingsButton.isHidden = true
    }
    
    private func addGoals(to stackView: UIStackView) {
        let goalsController = GoalsController()
        addChildViewController(goalsController)
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

extension ProfileController: MFMailComposeViewControllerDelegate {
    
    @objc func mailDeveloper() {
        guard MFMailComposeViewController.canSendMail() else {
            let modal = CustomAlertView(type: .error, messageContent: "Your device is not configured to send mail!")
            modal.show(animated: true)
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["alexanderkvamme@gmail.com"])
        mail.setSubject("Hone(est) feedback")
        mail.setMessageBody("<h3>So I got this great idea:</h3", isHTML: true)
        present(mail, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Present modal based on result
        switch result {
        case .cancelled:
            let modal = CustomAlertView(type: .message, messageContent: "Another time, then! :)")
            modal.show(animated: true)
        case .sent:
            let modal = CustomAlertView(type: .message, messageContent: "Great stuff! Thanks! :)")
            modal.show(animated: true)
        case .failed:
            let modal = CustomAlertView(type: .error, messageContent: "Ohh my! Something wrong happened with your email and it could not be sent: \(error?.localizedDescription ?? "Try again later")")
            modal.show(animated: true)
        case .saved:
            let modal = CustomAlertView(type: .message, messageContent: "Great idea! Save it for later!")
            modal.show(animated: true)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}

