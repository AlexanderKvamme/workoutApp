//
//  newWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class NewWorkoutController: UIViewController, isStringReceiver, isWorkoutReceiver {
    
    var receiveHandler: ((String) -> Void) = { _ in } // Required method to handle the receiving of a final selection of muscle/type/weight/time pickers

    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 150
    var header: TwoLabelStack!
    var typeSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var restSelectionBox: Box!
    var weightSelectionBox: Box!
    var workoutSelectionBox: TwoLabelStack!
    var nameOfSelectedWorkouts = [String]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: - ViewWillAppear
    
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
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .light
        
        // Remove tab and navigationcontrollers
        
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        
        // MARK: - setup of buttons: Header, muscle, type, exercises
        
        header = TwoLabelStack(frame: CGRect(x: 0, y: 100,
                                                 width: Constant.UI.width,
                                                 height: 70),
                                   topText: "Name",
                                   topFont: UIFont.custom(style: .bold, ofSize: .medium),
                                   topColor: UIColor.medium,
                                   bottomText: "Your workout",
                                   bottomFont: UIFont.custom(style: .bold, ofSize: .big),
                                   bottomColor: UIColor.darkest,
                                   fadedBottomLabel: false)
        header.button.addTarget(self, action: #selector(headerDidTap), for: .touchUpInside)
        header.bottomLabel.adjustsFontSizeToFitWidth = true
        
        // Type and Muscle selectors
        
        typeSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Type",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.exerciseType,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        typeSelecter.button.addTarget(self, action: #selector(typeDidTap), for: .touchUpInside)
        
        muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Muscle",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.muscle,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleDidTap), for: .touchUpInside)
        
        // MARK: - Weight and rest Boxes
        
        let boxFactory = BoxFactory.makeFactory(type: .SelectionBox)
        
        // Weight selection box
        
        let weightHeader = boxFactory.makeBoxHeader()
        let weightSubHeader = boxFactory.makeBoxSubHeader()
        let weightFrame = boxFactory.makeBoxFrame()
        let weightContent = boxFactory.makeBoxContent()
        
        weightSelectionBox = Box(header: weightHeader, subheader: weightSubHeader, bgFrame: weightFrame!, content: weightContent!)
        weightSelectionBox.frame.origin = CGPoint(x: 0, y: typeSelecter.frame.maxY)
        weightSelectionBox.setTitle("Weight in kg")
        weightSelectionBox.setContentLabel("40.1")
        weightSelectionBox.button.addTarget(self, action: #selector(weightButtonDidTap), for: .touchUpInside)
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
        
        restSelectionBox.button.addTarget(self, action: #selector(restButtonDidTap), for: .touchUpInside)
        
        
//        restSelectionBox.setDebugColors()
        
        // Workout selection box
        
        workoutSelectionBox = TwoLabelStack(frame: CGRect(x: 0,
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
        workoutSelectionBox.button.addTarget(self, action: #selector(workoutsTapHandler), for: .touchUpInside)
        
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
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tap handlers
    
    func headerDidTap() {
//        let currentWorkoutName = header.bottomLabel.text
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.delegate = self
        
        receiveHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: false)
    }
    
    func typeDidTap() {
        let currentlySelectedType = typeSelecter.bottomLabel.text
        let typePicker = PickerViewController(withChoices: fewWorkoutStyles, withPreselection: currentlySelectedType)
        typePicker.delegate = self
        
        receiveHandler = { s in
            self.typeSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(typePicker, animated: false)
    }
    
    func muscleDidTap() {
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        let musclePicker = PickerViewController(withChoices: manyWorkoutStyles, withPreselection: currentlySelectedMuscle)
        musclePicker.delegate = self
        
        receiveHandler = {
            s in
            self.muscleSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(musclePicker, animated: false)
    }
    
    func weightButtonDidTap() {
        let weightInputViewController = InputViewController(inputStyle: .weight)
        weightInputViewController.delegate = self
        
        receiveHandler = { s in
            if s != "" {
                self.weightSelectionBox.content.label?.text = s
            }
        }
        navigationController?.pushViewController(weightInputViewController, animated: false)
    }
    
    func restButtonDidTap() {
        let restInputViewController  = InputViewController(inputStyle: .time)
        restInputViewController.delegate = self
        
        receiveHandler = { s in
            if s != "" {
                self.restSelectionBox.content.label?.text = s
            }
        }
        navigationController?.pushViewController(restInputViewController, animated: false)
    }
    
    func workoutsTapHandler() {
        let workoutPickerViewController = WorkoutPickerViewController(choices: ["Extreme Flipovers",
                                                                                "Backstacked Tripleflips",
                                                                                "Underground Leg Flexers"],
                                                                      withMultiplePreselections: nameOfSelectedWorkouts)
        print("sending inn this list: \(nameOfSelectedWorkouts)")
        workoutPickerViewController.delegate = self
        workoutPickerViewController.workoutDelegate = self
        receiveHandler = { s in
            self.workoutSelectionBox.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutPickerViewController, animated: false)
    }
    
    // MARK: - Delegate methods
    
    func receiveWorkout(_ workouts: [String]) {
        print("workouts in NWC is received and set to : ", workouts)
        nameOfSelectedWorkouts = workouts
    }
}
