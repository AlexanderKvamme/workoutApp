//
//  newWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class NewWorkoutController: UIViewController, isStringReceiver, isExerciseReceiver {
    
    // MARK: - Properties

    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 150
    
    // Components
    var header: TwoLabelStack!
    var workoutStyleSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var restSelectionBox: Box!
    var buttonFooter: ButtonFooter!
    var weightSelectionBox: Box!
    var exerciseSelecter: TwoLabelStack!
    var currentlySelectedExercises = [Exercise]()
    
    // Delegate closures
    var receiveExercises: (([Exercise]) -> ()) = { _ in }
    var stringReceivedHandler: ((String) -> Void) = { _ in } //  used to receiving of muscle/type/weight/time from pickers
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        currentlySelectedExercises = [Exercise]()
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    // ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        // Hide tab bar's selection indicator
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.hideSelectionIndicator()
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    // ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .light
        
        setupHeader()
        setupTypeAndMuscleSelecter()
        setupRestBox()
        setupExerciseSelecter()
        setupFooter()
        
        view.addSubview(header)
        view.addSubview(workoutStyleSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(restSelectionBox)
        view.addSubview(exerciseSelecter)
        view.addSubview(buttonFooter)
    }
    
    @objc private func approveAndDismissVC() {
        
        // Present error modal if workout contains no exercises
        guard currentlySelectedExercises.count > 0 else {
            let errorMessage = "Add at least one exercise, please!"
            let modal = CustomAlertView(type: .message, messageContent: errorMessage)
            modal.show(animated: true)
            return
         }
        
        if let workoutName = header.bottomLabel.text,
           let workoutStyleName = workoutStyleSelecter.bottomLabel.text,
           let muscleName = muscleSelecter.bottomLabel.text {
//            DatabaseFacade.makeWorkout(withName: workoutName, workoutStyleName: workoutStyleName, muscleName: muscleName, exerciseNames: nameOfCurrentlySelectedExercises)
            DatabaseFacade.makeWorkout(withName: workoutName, workoutStyleName: workoutStyleName, muscleName: muscleName, exercises: currentlySelectedExercises)
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
        
        stringReceivedHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func typeTapHandler() {
        // Make and present a custom pickerView for selecting type
        let currentlySelectedWorkoutTypeName = workoutStyleSelecter.bottomLabel.text
        let workoutStyles = DatabaseFacade.fetchManagedObjectsForEntity(.WorkoutStyle) as! [WorkoutStyle]
        
        let typePicker = PickerViewController<WorkoutStyle>(withPicksFrom: workoutStyles,
                                              withPreselection: currentlySelectedWorkoutTypeName)
        
        typePicker.delegate = self
        
        // When receivng a selection of workout type
        stringReceivedHandler = { s in
            self.workoutStyleSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(typePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let existingMuscles = DatabaseFacade.fetchMuscles()
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        let musclePicker = PickerViewController<Muscle>(withPicksFrom: existingMuscles,
                                                withPreselection: currentlySelectedMuscle)
        musclePicker.delegate = self
        
        // When receiving a selection of workout musclegroup
        stringReceivedHandler = {
            s in
            self.muscleSelecter.bottomLabel.text = s
            self.exerciseSelecter.topLabel.text = "Exercises Added".uppercased()
        }
        
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func restTapHandler() {
        // Prepares and present a VC to input weight
        let restInputViewController  = InputViewController(inputStyle: .time)
        restInputViewController.delegate = self
        
        stringReceivedHandler = { s in
            if s != "" {
                self.restSelectionBox.content?.label?.text = s
            }
        }
        navigationController?.pushViewController(restInputViewController, animated: false)
    }
    
    // MARK: - Helper methods
    
    @objc private func exercisesTapHandler() {
        
        // Use selected muscle to prepare a pickerview and update UI
        guard let muscleName = muscleSelecter.bottomLabel.text else {
            return
        }
        
        let selectedMuscle = DatabaseFacade.getMuscle(named: muscleName)! // Only existing muscles are displayed so force unwrap
        let exercisePicker = ExercisePickerViewController(forMuscle: selectedMuscle,
                                                          withPreselectedExercises: currentlySelectedExercises)
        
        exercisePicker.setHeaderTitle("\(muscleName) EXERCISES")
        exercisePicker.delegate = self
        exercisePicker.exerciseDelegate = self
        
        // prepare to receive exercises back from picker
        receiveExercises = { exercises in
            self.currentlySelectedExercises = exercises
            self.exerciseSelecter.bottomLabel.text = String(exercises.count)
        }
        
        navigationController?.pushViewController(exercisePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    // MARK: Helper methods
    
    private func setupHeader() {
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
        header.bottomLabel.adjustsFontSizeToFitWidth = true
        header.button.addTarget(self, action: #selector(headerTapHandler), for: .touchUpInside)
    }
    
    private func setupTypeAndMuscleSelecter() {
        // Fonts
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        
        // Type selecter
        workoutStyleSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Type", topFont: darkHeaderFont, topColor: .dark, bottomText: Constant.defaultValues.exerciseType, bottomFont: darkSubHeaderFont, bottomColor: UIColor.dark, fadedBottomLabel: false)
        workoutStyleSelecter.button.addTarget(self, action: #selector(typeTapHandler), for: .touchUpInside)
        
        // Muscle selecter
        muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Muscle", topFont: darkHeaderFont, topColor: .dark, bottomText: Constant.defaultValues.muscle, bottomFont: darkSubHeaderFont, bottomColor: UIColor.dark, fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
    }
    
    private func setupRestBox() {
        // Make Rest Box
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
    }
    
    private func setupExerciseSelecter() {
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
    }
    
    private func setupFooter() {
        // Footer
        buttonFooter = ButtonFooter(withColor: .darkest)
        buttonFooter.frame.origin.y = view.frame.maxY - buttonFooter.frame.height
        buttonFooter.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        buttonFooter.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
    }
    
    // MARK: Delegate methods
    
    func receiveExerciseNames(_ exerciseNames: [Exercise]) {
        currentlySelectedExercises = exerciseNames
    }
}

