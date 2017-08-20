//
//  newWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class NewWorkoutController: UIViewController, isStringReceiver, isExerciseNameReceiver {
    
    var receiveHandler: ((String) -> Void) = { _ in } // Required method to handle the receiving of a final selection of muscle/type/weight/time pickers

    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 150
    var header: TwoLabelStack!
    var workoutStyleSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var restSelectionBox: Box!
    var weightSelectionBox: Box!
    var exerciseSelecter: TwoLabelStack!
    var nameOfCurrentlySelectedExercises = [String]()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide tab bar's selection indicator
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.hideSelectionIndicator()
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
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
                                   topText: "Name of new workout",
                                   topFont: UIFont.custom(style: .bold, ofSize: .medium),
                                   topColor: UIColor.medium,
                                   bottomText: "Your workout",
                                   bottomFont: UIFont.custom(style: .bold, ofSize: .big),
                                   bottomColor: UIColor.darkest,
                                   fadedBottomLabel: false)
        header.button.addTarget(self, action: #selector(headerTapHandler), for: .touchUpInside)
        header.bottomLabel.adjustsFontSizeToFitWidth = true
        
        // Type and Muscle selectors
        
        workoutStyleSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Type",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.exerciseType,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        workoutStyleSelecter.button.addTarget(self, action: #selector(typeTapHandler), for: .touchUpInside)
        
        muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                         topText: "Muscle",
                                         topFont: darkHeaderFont,
                                         topColor: .dark,
                                         bottomText: Constant.defaultValues.muscle,
                                         bottomFont: darkSubHeaderFont,
                                         bottomColor: UIColor.dark,
                                         fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        
        // Make rest Box
        
        let boxFactory = BoxFactory.makeFactory(type: .SelectionBox)
        let restHeader = boxFactory.makeBoxHeader()
        let restSubHeader = boxFactory.makeBoxSubHeader()
        let restFrame = boxFactory.makeBoxFrame()
        let restContent = boxFactory.makeBoxContent()
        
        restSelectionBox = Box(header: restHeader, subheader: restSubHeader, bgFrame: restFrame!, content: restContent!)
        restSelectionBox.frame.origin = CGPoint(x: halfScreenWidth - restSelectionBox.frame.width/2, y: workoutStyleSelecter.frame.maxY)
        restSelectionBox.setTitle("Rest")
        restSelectionBox.setContentLabel("3:00")
        
        restSelectionBox.button.addTarget(self, action: #selector(restTapHandler), for: .touchUpInside)
        
        //restSelectionBox.setDebugColors()
        
        // Workout selection box
        
        exerciseSelecter = TwoLabelStack(frame: CGRect(x: 0,
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
        exerciseSelecter.button.addTarget(self, action: #selector(exercisesTapHandler), for: .touchUpInside)
        
        // Footer 
        
        let buttonFooter = ButtonFooter(withColor: .darkest)
        buttonFooter.frame.origin.y = view.frame.maxY - buttonFooter.frame.height
        buttonFooter.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        buttonFooter.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
        
        view.addSubview(header)
        view.addSubview(workoutStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(restSelectionBox)
        view.addSubview(exerciseSelecter)
        view.addSubview(buttonFooter)
    }
    
    @objc private func approveAndDismissVC() {
        
        // Present error modal if workout contains no exercises
        guard nameOfCurrentlySelectedExercises.count > 0 else {
            let errorMessage = "Add at least one exercise, please!"
            let modal = CustomAlertView(type: .message, messageContent: errorMessage)
            modal.show(animated: true)
            return
         }
        
        if let workoutName = header.bottomLabel.text,
           let workoutStyleName = workoutStyleSelecter.bottomLabel.text,
           let muscleName = muscleSelecter.bottomLabel.text {
            DatabaseFacade.makeWorkout(withName: workoutName, workoutStyleName: workoutStyleName, muscleName: muscleName, exerciseNames: nameOfCurrentlySelectedExercises)
            DatabaseFacade.saveContext()
        } else {
            print("could not make workout")
        }
        navigationController?.popViewController(animated: true)
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tap handlers
    
    @objc private func headerTapHandler() {
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.setHeader("NAME OF YOUR WORKOUT?")
        workoutNamePicker.delegate = self
        
        receiveHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func typeTapHandler() {
        // Make and present a custom pickerView for selecting type
        let currentlySelectedType = workoutStyleSelecter.bottomLabel.text
        let workoutStyles = DatabaseFacade.fetchManagedObjectsForEntity(.WorkoutStyle) as! [WorkoutStyle]
        var workoutStyleNames = [String]()
        
        for ws in workoutStyles {
            if let name = ws.name {
                workoutStyleNames.append(name)
            }
        }
        
        let typePicker = PickerViewController(withChoices: workoutStyleNames, withPreselection: currentlySelectedType)
        typePicker.delegate = self
        
        // When receivng a selection of workout type
        receiveHandler = { s in
            self.workoutStyleSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(typePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        var muscleNames = [String]()
        // Fetch unique muscles
//        let musclesFromCoreData = Database.fetchManagedObjectsForEntity(.Muscle) as! [Muscle]
         let musclesFromCoreData = DatabaseFacade.fetchMuscles()
        
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
            self.exerciseSelecter.topLabel.text = "\(s) Exercises Added".uppercased()
            self.updateSelectableExercises()
        }
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
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
        
        nameOfCurrentlySelectedExercises = [String]()
        exerciseSelecter.bottomLabel.text = "0"
    }
    
    @objc private func exercisesTapHandler() {
        // Checks which muscle is selected, and then makes a pickerview to let user select exercises of that muscle group.
        let exercisePicker: ExercisePickerViewController!
        
        // Use selected muscle to prepare a pickerview and update UI
        guard let muscleName = muscleSelecter.bottomLabel.text else {
            return
        }
        
        let muscle = DatabaseFacade.getMuscle(named: muscleName)! // Only existing muscles are displayed so force unwrap
        exercisePicker = ExercisePickerViewController(forMuscle: muscle,
                                                          withMultiplePreselections: nameOfCurrentlySelectedExercises)
        exercisePicker.setHeaderTitle("\(muscleName) EXERCISES")
        exercisePicker.delegate = self
        exercisePicker.exerciseDelegate = self
        
        receiveHandler = { input in
            self.exerciseSelecter.bottomLabel.text = input
        }
        navigationController?.pushViewController(exercisePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    // MARK: - Delegate methods
    
    func receiveExerciseNames(_ exerciseNames: [String]) {
        nameOfCurrentlySelectedExercises = exerciseNames
    }
}

