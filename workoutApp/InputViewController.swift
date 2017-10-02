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
    case reps // Used in exercise
}

// MARK: - InputViewController

class InputViewController: UIViewController, KeyboardDelegate, UITextFieldDelegate, isStringSender {
    
    // MARK: - Properties
    
    var kb: Keyboard!
    var tf: UITextField!
    var customTextfieldContainer: InputView!
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    weak var delegate: isStringReceiver? // Delegate to receive string from the InputViewController
    
    // MARK: - Initializers
    
    init(inputStyle: CustomInputStyle) {
        super.init(nibName: nil, bundle: nil)
        // set
        switch inputStyle {
        case CustomInputStyle.text:
            // Standard keyboard for inputting text, such as workout names
            customTextfieldContainer = InputView(inputStyle: inputStyle)
            customTextfieldContainer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: Constant.UI.height - screenWidth) // set to match keyboard which is 1:1 with length screenWidth
            view.addSubview(customTextfieldContainer)
            tf = customTextfieldContainer.textField
            tf.delegate = self
            
        default:
            // Custom keyboard for inputting time and weight
            let kb = Keyboard(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
            kb.setKeyboardType(style: inputStyle)
            kb.delegate = self
            
            customTextfieldContainer = InputView(inputStyle: inputStyle)
            customTextfieldContainer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: Constant.UI.height - screenWidth) // set to match keyboard which is 1:1 with length screenWidth
            view.addSubview(customTextfieldContainer)
            tf = customTextfieldContainer.textField
            tf.inputView = kb
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
    }
    
    // MARK: - Methods
    
    // Keyboard methods

    public func buttonDidTap(keyName: String) {
        switch keyName{
            case "OK":
            tf.resignFirstResponder()
            textFieldDidEndEditing(tf)
        case "B": // Back button
            tf.deleteBackward()
            return
        default:
            tf.insertText(keyName.uppercased())
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
        
        if text.characters.count > 0 { sendStringBack(text) }
        
        navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // TODO: Use this method to verify input
        // let text: NSString = (textField.text ?? "") as NSString
        // let resultString = text.replacingCharacters(in: range, with: string)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tf.resignFirstResponder()
        return true
    }
    
    // MARK: isStringSender protocol requirements
    
    func sendStringBack(_ string: String) {
        delegate?.receiveString(string)
    }
    
    // MARK: API
    func setHeader(_ str: String) {
        customTextfieldContainer.setHeaderText(str)
    }
}

// MARK: - Extensions

extension Selector {
    static let keyboardWillShow = #selector(InputViewController.keyboardWillShow(notification:))
}

