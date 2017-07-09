//
//  Keyboard.swift
//  test
//
//  Created by Alexander Kvamme on 09/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

protocol KeyboardDelegate: class {
    func buttonDidTap(keyName: String)
}

class Keyboard: UIView {
    
    weak var delegate: KeyboardDelegate?

    @IBOutlet weak var bottomLeftButton: UIButton! // Will change according to setting between : and .
    @IBOutlet weak var topRightButton: UIButton! // + button
    @IBOutlet weak var middleRightButton: UIButton! // - button
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeSubviews() {
        let xibFileName = "Keyboard" // xib extention not included
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard sender.titleLabel?.text != nil else { return }
        delegate?.buttonDidTap(keyName: (sender.titleLabel?.text)!)
    }
    
    func setKeyboardType(style: CustomInputStyle) {
        switch style {
        case .time:
            bottomLeftButton.setTitle(":", for: .normal)
        case .reps:
            bottomLeftButton.setTitle("", for: .normal)
            topRightButton.setTitle("", for: .normal)
            
            // FIXME: - make next button
            middleRightButton.setTitle("", for: .normal)
            if let backArrowImage = UIImage(named: "arrow-back") {
                let tintableImage = backArrowImage.withRenderingMode(.alwaysTemplate)
                let rotatedImage = UIImage(cgImage: tintableImage.cgImage!, scale: 0, orientation: .down)
                
                middleRightButton.setImage(rotatedImage, for: .normal)
                let inset: CGFloat = 22
                middleRightButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
                middleRightButton.image
                middleRightButton.tintColor = .light
            }
            middleRightButton.addTarget(self, action: #selector(postNextKeyDidPressNotification), for: .touchUpInside)
            
//            et xmark = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysTemplate)
//            cancelButton.setImage(xmark, for: .normal)
//            cancelButton.tintColor = color
            
            
            print("would set up Keyboard class for REPS")
        default:
            bottomLeftButton.setTitle(".", for: .normal)
        }
    }
    
    func postNextKeyDidPressNotification() {
        print("posting")
        //NotificationCenter.default.post(name: CustomNotificationNames.KeyboardNextButtonDidPress.rawValue, object: self)
        NotificationCenter.default.post(name: .keyboardsNextButtonDidPress, object: nil)
        print("posted")
    }
}


// MARK: - Extension to enable dismissal of keyboard when tapping outside

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false // When this is used in a tableView og collectionView, this setting makes sure the tapRecognizer does not eat up the touch and stops the responderchain. Setting it to false makes sure didSelectRowAtIndexPath will still be called
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


