//
//  ViewController.swift
//
//  Created by Alexander Kvamme on 09/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: - Enum

enum CustomInputStyle {
    case weight
    case time
    case text
    case reps
}

// MARK: - InputViewController

class InputViewController: UIViewController, KeyboardDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var textField: UITextField!
    var customTextfieldContainer: InputView!
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    weak var delegate: isStringReceiver? // Will receive string from the InputViewController
    
    // MARK: - Initializers
    
    init(inputStyle: CustomInputStyle) {
        super.init(nibName: nil, bundle: nil)
        prepareForInput(with: inputStyle)
        view.backgroundColor = .light
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func prepareForInput(with inputStyle: CustomInputStyle) {
        switch inputStyle {
        case CustomInputStyle.text:
            // Standard keyboard for inputting text, such as workout names
            customTextfieldContainer = InputView(inputStyle: inputStyle)
            customTextfieldContainer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: Constant.UI.height - screenWidth) // set to match keyboard which is 1:1 with length screenWidth
            view.addSubview(customTextfieldContainer)
            textField = customTextfieldContainer.textField
            textField.delegate = self
        default:
            // Custom keyboard for inputting time and weight
            globalKeyboard.setKeyboardType(style: inputStyle)
            globalKeyboard.delegate = self
            
            customTextfieldContainer = InputView(inputStyle: inputStyle)
            customTextfieldContainer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: Constant.UI.height - screenWidth) // set to match keyboard which is 1:1 with length screenWidth
            view.addSubview(customTextfieldContainer)
            textField = customTextfieldContainer.textField
            textField.inputView = globalKeyboard
        }
    }
    
    // MARK: Keyboard methods

    public func buttonDidTap(keyName: String) {
        switch keyName{
            case "OK":
            textField.resignFirstResponder()
            textFieldDidEndEditing(textField)
        case "B": // Back button
            textField.deleteBackward()
            return
        default:
            textField.insertText(keyName.uppercased())
        }
    }
    
    // MARK: Observers
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let size = CGSize(width: screenWidth, height: screenHeight - keyboardHeight)
        if let topInputView = customTextfieldContainer {
            topInputView.frame.size = size
        }
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 0 {
            sendStringBack(text)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: API
    
    func setHeader(_ str: String) {
        customTextfieldContainer.setHeaderText(str)
    }
}

// MARK: - Extensions

/// isStringSender Conformance
extension InputViewController: isStringSender {
    func sendStringBack(_ string: String) {
        delegate?.receiveString(string)
    }
}

extension Selector {
    static let keyboardWillShow = #selector(InputViewController.keyboardWillShow(notification:))
}

