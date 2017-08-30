//
//  newWorkoutController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: - Class

class NewWorkoutController: UIViewController, ExerciseReceiver {

    // MARK: - Properties

    private let halfScreenWidth = Constant.UI.width/2
    private let screenWidth = Constant.UI.width
    private let selecterHeight: CGFloat = 150
    
    // Components
    fileprivate var muscleSelecter: TwoLabelStack!
    fileprivate var workoutStyleSelecter: TwoLabelStack!
    fileprivate var exerciseSelecter: TwoLabelStack!
    
    private var header: TwoLabelStack!
    
    private var weightSelectionBox: Box!
    private var restSelectionBox: Box!
    private var buttonFooter: ButtonFooter!
    
    private var currentExercise = [Exercise]()
    
    fileprivate var currentMuscle: Muscle!
    fileprivate var currentWorkoutStyle: WorkoutStyle!
    
    var receiveExercises: (([Exercise]) -> ()) = { _ in }
    var stringReceivedHandler: ((String) -> Void) = { _ in } //  used to receiving of time and workoutname from pickers
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
        
        currentMuscle = DatabaseFacade.defaultMuscle
        currentWorkoutStyle = DatabaseFacade.defaultWorkoutStyle
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
    
    // MARK: - Methods
    
    @objc private func approveAndDismissVC() {
        
        // Present error modal if workout contains no exercises
        guard currentExercise.count > 0 else {
            let errorMessage = "Add at least one exercise, please!"
            let modal = CustomAlertView(type: .message, messageContent: errorMessage)
            modal.show(animated: true)
            return
         }
        
        // FIXME: - Present error modal if workout contains no muscle
        
        guard let currentMuscle = currentMuscle else {
            print("current muscle is not chosen. present modal")
            return
        }
        
        guard let currentWorkoutStyle = currentWorkoutStyle else {
            print("current exercise style is not chosen. present modal")
            return
        }
        
        guard currentExercise.count > 0 else {
            let errorMessage = "Add at least one exercise, please!"
            let modal = CustomAlertView(type: .message, messageContent: errorMessage)
            modal.show(animated: true)
            return
        }
        
        if let workoutName = header.bottomLabel.text,
           let workoutStyleName = workoutStyleSelecter.bottomLabel.text,
           let muscleName = muscleSelecter.bottomLabel.text {
            DatabaseFacade.makeWorkout(withName: workoutName, workoutStyleName: workoutStyleName, muscleName: muscleName, exercises: currentExercise)
            DatabaseFacade.saveContext()
        } else {
            print("could not make workout")
        }
        navigationController?.popViewController(animated: true)
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Tap handlers
    
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
        let workoutStyles = DatabaseFacade.fetchManagedObjectsForEntity(.WorkoutStyle) as! [WorkoutStyle]
        let typePicker = PickerController<WorkoutStyle>(withPicksFrom: workoutStyles, withPreselection: currentWorkoutStyle)
        
        typePicker.pickableReceiver = self
    
        navigationController?.pushViewController(typePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let existingMuscles = DatabaseFacade.fetchMuscles()
        let musclePicker = PickerController<Muscle>(withPicksFrom: existingMuscles, withPreselection: currentMuscle)
        
        musclePicker.pickableReceiver = self
        
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
    
    // MARK: Helper methods
    
    @objc private func exercisesTapHandler() {
        
        // Use selected muscle to prepare a pickerview and update UI
        guard let muscleName = muscleSelecter.bottomLabel.text else {
            return
        }
        
        let selectedMuscle = DatabaseFacade.getMuscle(named: muscleName)! // Only existing muscles are displayed so force unwrap
        let exercisePicker = ExercisePickerController(forMuscle: selectedMuscle, withPreselectedExercises: currentExercise)
        
        exercisePicker.pickableReceiver = self
        exercisePicker.exerciseReceiver = self
        
        // prepare to receive exercises back from picker
        receiveExercises = { exercises in
            self.currentExercise = exercises
            self.exerciseSelecter.bottomLabel.text = String(exercises.count)
        }
        
        navigationController?.pushViewController(exercisePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    // MARK: Helper methods
    
    private func setupHeader() {
        header = TwoLabelStack(frame: CGRect(x: 0, y: 100, width: Constant.UI.width, height: 70), topText: "Name of new workout", topFont: UIFont.custom(style: .bold, ofSize: .medium), topColor: UIColor.medium, bottomText: "Your workout", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.darkest, fadedBottomLabel: false)
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
        exerciseSelecter = TwoLabelStack(frame: CGRect(x: 0, y: restSelectionBox.frame.maxY + 20, width: Constant.UI.width, height: 100), topText: " Exercises Added", topFont: UIFont.custom(style: .bold, ofSize: .medium),
            topColor: UIColor.faded, bottomText: "0", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.dark, fadedBottomLabel: false)
        exerciseSelecter.button.addTarget(self, action: #selector(exercisesTapHandler), for: .touchUpInside)
    }
    
    private func setupFooter() {
        // Footer
        buttonFooter = ButtonFooter(withColor: .darkest)
        buttonFooter.frame.origin.y = view.frame.maxY - buttonFooter.frame.height
        buttonFooter.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        buttonFooter.approveButton.addTarget(self, action: #selector(approveAndDismissVC), for: .touchUpInside)
    }
}

extension NewWorkoutController: PickableReceiver {
    // Receive Muscle, ExerciseStyle, and WorkoutStyle
    func receive(pickable: PickableEntity) {

        switch pickable {
        case is Muscle:
            currentMuscle = pickable as! Muscle
            muscleSelecter.bottomLabel.text = currentMuscle.name
            self.exerciseSelecter.topLabel.text = "Exercises Added".uppercased()
        case is WorkoutStyle:
            currentWorkoutStyle = pickable as! WorkoutStyle
            workoutStyleSelecter.bottomLabel.text = currentWorkoutStyle.name
        default:
            print("Received something wierd")
        }
    }
}

// When receiving a selection of workout musclegroup
extension NewWorkoutController : isStringReceiver {}

