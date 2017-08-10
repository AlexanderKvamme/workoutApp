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

        // test controller
        
//        let test = GoalsController(withGoals: ["One", "Two", "Three"])
//        view.addSubview(test.view)
        
        // test button
        
        let btn = GoalsButton(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        btn.backgroundColor = .green
        btn.addTarget(self, action: #selector(test), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    func test() {
        print("test")
    }
}

