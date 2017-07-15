//
//  NewExerciseController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 14/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

//
//  newWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class NewExerciseController: UIViewController, isStringReceiver, isExerciseNameReceiver {
    
    var receiveHandler: ((String) -> Void) = { _ in } // Required method to handle the receiving of a final selection of muscle/type/weight/time pickers
    
    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 150
    var header: TwoLabelStack!
    var typeSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var restSelectionBox: Box!
    var weightSelectionBox: Box!
    var exerciseSelectionBox: TwoLabelStack!
    var nameOfCurrentlySelectedExercises = [String]()
    var currentExerciseSelectionOptions: [Exercise]?
    
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
        
        // Setup of buttons: Header, muscle, type, rest, and exercises
        
        header = TwoLabelStack(frame: CGRect(x: 0, y: 100,
                                             width: Constant.UI.width,
                                             height: 70),
                               topText: "Name",
                               topFont: UIFont.custom(style: .bold, ofSize: .medium),
                               topColor: UIColor.medium,
                               bottomText: "Your exercise",
                               bottomFont: UIFont.custom(style: .bold, ofSize: .big),
                               bottomColor: UIColor.darkest,
                               fadedBottomLabel: false)
        header.button.addTarget(self, action: #selector(headerTapHandler), for: .touchUpInside)
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
        typeSelecter.button.addTarget(self, action: #selector(typeTapHandler), for: .touchUpInside)
        
        muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                       topText: "Muscle",
                                       topFont: darkHeaderFont,
                                       topColor: .dark,
                                       bottomText: Constant.defaultValues.muscle,
                                       bottomFont: darkSubHeaderFont,
                                       bottomColor: UIColor.dark,
                                       fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        
        // MARK: - Weight and Rest Boxes
        
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
        weightSelectionBox.button.addTarget(self, action: #selector(weightTapHandler), for: .touchUpInside)
        // weightSelectionBox.setDebugColors()
        
        // Rest selection box
        
        let restHeader = boxFactory.makeBoxHeader()
        let restSubHeader = boxFactory.makeBoxSubHeader()
        let restFrame = boxFactory.makeBoxFrame()
        let restContent = boxFactory.makeBoxContent()
        
        restSelectionBox = Box(header: restHeader, subheader: restSubHeader, bgFrame: restFrame!, content: restContent!)
        restSelectionBox.frame.origin = CGPoint(x: halfScreenWidth, y: weightSelectionBox.frame.origin.y)
        restSelectionBox.setTitle("Rest")
        restSelectionBox.setContentLabel("3:00")
        
        restSelectionBox.button.addTarget(self, action: #selector(restTapHandler), for: .touchUpInside)
        
        // restSelectionBox.setDebugColors()
        
        // Workout selection box
        
        exerciseSelectionBox = TwoLabelStack(frame: CGRect(x: 0,
                                                           y: restSelectionBox.frame.maxY + 20,
                                                           width: Constant.UI.width,
                                                           height: 100),
                                             topText: "\(Constant.defaultValues.muscle) Exercises Added",
            topFont: UIFont.custom(style: .bold, ofSize: .medium),
            topColor: UIColor.faded,
            bottomText: "0",
            bottomFont: UIFont.custom(style: .bold, ofSize: .big),
            bottomColor: UIColor.dark,
            fadedBottomLabel: false)
        exerciseSelectionBox.button.addTarget(self, action: #selector(exercisesTapHandler), for: .touchUpInside)
        
        let buttonFooter = ButtonFooter(withColor: .darkest)
        buttonFooter.frame.origin.y = view.frame.maxY - buttonFooter.frame.height
        buttonFooter.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(header)
        view.addSubview(typeSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(weightSelectionBox)
        view.addSubview(restSelectionBox)
        view.addSubview(exerciseSelectionBox)
        view.addSubview(buttonFooter)
        
        // header.setDebugColors()
        // typeSelecter.setDebugColors()
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tap handlers
    
    @objc private func headerTapHandler() {
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.delegate = self
        
        receiveHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: false)
    }
    
    @objc private func typeTapHandler() {
        // Make and present a custom pickerView for selecting type
        let currentlySelectedType = typeSelecter.bottomLabel.text
        let exerciseStyles = DatabaseController.fetchManagedObjectsForEntity(.ExerciseStyle) as! [ExerciseStyle]
        var exerciseNames = [String]()
        
        for ws in exerciseStyles {
            if let name = ws.name {
                exerciseNames.append(name)
            }
        }
        
        let typePicker = PickerViewController(withChoices: exerciseNames, withPreselection: currentlySelectedType)
        typePicker.delegate = self
        
        // When receivng a selection of workout type
        receiveHandler = { s in
            self.typeSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(typePicker, animated: false)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        var muscleNames = [String]()
        // Fetch unique muscles
        let musclesFromCoreData = DatabaseController.fetchManagedObjectsForEntity(.Muscle) as! [Muscle]
        
        for m in musclesFromCoreData {
            if let name = m.name {
                muscleNames.append(name.uppercased() )
            }
        }
        
        let musclePicker = PickerViewController(withChoices: muscleNames, withPreselection: currentlySelectedMuscle)
        musclePicker.delegate = self
        
        // When receiving a selection of workout musclegroup
        receiveHandler = {
            s in
            self.muscleSelecter.bottomLabel.text = s
            self.exerciseSelectionBox.topLabel.text = "\(s) Exercises Added".uppercased()
            self.updateSelectableExercises()
        }
        navigationController?.pushViewController(musclePicker, animated: false)
    }
    
    @objc private func weightTapHandler() {
        // Prepares and present a VC to input weight
        let weightInputViewController = InputViewController(inputStyle: .weight)
        weightInputViewController.delegate = self
        
        receiveHandler = { s in
            if s != "" {
                self.weightSelectionBox.content?.label?.text = s
            }
        }
        navigationController?.pushViewController(weightInputViewController, animated: false)
    }
    
    @objc private func restTapHandler() {
        // Prepares and present a VC to input weight
        let restInputViewController  = InputViewController(inputStyle: .time)
        restInputViewController.delegate = self
        
        receiveHandler = { s in
            if s != "" {
                self.restSelectionBox.content?.label?.text = s
            }
        }
        navigationController?.pushViewController(restInputViewController, animated: false)
    }
    
    // MARK: - Helper methods
    
    // Update/reset exercise picker whenever user changes workout type/musclegroup
    
    private func updateSelectableExercises() {
        // method is called after selecting a muscle, and makes sure the exercises that are selectable are exercises for the selected muscle.
        
        // Get muscle
        
        var newlySelectedMuscle: Muscle? = nil
        
        if let muscleName = muscleSelecter.bottomLabel.text {
            newlySelectedMuscle = DatabaseFacade.fetchMuscleWithName(muscleName)
        }
        
        // fetch exercises using the newly selected muscle as predicate
        
        var exercisesUsingSelectedMuscle: [Exercise]? = nil
        
        if let newlySelectedMuscle = newlySelectedMuscle {
            exercisesUsingSelectedMuscle = DatabaseFacade.fetchExercises(usingMuscle: newlySelectedMuscle)
        }
        
        // save exercises, exerciseCount, and reset currentlySelected
        currentExerciseSelectionOptions = exercisesUsingSelectedMuscle // Stores exercises in class
        nameOfCurrentlySelectedExercises = [String]()
        exerciseSelectionBox.bottomLabel.text = "0"
    }
    
    @objc private func exercisesTapHandler() {
        // Uses exercises fetched during updateSelectableExercises to create a custom picker
        
        var currentExerciseNames = [String]()
        
        guard let currentExerciseSelectionOptions = currentExerciseSelectionOptions else { return }
        for e in currentExerciseSelectionOptions {
            if let name = e.name {
                currentExerciseNames.append(name)
            }
        }
        
        let exercisePicker = ExercisePickerViewController(choices: currentExerciseNames,
                                                          withMultiplePreselections: nameOfCurrentlySelectedExercises)
        // Set header
        if let muscleName = muscleSelecter.bottomLabel.text {
            exercisePicker.setHeaderTitle("\(muscleName) EXERCISES")
        } else {
            exercisePicker.setHeaderTitle("SELECT EXERCISES")
        }
        
        exercisePicker.delegate = self
        exercisePicker.exerciseDelegate = self
        
        receiveHandler = { input in
            self.exerciseSelectionBox.bottomLabel.text = input
        }
        navigationController?.pushViewController(exercisePicker, animated: false)
    }
    
    // MARK: - Delegate methods
    
    func receiveExerciseNames(_ exerciseNames: [String]) {
        print("BAM workouts in NWC is received and set to : ", exerciseNames)
        nameOfCurrentlySelectedExercises = exerciseNames
    }
}

