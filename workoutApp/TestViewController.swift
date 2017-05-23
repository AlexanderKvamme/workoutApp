//
//  ViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 11/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    /* Use this testviewcontroller to test the abstract factory */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.light
        
        // Produce boxes from the factory
        
        let historyBoxFactory = BoxFactory.makeFactory(type: .HistoryBox)
        
        if let header = historyBoxFactory.makeBoxHeader(),
            let subheader = historyBoxFactory.makeBoxSubHeader(),
            let bgFrame = historyBoxFactory.makeBoxFrame(),
            let boxContent = historyBoxFactory.makeBoxContent() {
            
            let box = Box(header: header, subheader: subheader, bgFrame: bgFrame, content: boxContent)
            box.setTitle("Biceps")
            box.setSubHeader("Drop Set")
            
            box.center.y = box.center.y + 100
            view.addSubview(box)
            
            boxContent.contentStack.highlightBottomRow()
        }
    }
}

