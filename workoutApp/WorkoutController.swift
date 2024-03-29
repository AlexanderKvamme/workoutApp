
import UIKit
import AKKIT

/// ViewController to manage the creation of new workouts
class WorkoutController: UIViewController, ExerciseReceiver, isStringReceiver {
    
    // MARK: - Properties
    
    // required properties
    var currentMuscles: [Muscle]!
    var currentWorkoutStyle: WorkoutStyle!
    var receiveExercises: (([Exercise]) -> ()) = { _ in }
    var stringReceivedHandler: ((String) -> Void) = { _ in } // Receiving of time and name from pickers
    
    // Computed properties
    
    lazy var muscleSelecter: TwoLabelStack = {
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        let halfScreenWidth = Constant.UI.width/2
        let selecterHeight: CGFloat = 150
        
        let stack = TwoLabelStack(frame: CGRect(x: halfScreenWidth, y: self.header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Muscle", topFont: darkHeaderFont, topColor: .akDark, bottomText: Constant.defaultValues.muscle, bottomFont: darkSubHeaderFont, bottomColor: UIColor.akDark, fadedBottomLabel: false)
        stack.button.accessibilityIdentifier = "muscle-picker-button"
        stack.button.addTarget(self, action: #selector(muscleTapHandler), for: .touchUpInside)
        
        return stack
    }()
    
    lazy var workoutStyleSelecter: TwoLabelStack = {
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        let halfScreenWidth = Constant.UI.width/2
        let selecterHeight: CGFloat = 150
        
        let workoutStyleSelecter = TwoLabelStack(frame: CGRect(x: 0, y: self.header.frame.maxY, width: halfScreenWidth, height: selecterHeight), topText: "Type", topFont: darkHeaderFont, topColor: .akDark, bottomText: Constant.defaultValues.exerciseType, bottomFont: darkSubHeaderFont, bottomColor: UIColor.akDark, fadedBottomLabel: false)
        workoutStyleSelecter.button.accessibilityIdentifier = "workout-style-picker-button"
        workoutStyleSelecter.button.addTarget(self, action: #selector(showWorkoutStyleEditor), for: .touchUpInside)
        
        return workoutStyleSelecter
    }()
    
    lazy var exerciseSelecter: TwoLabelStack = {
        let newframe = CGRect(x: 0, y: self.workoutStyleSelecter.frame.maxY - 30, width: Constant.UI.width, height: 100)
        let exerciseSelecter = TwoLabelStack(frame: newframe, topText: " Exercises Added", topFont: UIFont.custom(style: .medium, ofSize: .medium), topColor: UIColor.akDark, bottomText: "0", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.akDark, fadedBottomLabel: false)
        exerciseSelecter.button.accessibilityIdentifier = "exercise-picker-button"
        exerciseSelecter.button.addTarget(self, action: #selector(exercisesTapHandler), for: .touchUpInside)

        return exerciseSelecter
    }()
    
    lazy var header: TwoLabelStack = {
        let stack = TwoLabelStack(frame: CGRect(x: 0, y: 100, width: Constant.UI.width, height: 70), topText: "Name of new workout", topFont: UIFont.custom(style: .bold, ofSize: .medium), topColor: UIColor.akDark.withAlphaComponent(0.4), bottomText: "My workout", bottomFont: UIFont.custom(style: .bold, ofSize: .big), bottomColor: UIColor.akDark, fadedBottomLabel: false)
        stack.button.accessibilityIdentifier = "workout-name-button"
        stack.bottomLabel.adjustsFontSizeToFitWidth = true
        
        return stack
    }()
    
    lazy var restSelectionBox: Box = {
        // Make Rest Box
        let boxFactory = BoxFactory.makeFactory(type: .SelectionBox)
        let restHeader = boxFactory.makeBoxHeader()
        let restSubHeader = boxFactory.makeBoxSubHeader()
        let restFrame = boxFactory.makeBoxFrame()
        let restContent = boxFactory.makeBoxContent()
        
        let halfScreenWidth = Constant.UI.width/2
        
        let box = Box(header: restHeader, subheader: restSubHeader, bgFrame: restFrame!, content: restContent!)
        box.frame.origin = CGPoint(x: halfScreenWidth - box.frame.width/2, y: self.workoutStyleSelecter.frame.maxY)
        box.button.addTarget(self, action: #selector(restTapHandler), for: .touchUpInside)
        box.setContentLabel("3:00")
        box.setTitle("Rest")
        
        return box
    }()
    
    var currentExercises = [Exercise]() {
        didSet {
            self.exerciseSelecter.bottomLabel.text = String(currentExercises.count)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        globalTabBar.showIt()
    }
    
    // MARK: - Methods
    
    @objc func dismissVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // Tap handlers
    @objc private func showWorkoutStyleEditor() {
        // Make and present a custom pickerView for selecting type
        let workoutStyles = DatabaseFacade.fetchWorkoutStyles()
        let typePicker = PickerController<WorkoutStyle>(withPicksFrom: workoutStyles, withPreselection: currentWorkoutStyle)
        
        typePicker.pickableReceiver = self
        
        navigationController?.pushViewController(typePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func muscleTapHandler() {
        // Make and present a custom pickerView for selecting muscle
        let musclePicker = MusclePickerController(withPreselectedMuscles: currentMuscles)
        musclePicker.muscleReceiver = self

        navigationController?.pushViewController(musclePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    @objc private func restTapHandler() {
        // Prepares and present a VC to input weight
        let restInputViewController  = InputViewController(inputStyle: .time)
        restInputViewController.delegate = self
        
        stringReceivedHandler = { str in
            if str != "" {
                self.restSelectionBox.content?.label?.text = str
            }
        }
        navigationController?.pushViewController(restInputViewController, animated: false)
    }
    
    @objc private func exercisesTapHandler() {
        let exercisePicker = ExercisePickerController(forMuscle: currentMuscles, withPreselectedExercises: currentExercises)
        
        exercisePicker.pickableReceiver = self
        exercisePicker.exerciseReceiver = self
        
        // prepare to receive exercises back from picker
        receiveExercises = { exercises in
            self.currentExercises = exercises
        }
        
        navigationController?.pushViewController(exercisePicker, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
}

// MARK: - Extensions

extension WorkoutController: PickableReceiver {
    // Receive Muscle, ExerciseStyle, and WorkoutStyle
    func receive(pickable: PickableEntity) {
        
        switch pickable {
        case is Muscle:
            currentMuscles = pickable as! [Muscle]
            setMuscleName(currentMuscles)
            self.exerciseSelecter.topLabel.text = "Exercises Added".uppercased()
        case is WorkoutStyle:
            currentWorkoutStyle = pickable as! WorkoutStyle
            workoutStyleSelecter.bottomLabel.text = currentWorkoutStyle.name
        default:
            print("Received something wierd")
        }
    }
    
    private func setMuscleName(_ muscles: [Muscle]) {
        if muscles.count == 1 {
            muscleSelecter.bottomLabel.text = muscles.first!.name
        } else {
            muscleSelecter.bottomLabel.text = "MIXED"
        }
    }
}

// MARK: Helpers

extension WorkoutController {
    var hasExercises: Bool {
        return currentExercises.count > 0
    }
}

extension WorkoutController: MuscleReceiver {
    func receive(muscles: [Muscle]) {
        self.currentMuscles = muscles
        self.muscleSelecter.setBottomText(muscles.getName())
    }
}

