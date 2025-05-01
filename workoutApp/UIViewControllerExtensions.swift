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
    func addExitButtonToNavBar(withAction selector: Selector? = nil) {
        // Right navBar button
        let topinset = 12.0
        let menuBtn = UIButton(type: .custom)
        menuBtn.contentVerticalAlignment = .center
        menuBtn.contentHorizontalAlignment = .center
        menuBtn.imageView?.contentMode = .scaleAspectFit
        
        // Option 1: Use template mode and set tint on the button
        let xImage = UIImage.xmarkIcon.withRenderingMode(.alwaysTemplate)
        menuBtn.setImage(xImage, for: .normal)
        menuBtn.tintColor = .akDark  // This will tint the template image
        
        // OR Option 2: Pre-tint the image (but don't use template mode)
        // let xImage = UIImage.xmarkIcon.withTintColor(.red)
        // menuBtn.setImage(xImage, for: .normal)
        
        menuBtn.contentEdgeInsets = UIEdgeInsets(top: topinset, left: 0, bottom: topinset, right: 16)
        
        // Use the provided selector if available, otherwise fall back to the default
        let actionSelector = selector ?? #selector(xButtonHandler)
        menuBtn.addTarget(self, action: actionSelector, for: UIControl.Event.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
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
