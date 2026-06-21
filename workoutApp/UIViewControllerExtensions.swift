//
//  UIViewControllerExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//
import UIKit
import AKKIT


extension UIViewController {
    func addExitButtonToNavBar(withAction selector: Selector? = nil, usePlainIcon: Bool = false) {
        // Right navBar button
        let menuView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.backgroundColor = .clear
        menuView.layer.backgroundColor = UIColor.clear.cgColor
        menuView.isOpaque = false
        menuView.isUserInteractionEnabled = true
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .akDark
        imageView.image = (usePlainIcon ? UIImage(systemName: "xmark")! : UIImage.closeFat).withRenderingMode(.alwaysTemplate)
        imageView.isUserInteractionEnabled = false
        menuView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            menuView.widthAnchor.constraint(equalToConstant: 44),
            menuView.heightAnchor.constraint(equalToConstant: 44),
            
            imageView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: menuView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 17),
            imageView.heightAnchor.constraint(equalToConstant: 17)
        ])
        
        // Use a plain UIView + tap recognizer to avoid UIButton/UIBarButtonItem
        // native glass/background styling.
        let actionSelector = selector ?? #selector(xButtonHandler)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: actionSelector)
        menuView.addGestureRecognizer(tapRecognizer)
        
        let menuBarItem = UIBarButtonItem(customView: menuView)
        // No need to set tintColor on the bar button item if you've set it on the button
        self.navigationItem.rightBarButtonItem = menuBarItem
        self.navigationItem.hidesBackButton = true
    }
    
    // Default implementation of xButtonHandler
    @objc func xButtonHandler() {
        // Default behavior - dismiss or pop
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
