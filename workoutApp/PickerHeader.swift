//
//  PickerHeader.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 27/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

//      let labelStack = TwoLabelStack(frame: .zero, topText: "SELECT", topFont: .custom(style: .bold, ofSize: .big), topColor: .secondary, bottomText: "", bottomFont: .custom(style: .medium, ofSize: .small), bottomColor: .black, fadedBottomLabel: false)

//
//  HeaderLabelStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class PickerHeader: TwoLabelStack {
    
    init(text: String) {
        
        let defaultFrame = CGRect(x: 0, y: 0, width: Constant.UI.width, height: 100)
        
        super.init(frame: defaultFrame,
                   topText: text,
                   topFont: UIFont.custom(style: .bold, ofSize: .big),
                   topColor: UIColor.secondary,
                   bottomText: "",
                   bottomFont: UIFont.custom(style: .medium, ofSize: .small),
                   bottomColor: UIColor.black,
                   fadedBottomLabel: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

