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

protocol NewExerciseReceiver: class {
    func receiveNewExercise(_ exercise: Exercise)
}

class NewExerciseController: UIViewController, isStringReceiver, isExerciseNameReceiver {
    
    var receiveHandler: ((String) -> Void) = { _ in } // Required method to handle the receiving of a final selection of muscle/type/weight/time pickers
    
    let halfScreenWidth = Constant.UI.width/2
    let screenWidth = Constant.UI.width
    let selecterHeight: CGFloat = 125
    var header: TwoLabelStack!
    var typeSelecter: TwoLabelStack!
    var muscleSelecter: TwoLabelStack!
    var measurementSelecter: TwoLabelStack!
    var nameOfCurrentlySelectedExercises = [String]()
    var preselectedMuscle: Muscle? = nil
    
    weak var exercisePickerDelegate: NewExerciseReceiver?
    
    init(withPreselectedMuscle muscle: Muscle?) {
        super.init(nibName: nil, bundle: nil)
        
        preselectedMuscle = muscle
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
        
        // Type selecter
        
        typeSelecter = TwoLabelStack(frame: CGRect(x: 0, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight),
                                     topText: "Type",
                                     topFont: darkHeaderFont,
                                     topColor: .dark,
                                     bottomText: Constant.defaultValues.exerciseType,
                                     bottomFont: darkSubHeaderFont,
                                     bottomColor: UIColor.dark,
                                     fadedBottomLabel: false)
        typeSelecter.button.addTarget(self, action: #selector(typeTapHandler), for: .touchUpInside)
        
        // Muscle selecter
        
        let muscleFrame = CGRect(x: halfScreenWidth, y: header.frame.maxY, width: halfScreenWidth, height: selecterHeight)
        muscleSelecter = TwoLabelStack(frame: muscleFrame,
                                       topText: "Muscle",
                                       topFont: darkHeaderFont,
                                       topColor: .dark,
                                       bottomText: preselectedMuscle?.name ?? Constant.defaultValues.muscle,
                                       bottomFont: darkSubHeaderFont,
                                       bottomColor: .dark,
                                       fadedBottomLabel: false)
        muscleSelecter.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        
        // Measurement style
        
        let frameForMeasurementStyle = CGRect(x: 0, y: muscleSelecter.frame.maxY, width: screenWidth, height: selecterHeight)
        measurementSelecter = TwoLabelStack(frame: frameForMeasurementStyle,
                                                topText: "Measurement",
                                                topFont: darkHeaderFont,
                                                topColor: .dark,
                                                bottomText: Constant.defaultValues.measurement      ,
                                                bottomFont: darkSubHeaderFont,
                                                bottomColor: .dark,
                                                fadedBottomLabel: false)
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
        
//        header.setDebugColors()
//        typeSelecter.setDebugColors()
//        muscleSelecter.setDebugColors()
//        measurementSelecter.setDebugColors()
    }
    
    func dismissVC() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    // MARK: - Tap handlers
    
    @objc private func headerTapHandler() {
        let workoutNamePicker = InputViewController(inputStyle: .text)
        workoutNamePicker.delegate = self
        
        receiveHandler = { s in
            self.header.bottomLabel.text = s
        }
        navigationController?.pushViewController(workoutNamePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func typeTapHandler() {
        // Make and present a custom pickerView for selecting type
        let currentlySelectedType = typeSelecter.bottomLabel.text
//        let exerciseStyles = DatabaseController.fetchManagedObjectsForEntity(.ExerciseStyle) as! [ExerciseStyle]
        let exerciseStyles = DatabaseFacade.fetchExerciseStyles()
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
        navigationController?.pushViewController(typePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let currentlySelectedMuscle = muscleSelecter.bottomLabel.text
        var muscleNames = [String]()
        // Fetch unique muscles
        let musclesFromCoreData = DatabaseFacade.fetchManagedObjectsForEntity(.Muscle) as! [Muscle]
        
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
        }
        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func measurementTapHandler() {
        let currentlySelectedMeasurement = measurementSelecter.bottomLabel.text
        var measurementNames = [String]()
        
        let measurementsFromCoreData = DatabaseFacade.fetchManagedObjectsForEntity(.MeasurementStyle) as! [MeasurementStyle]
        
        for measurementStyle in measurementsFromCoreData {
            if let name = measurementStyle.name {
                measurementNames.append(name)
            }
        }
        
        let measurementStylePicker = PickerViewController(withChoices: measurementNames, withPreselection: currentlySelectedMeasurement)
        measurementStylePicker.delegate = self
        receiveHandler = {
            s in
            print("received back: ", s)
            self.measurementSelecter.bottomLabel.text = s
        }
        navigationController?.pushViewController(measurementStylePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
 }
    
    @objc private func approveTapHandler() {
        // Make exercise and save to core data
        
        // Unwrap user selections to 
        if let name = header.bottomLabel.text, let exerciseStyle = typeSelecter.bottomLabel.text, let muscleName = muscleSelecter.bottomLabel.text, let measurementStyle = measurementSelecter.bottomLabel.text {
            
            let newExercise = DatabaseFacade.makeExercise(withName: name, styleName: exerciseStyle, muscleName: muscleName, measurementStyleName: measurementStyle)
            
            // Signal to delegate ( exercisePicker ) that user made a new exercise, and that the VC is supposed to mark it as selected
            exercisePickerDelegate?.receiveNewExercise(newExercise)
        }

        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    // MARK: - Helper methods
    
    // MARK: - Delegate methods
    
    func receiveExerciseNames(_ exerciseNames: [String]) {
        nameOfCurrentlySelectedExercises = exerciseNames
    }
}

