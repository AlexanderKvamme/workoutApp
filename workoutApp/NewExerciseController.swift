//
//  NewExerciseController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 14/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Protocols
protocol NewExerciseReceiver: class {
    func receiveNewExercise(_ exercise: Exercise)
}

/// Lets users make new exercises
class NewExerciseController: UIViewController, ExerciseReceiver, isStringReceiver {
    
    // MARK: - Properties
    
    let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
    let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
    
    var header: TwoLabelStack = {
        let header = TwoLabelStack(frame: CGRect(x: 0, y: 100, width: Constant.UI.width, height: 70), topText: "Name", topFont: UIFont.custom(style: .bold, ofSize: .medium), topColor: UIColor.akDark.withAlphaComponent(.opacity.faded.rawValue), bottomText: "Your exercise", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: .akDark, fadedBottomLabel: false)
        header.button.accessibilityIdentifier = "exercise-name-button"
        header.button.addTarget(self, action: #selector(headerTapHandler), for: .touchUpInside)
        header.bottomLabel.adjustsFontSizeToFitWidth = true
        return header
    }()
    
    lazy var typeSelecter: TwoLabelStack = {
        let typeSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Type", topFont: darkHeaderFont, topColor: .dark, bottomText: Constant.defaultValues.exerciseType, bottomFont: darkSubHeaderFont, bottomColor: UIColor.dark, fadedBottomLabel: false)
        typeSelecter.button.addTarget(self, action: #selector(typeTapHandler), for: .touchUpInside)
        return typeSelecter
    }()

    lazy var muscleSelecter: TwoLabelStack = {
        let muscleSelecter = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Muscle", topFont: darkHeaderFont, topColor: .dark, bottomText: currentMuscles.getName(), bottomFont: darkSubHeaderFont, bottomColor: .dark, fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        return muscleSelecter
    }()
    
    lazy var measurementSelecter: TwoLabelStack = {
        let measurementSelecter = TwoLabelStack(frame: CGRect(x: 0, y: muscleSelecter.frame.maxY - 40, width: screenWidth, height: selecterHeight), topText: "Measurement", topFont: darkHeaderFont, topColor: .dark, bottomText: DatabaseFacade.defaultMeasurementStyle.name!, bottomFont: darkSubHeaderFont, bottomColor: .dark, fadedBottomLabel: false)
        measurementSelecter.button.addTarget(self, action: #selector(measurementTapHandler), for: .touchUpInside)
       
        return measurementSelecter
    }()

    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 125
    
    var receiveExercises: (([Exercise]) -> ()) = { _ in }
    var stringReceivedHandler: ((String) -> Void) = { _ in } // Receive name/time pickers
    
    fileprivate var currentExerciseStyle: ExerciseStyle!
    fileprivate var currentMuscles: [Muscle]!
    fileprivate var currentMeasurementStyle: MeasurementStyle!
    
    // Delegates
    weak var exercisePickerDelegate: NewExerciseReceiver?
    
    // MARK: - Initializers
    
    init(withPreselectedMuscle muscles: [Muscle]?) {
        super.init(nibName: nil, bundle: nil)
        currentMuscles = muscles ?? [DatabaseFacade.defaultMuscle]
        currentMeasurementStyle = DatabaseFacade.defaultMeasurementStyle
        currentExerciseStyle = DatabaseFacade.defaultExerciseStyle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide tab bar's selection indicator
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.hideSelectionIndicator(shouldAnimate: false)
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        // Footer
        let buttonFooter = ButtonFooter(withColor: .akDark)
        buttonFooter.frame.origin.y = view.frame.maxY - buttonFooter.frame.height
        buttonFooter.cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        buttonFooter.approveButton.addTarget(self, action: #selector(approveTapHandler), for: .touchUpInside)
        
        view.addSubview(header)
        view.addSubview(typeSelecter)
        view.addSubview(muscleSelecter)
        view.addSubview(measurementSelecter)
        view.addSubview(buttonFooter)
    }
    
    // MARK: - Methods
    
    @objc private func headerTapHandler() {
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.setHeader("NAME OF YOUR EXERCISE?")
        workoutNamePicker.delegate = self
        
        stringReceivedHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func typeTapHandler() {
        // Make and present a custom pickerView for selecting type
        let exerciseStyles = DatabaseFacade.getExerciseStyles()
        let typePicker = PickerController<ExerciseStyle>(withPicksFrom: exerciseStyles, withPreselection: currentExerciseStyle)
        typePicker.pickableReceiver = self
        
        // When receivng a selection of workout type
        stringReceivedHandler = { s in
            self.typeSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(typePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let musclePicker = MusclePickerController(withPreselectedMuscles: currentMuscles)
        musclePicker.muscleReceiver = self
        // When receiving a selection of workout musclegroup
        stringReceivedHandler = {
            s in
            self.muscleSelecter.bottomLabel.text = s
        }

        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func measurementTapHandler() {
        let allMeasurements = DatabaseFacade.fetchMeasurementStyles()
        let measurementStylePicker = PickerController<MeasurementStyle>(withPicksFrom: allMeasurements, withPreselection: currentMeasurementStyle)
        
        measurementStylePicker.pickableReceiver = self
        
        stringReceivedHandler = { str in
            self.measurementSelecter.bottomLabel.text = str
        }
        navigationController?.pushViewController(measurementStylePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    // Approve and dismiss
    
    @objc private func approveTapHandler() {
        // Make exercise and save to core data
        guard let name = header.bottomLabel.text, name.count > 0 else {
            let modal = CustomAlertView(messageContent: "Pick a longer name!")
            modal.show(animated: true)
            return
        }
        
        let newExercise = DatabaseFacade.makeExercise(withName: name, exerciseStyle: currentExerciseStyle, muscles: currentMuscles, measurementStyle: currentMeasurementStyle)
        exercisePickerDelegate?.receiveNewExercise(newExercise)
        DatabaseFacade.saveContext()
        
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    @objc func dismissVC() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

extension NewExerciseController: PickableReceiver {
    func receive(pickable: PickableEntity) {
        
        switch pickable {
        case is [Muscle]:
            currentMuscles = pickable as! [Muscle]
            muscleSelecter.setBottomText(currentMuscles.getName())
        case is ExerciseStyle:
            currentExerciseStyle = pickable as! ExerciseStyle
            typeSelecter.setBottomText(pickable.name!)
        case is MeasurementStyle:
            currentMeasurementStyle = pickable as! MeasurementStyle
            measurementSelecter.setBottomText(pickable.name!)
        default:
            preconditionFailure("Was something else entirely")
        }
    }
}

extension NewExerciseController: MuscleReceiver {
    func receive(muscles: [Muscle]) {
        self.currentMuscles = muscles
        self.muscleSelecter.setBottomText(muscles.getName())
    }
}

