//
//  InputView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

enum CustomInputStyle {
    case weight
    case time
    case text
}

class InputView: UIViewController {
    
    var header: UILabel!
    
    init(header: String, initialValue: String, inputStyle: CustomInputStyle) {
        super.init(nibName: nil, bundle: nil)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
    
        view.backgroundColor = .light
    }
}
