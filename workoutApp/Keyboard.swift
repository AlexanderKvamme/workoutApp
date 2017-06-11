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
        delegate?.buttonDidTap(keyName: (sender.titleLabel?.text)!)
    }
}
