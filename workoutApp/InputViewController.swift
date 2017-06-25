//
//  ViewController.swift
//  test
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
}

// MARK: - InputViewController

class InputViewController: UIViewController, KeyboardDelegate, UITextFieldDelegate, isStringSender {
    
    var kb: Keyboard!
    var tf: UITextField!
    var v: UIView!
    weak var delegate: isStringReceiver?
    
    init(inputStyle: CustomInputStyle) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light

        let screenWidth = UIScreen.main.bounds.width
     

        let kb = Keyboard(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        let v = InputView(inputStyle: .time)
        v.frame = CGRect(x: 0, y: 0, width: screenWidth, height: Constant.UI.height - screenWidth) // set to match keyboard which is 1:1 with length screenWidth
        
        view.addSubview(v)
        tf = v.textField
        
        tf.inputView = kb
        
        kb.delegate = self
    }
    
    // Keyboard delegate method

    func buttonDidTap(keyName: String) {
        switch keyName{
            case "OK":
            print("pressed ok")
            tf.resignFirstResponder()
            textFieldDidEndEditing(tf)
        case "B":
            print("pressed back")
            tf.deleteBackward()
            return
        default:
            tf.insertText(keyName)
        }
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("did end editing")
        if let text = textField.text {
            sendStringBack(text)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text: NSString = (textField.text ?? "") as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        return true
    }
    
    // MARK : - isStringSender protocol requirements
    
    func sendStringBack(_ string: String) {
        delegate?.receive(string)
    }
}

