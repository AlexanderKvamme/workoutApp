//
//  ViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 11/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

//class TestViewController: UIViewController {
class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Test out a a suggestionbox
        let box = SuggestionBox()
        box.setSuggestionSubheader("LEGS")
        box.setSuggestionHeader("1 WEEK SINCE LAST WORKOUT")
        
        box.center = view.center
        view.addSubview(box)
        
        // MARK: Test long press recognizer
        
        let longPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
        box.addGestureRecognizer(longPressRecognizer)
    }
    
    func longPressRecognized( _ sender: UIGestureRecognizer) {
        print("lpr")
        
    }
}

