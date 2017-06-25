//
//  newWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class NewWorkoutController: UIViewController, isStringReceiver {
    
    var receiveHandler: ((String) -> Void) = { _ in }

    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 150
    var typeSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var restSelectionBox: Box!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide tab bar's selection indicator
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.hideSelectionIndicator()
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .light
        
        // Remove tab and navigationcontrollers
        
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        
        let header = TwoLabelStack(frame: CGRect(x: 0, y: 100,
                                                 width: Constant.UI.width,
                                                 height: 70),
                                   topText: "Name",
                                   topFont: UIFont.custom(style: .bold, ofSize: .medium),
                                   topColor: UIColor.medium,
                                   bottomText: "My New Long named Workout",
                                   bottomFont: UIFont.custom(style: .bold, ofSize: .big),
                                   bottomColor: UIColor.darkest,
                                   fadedBottomLabel: false)
        
        // Type and Muscle selectors
        
        typeSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Type",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.exerciseType,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        typeSelecter.button.addTarget(self, action: #selector(typeSelectorHandler), for: .touchUpInside)
        
        muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Muscle",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.muscle,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleSelectorHandler), for: .touchUpInside)
        
        // MARK: - Boxes
        
        let boxFactory = BoxFactory.makeFactory(type: .SelectionBox)
        
        // Weight selection box
        
        let weightHeader = boxFactory.makeBoxHeader()
        let weightSubHeader = boxFactory.makeBoxSubHeader()
        let weightFrame = boxFactory.makeBoxFrame()
        let weightContent = boxFactory.makeBoxContent()
        
        let weightSelectionBox = Box(header: weightHeader, subheader: weightSubHeader, bgFrame: weightFrame!, content: weightContent!)
        weightSelectionBox.frame.origin = CGPoint(x: 0, y: typeSelecter.frame.maxY)
        weightSelectionBox.setTitle("Weight in kg")
        weightSelectionBox.setContentLabel("40.1")
//        weightSelectionBox.setDebugColors()
        
        // Rest selection box
        
        let restHeader = boxFactory.makeBoxHeader()
        let restSubHeader = boxFactory.makeBoxSubHeader()
        let restFrame = boxFactory.makeBoxFrame()
        let restContent = boxFactory.makeBoxContent()
        
        restSelectionBox = Box(header: restHeader, subheader: restSubHeader, bgFrame: restFrame!, content: restContent!)
        restSelectionBox.frame.origin = CGPoint(x: halfScreenWidth, y: weightSelectionBox.frame.origin.y)
        restSelectionBox.setTitle("Rest")
        restSelectionBox.setContentLabel("3:00")
        
        restSelectionBox.button.addTarget(self, action: #selector(restBoxTapHandler), for: .touchUpInside)
        
        
//        restSelectionBox.setDebugColors()
        
        // Workout selection box
        
        let workoutSelectionBox = TwoLabelStack(frame: CGRect(x: 0,
                                                              y: restSelectionBox.frame.maxY + 20,
                                                              width: Constant.UI.width,
                                                              height: 100),
                                   topText: "Bodyweight Exercises Added",
                                   topFont: UIFont.custom(style: .bold, ofSize: .medium),
                                   topColor: UIColor.faded,
                                   bottomText: "0",
                                   bottomFont: UIFont.custom(style: .bold, ofSize: .big),
                                   bottomColor: UIColor.dark,
                                   fadedBottomLabel: false)
        
        let buttonFooter = ButtonFooter(withColor: .darkest)
        buttonFooter.frame.origin.y = view.frame.maxY - buttonFooter.frame.height
        buttonFooter.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(header)
        view.addSubview(typeSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(weightSelectionBox)
        view.addSubview(restSelectionBox)
        view.addSubview(workoutSelectionBox)
        view.addSubview(buttonFooter)
        
//        header.setDebugColors()
//        typeSelecter.setDebugColors()
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: false)
    }
    
    func typeSelectorHandler() {
        let currentlySelectedType = typeSelecter.bottomLabel.text
        let typePicker = PickerViewController(withChoices: fewWorkoutStyles, withPreselection: currentlySelectedType)
        typePicker.delegate = self
        
        receiveHandler = { s in
            self.typeSelecter.bottomLabel.text = s
        }
        
        navigationController?.pushViewController(typePicker, animated: false)
    }
    
    func muscleSelectorHandler() {
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        let musclePicker = PickerViewController(withChoices: manyWorkoutStyles, withPreselection: currentlySelectedMuscle)
        musclePicker.delegate = self
        
        receiveHandler = {
            s in
            self.muscleSelecter.bottomLabel.text = s
        }
        
        navigationController?.pushViewController(musclePicker, animated: false)
    }
    
    func restBoxTapHandler() {
        let currentlySelectedRestTime = restSelectionBox.content.label?.text
        let restInputViewController  = InputViewController(inputStyle: .time)
        restInputViewController.delegate = self
        
        receiveHandler = {
            s in
            self.restSelectionBox.content.label?.text = s
        }
        
        navigationController?.pushViewController(restInputViewController, animated: true)
    }
}
