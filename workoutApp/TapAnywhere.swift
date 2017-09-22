//
//  TapAnywhere.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Extension to enable dismissal of keyboard when tapping outside

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false // When this is used in a tableView og collectionView, this setting makes sure the tapRecognizer does not eat up the touch and stops the responderchain. Setting it to false makes sure didSelectRowAtIndexPath will still be called
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
