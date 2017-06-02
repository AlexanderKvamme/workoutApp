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
        
        // Produce a box from the factory
        
//        let historyBoxFactory = BoxFactory.makeFactory(type: .HistoryBox)
//        
//        if let header = historyBoxFactory.makeBoxHeader(),
//            let subheader = historyBoxFactory.makeBoxSubHeader(),
//            let bgFrame = historyBoxFactory.makeBoxFrame(),
//            let boxContent = historyBoxFactory.makeBoxContent() {
//            
//            let box = Box(header: header, subheader: subheader, bgFrame: bgFrame, content: boxContent)
//            box.setTitle("Biceps")
//            box.setSubHeader("Drop Set")
//            
//            box.center.y = box.center.y + 100
//            view.addSubview(box)
//            
//            boxContent.contentStack.highlightBottomRow()
//        }
        
        // Header
        
//        let headerStack = twoLabelStack(topText: "NAME",
//                                      topFont: UIFont.custom(style: .bold, ofSize: .medium),
//                                      topColor: UIColor.dark,
//                                      bottomText: "MY WORKOUT", // enable 2 lines
//                                      bottomFont: UIFont.custom(style: .bold, ofSize: .big),
//                                      bottomColor: UIColor.dark,
//                                      faded: false)
//        
//        headerStack.frame = CGRect(x: 0, y: 0, width: Constant.UI.width, height: 100)
//        view.addSubview(headerStack)
        
        // Type and Muscles stack
        
//        let typeAndMuscleStack = UIStackView()
//        
//        let typestack = twoLabelStack(topText: "TYPE".uppercased(),
//                                      topFont: UIFont.custom(style: .bold, ofSize: .medium),
//                                      topColor: UIColor.darkest,
//                                      bottomText: "BODYWEIGHT".uppercased(),
//                                      bottomFont: UIFont.custom(style: .medium, ofSize: .medium),
//                                      bottomColor: UIColor.darkest,
//                                      faded: true)
//        
//        let musclestack = twoLabelStack(topText: "MUSCLE".uppercased(),
//                                        topFont: UIFont.custom(style: .bold, ofSize: .medium),
//                                        topColor: UIColor.darkest,
//                                        bottomText: "LEGS".uppercased(),
//                                        bottomFont: UIFont.custom(style: .medium, ofSize: .medium),
//                                        bottomColor: UIColor.darkest,
//                                        faded: true)
//        
//        typestack.frame.size = CGSize(width: Constant.UI.width/2, height: 100)
//        musclestack.frame.size = CGSize(width: Constant.UI.width/2, height: 100)
//        
//        typeAndMuscleStack.axis = .horizontal
//        typeAndMuscleStack.distribution = .fillEqually
//        typeAndMuscleStack.alignment = .center
//        typeAndMuscleStack.spacing = 0
//        
//        typeAndMuscleStack.addArrangedSubview(typestack)
//        typeAndMuscleStack.addArrangedSubview(musclestack)
//        
//        typeAndMuscleStack.frame = CGRect(x: 0, y: 100, width: Constant.UI.width, height: 100)
//        view.addSubview(typeAndMuscleStack)
        
         // MARK: - Boxes
        
        let boxFactory = BoxFactory.makeFactory(type: .SelectionBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        // top box
        
        let box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent!)
        box.setTitle("Test")
        box.setSubHeader("Drop Set")
        view.addSubview(box)
        box.setDebugColors()
        
        // bot box factory
        
        let boxFactory2 = BoxFactory.makeFactory(type: .HistoryBox)
        let newboxHeader = boxFactory2.makeBoxHeader()
        let newboxSubHeader = boxFactory2.makeBoxSubHeader()
        let newboxFrame = boxFactory2.makeBoxFrame()
        let newboxContent = boxFactory2.makeBoxContent()
        
        // bot box
        
        let botBox = Box(header: newboxHeader, subheader: newboxSubHeader, bgFrame: newboxFrame!, content: newboxContent!)
        botBox.setTitle("this is a really long title right")
        botBox.setSubHeader("Drop Set")
        view.addSubview(botBox)
        botBox.center.y = botBox.center.y + 300
        
        botBox.translatesAutoresizingMaskIntoConstraints = false
        botBox.clipsToBounds = true
        setBotBoxConstraints()
    }
    
    private func setBotBoxConstraints() {
        NSLayoutConstraint.activate([
            
            ])
    }
}

