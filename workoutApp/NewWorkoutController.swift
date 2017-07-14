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
        
        // Setup of buttons: Header, muscle, type, exercises
        
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
        typeSelecter.button.addTarget(self, action: #selector(typeSelecterDidTap), for: .touchUpInside)
        
        muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Muscle",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.muscle,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        
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
        
        restSelectionBox.button.addTarget(self, action: #selector(restButtonDidTap), for: .touchUpInside)
        
        // restSelectionBox.setDebugColors()
        
        // Workout selection box
        
        workoutSelectionBox = TwoLabelStack(frame: CGRect(x: 0,
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
        workoutSelectionBox.button.addTarget(self, action: #selector(exercisesTapHandler), for: .touchUpInside)
        
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
        
        // header.setDebugColors()
        // typeSelecter.setDebugColors()
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tap handlers
    
    func headerDidTap() {
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.delegate = self
        
        receiveHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: false)
    }
    
    func typeSelecterDidTap() {
        let currentlySelectedType = typeSelecter.bottomLabel.text
        let workoutStyles = DatabaseController.fetchManagedObjectsForEntity(.WorkoutStyle) as! [WorkoutStyle]
        var workoutStyleNames = [String]()
        
        for w in workoutStyles {
            if let name = w.name {
                workoutStyleNames.append(name)
            }
        }
        
        let typePicker = PickerViewController(withChoices: workoutStyleNames, withPreselection: currentlySelectedType)
        typePicker.delegate = self
        
        // When receivng a selection of workout type
        receiveHandler = { s in
            self.typeSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(typePicker, animated: false)
    }
    
    func muscleTapHandler() {
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        var muscleNames = [String]()
        let musclesFromCoredate = DatabaseController.fetchManagedObjectsForEntity(.Muscle) as! [Muscle]
        for m in musclesFromCoredate {
            if let name = m.name {
                muscleNames.append(name.uppercased() )
            }
        }
        
        let musclePicker = PickerViewController(withChoices: muscleNames, withPreselection: currentlySelectedMuscle)
        musclePicker.delegate = self
        
        // When receivng a selection of workout musclegroup
        receiveHandler = {
            s in
            self.muscleSelecter.bottomLabel.text = s
            self.workoutSelectionBox.topLabel.text = "\(s) Exercises Added".uppercased()
            self.updateExerciseSelecters()
        }
        navigationController?.pushViewController(musclePicker, animated: false)
    }
    
    func weightButtonDidTap() {
        let weightInputViewController = InputViewController(inputStyle: .weight)
        weightInputViewController.delegate = self
        
        receiveHandler = { s in
            if s != "" {
                self.weightSelectionBox.content?.label?.text = s
            }
        }
        navigationController?.pushViewController(weightInputViewController, animated: false)
    }
    
    func restButtonDidTap() {
        let restInputViewController  = InputViewController(inputStyle: .time)
        restInputViewController.delegate = self
        
        receiveHandler = { s in
            if s != "" {
                self.restSelectionBox.content?.label?.text = s
            }
        }
        navigationController?.pushViewController(restInputViewController, animated: false)
    }
    
    // Update/reset exercise picker whenever user changes workout type/musclegroup
    
    private func updateExerciseSelecters() {
        
        print("*UPDATE EXERCISESELECTER*")
        
        // FIXME: - update exercises to match newly selected "MUSCLE"
        
        // guard muscle is actually changed
        
        // Get muscle
        
        var newlySelectedMuscle: Muscle? = nil
        
        if let muscleName = muscleSelecter.bottomLabel.text {
            newlySelectedMuscle = DatabaseFacade.fetchMuscleWithName(muscleName)
        }
        
        // fetch exercising using requested muscle as predicate
        
        var exercisesUsingSelectedMuscle: [Exercise]? = nil
        
        if let newlySelectedMuscle = newlySelectedMuscle {
            exercisesUsingSelectedMuscle = DatabaseFacade.fetchExercises(usingMuscle: newlySelectedMuscle)
            print("updateExerciseSelecters received fetched exercises: ")
            if let exercisesUsingSelectedMuscle = exercisesUsingSelectedMuscle {
                for e in exercisesUsingSelectedMuscle {
                    print(e.musclesUsed?.name)
                }
            }
        }
        
        print("Now left with exercisesUsingSelectedMuscle: \(exercisesUsingSelectedMuscle)")
        
        currentExerciseSelectionOptions = exercisesUsingSelectedMuscle // Stores exercises

        // TODO: - Use the fetched exercises to update the bottom label and let user select from these exercises
        
        // ...
        
        // save exercises and reset currentlySelected
        
//        DatabaseFacade.fetchExercises(usingMuscle: )
     print("*DONE UPDATING EXERCISESELECTER*")   
    }
    
    @objc private func exercisesTapHandler() {
        
        var currentExerciseNames = [String]()
        
        guard let currentExerciseSelectionOptions = currentExerciseSelectionOptions else { return }
        for e in currentExerciseSelectionOptions {
            if let name = e.name {
                currentExerciseNames.append(name)
            }
        }
        
        print("BAM ended up with names to send in ", currentExerciseNames)
        
        //let workoutPickerViewController = WorkoutPickerViewController(choices: ["Extreme Flipovers", "Backstacked Tripleflips", "Underground Leg Flexers"],withMultiplePreselections: nameOfCurrentlySelectedExercises)
        let workoutPickerViewController = WorkoutPickerViewController(choices: currentExerciseNames,
                                                                      withMultiplePreselections: nameOfCurrentlySelectedExercises)
        
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
        nameOfCurrentlySelectedExercises = workouts
    }
}
