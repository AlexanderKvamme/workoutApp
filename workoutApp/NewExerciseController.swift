//
//  NewExerciseController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 14/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

protocol NewExerciseReceiver: class {
    func receiveNewExercise(_ exercise: Exercise)
}

class NewExerciseController: UIViewController, isExerciseReceiver, isStringReceiver {
    
    // MARK: - Properties
    
    var receiveExercises: (([Exercise]) -> ()) = { _ in }
    var stringReceivedHandler: ((String) -> Void) = { _ in } // Required method to handle the receiving of a final selection of name/time pickers
    
    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 125
    var header: TwoLabelStack!
    var typeSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var measurementSelecter: TwoLabelStack!

    fileprivate var currentExerciseStyle: ExerciseStyle!
    fileprivate var currentMuscle: Muscle!
    fileprivate var currentMeasurementStyle: MeasurementStyle!
    
    weak var exercisePickerDelegate: NewExerciseReceiver?
    
    // MARK: - Initializers
    
    init(withPreselectedMuscle muscle: Muscle?) {
        super.init(nibName: nil, bundle: nil)
        
        currentMuscle = muscle ?? DatabaseFacade.defaultMuscle
        currentMeasurementStyle = DatabaseFacade.defaultMeasurementStyle
        currentExerciseStyle = DatabaseFacade.defaultExerciseStyle
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
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
        
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        
        // Setup Header, muscle, type, rest, and exercises
        header = TwoLabelStack(frame: CGRect(x: 0, y: 100, width: Constant.UI.width, height: 70), topText: "Name", topFont: UIFont.custom(style: .bold, ofSize: .medium), topColor: UIColor.medium, bottomText: "Your exercise", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.darkest, fadedBottomLabel: false)
        header.button.addTarget(self, action: #selector(headerTapHandler), for: .touchUpInside)
        header.bottomLabel.adjustsFontSizeToFitWidth = true
        
        // Type selecter
        typeSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Type", topFont: darkHeaderFont, topColor: .dark, bottomText: Constant.defaultValues.exerciseType, bottomFont: darkSubHeaderFont, bottomColor: UIColor.dark, fadedBottomLabel: false)
        typeSelecter.button.addTarget(self, action: #selector(typeTapHandler), for: .touchUpInside)
        
        // Muscle selecter
        let muscleFrame = CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight)
        muscleSelecter = TwoLabelStack(frame: muscleFrame, topText: "Muscle", topFont: darkHeaderFont, topColor: .dark, bottomText: currentMuscle?.name ?? Constant.defaultValues.muscle, bottomFont: darkSubHeaderFont, bottomColor: .dark, fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        
        // Measurement style
        let frameForMeasurementStyle = CGRect(x: 0, y: muscleSelecter.frame.maxY, width: screenWidth, height: selecterHeight)
        measurementSelecter = TwoLabelStack(frame: frameForMeasurementStyle, topText: "Measurement", topFont: darkHeaderFont, topColor: .dark, bottomText: DatabaseFacade.defaultMeasurementStyle.name!, bottomFont: darkSubHeaderFont, bottomColor: .dark, fadedBottomLabel: false)
        measurementSelecter.button.addTarget(self, action: #selector(measurementTapHandler), for: .touchUpInside)
        
        // Footer
        let buttonFooter = ButtonFooter(withColor: .darkest)
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
    
    // MARK: Tap handlers
    
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
        let exerciseStyles = DatabaseFacade.fetchExerciseStyles()
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
        let allMuscles = DatabaseFacade.fetchMuscles()
        let musclePicker = PickerController<Muscle>(withPicksFrom: allMuscles, withPreselection: currentMuscle)
    
        musclePicker.pickableReceiver = self
        
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
        
        stringReceivedHandler = {
            s in
            print("received back: ", s)
            self.measurementSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(measurementStylePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
 
    }
    
    // Approve and dismiss
    
    @objc private func approveTapHandler() {
        
        // Make exercise and save to core data
        if let name = header.bottomLabel.text {
            guard name.characters.count > 0 else {
                let modal = CustomAlertView(type: .message, messageContent: "Pick a longer name!")
                modal.show(animated: true)
                return
            }
            
            let newExercise = DatabaseFacade.makeExercise(withName: name, exerciseStyle: currentExerciseStyle, muscle: currentMuscle, measurementStyle: currentMeasurementStyle)
            
            print("made exercise: ", newExercise)
            // Signal to delegate ( exercisePicker ) that user made a new exercise, and that the VC is supposed to mark it as selected
            exercisePickerDelegate?.receiveNewExercise(newExercise)
            DatabaseFacade.saveContext()
        }
        
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    // MARK: - Helper methods
}

extension NewExerciseController: PickableReceiver {
    func receivePickable(_ object: PickableEntity) {
        print(" received object: ", object)
        
        switch object {
        case is Muscle:
            currentMuscle = object as! Muscle
            muscleSelecter.setBottomText(object.name!)
        case is ExerciseStyle:
            currentExerciseStyle = object as! ExerciseStyle
            typeSelecter.setBottomText(object.name!)
        case is MeasurementStyle:
            currentMeasurementStyle = object as! MeasurementStyle
            measurementSelecter.setBottomText(object.name!)
        default:
            print("Was something else entirely")
        }
    }
}

