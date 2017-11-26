//
//  workoutAppUITests.swift
//  workoutAppUITests
//
//  Created by Alexander Kvamme on 27/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import XCTest


class workoutAppUITests: XCTestCase {
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // MARK: Teardown
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    func testSeedAbortedActiveWorkout() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshot")
        app.launch()
        
        app.tabBars.buttons["workout-tab"].tap()
        
        app.buttons["NORMAL"].firstMatch.tap()
        app.cells["PULL DAY"].tap()
        
        let nextButton = app.buttons["customNextButton"].firstMatch
        
        // Tap plus button and start entering workouts for the first exercise
        app.cells["PULL UP"].buttons["cell-plus-button"].forceTap()
        
        // Enter Lifts
        app.buttons["8"].tap()
        nextButton.tap()
        app.buttons["8"].tap()
    }
    
    func testFastlaneSeeding() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshot")
        app.launch()
    }
    
    func testExercisepickingSnapshots() {
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshot")
        app.launch()
        
        app.tabBars.buttons["workout-tab"].tap()
        
        // Screenshot of New workout being made
        app.buttons["plus-button"].tap()
        
        // Snapshot of Muscle type picker
        app.buttons["muscle-picker-button"].tap()
        
        app.cells["OTHER-muscle-button"].tap()
        app.cells["BACK-muscle-button"].tap()
        // snapshot("9-Switching to back muscle")
    }
    
    func testSnapshotsOfWorkoutInUse() {
        // Launch
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshot")
        app.launch()
        
        app.tabBars.buttons["workout-tab"].tap()
        app.buttons["NORMAL"].firstMatch.tap()
        app.cells["PULL DAY"].tap()
        
        // Tap plus button and start entering workouts for the first exercise
        app.cells["WEIGHTED PULL UP"].buttons["cell-plus-button"].forceTap()
        
        let okButton = app.buttons["OK"]
        let nextButton = app.buttons["customNextButton"].firstMatch
        
        // Enter First lift
        app.buttons["8"].tap()
        nextButton.tap()
        sleep(5)
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        nextButton.tap()
        
        // Enter Second lift
        app.buttons["6"].tap()
        nextButton.tap()
        app.buttons["2"].tap()
        app.buttons["0"].tap()
        nextButton.tap()
        
        // Enter third lift
        app.buttons["4"].tap()
        nextButton.tap()
        app.buttons["3"].tap()
        app.buttons["0"].tap()
        okButton.tap()
        
        // Move on to Second Exercise
        app.cells["PULL UP"].buttons["cell-plus-button"].forceTap()
        
        // Enter First lift
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        nextButton.tap()
        
        // Enter Second lift
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        nextButton.tap()
        
        app.buttons["0"].tap()
        okButton.tap()
        
        // Move on to Third Exercise
        app.cells["AUSTRALIAN PULL UP"].buttons["cell-plus-button"].forceTap()
        
        // Enter First Lift
        app.buttons["1"].tap()
        app.buttons["7"].tap()
        nextButton.tap()
        
        // Enter Second Lift
        app.buttons["1"].tap()
        app.buttons["4"].tap()
        nextButton.tap()
        
        // Enter Third Lift
        app.buttons["1"].tap()
        app.buttons["3"].tap()
        okButton.tap()
        
        // Save
        app.buttons["footer-save-button"].tap()
        snapshot("great job 9 exercises")
        app.buttons["approve-modal-button"].tap()
        
        // PART 2
        // Make new workout, and snapshot the comparison between current, and old ghost lifts
        
        // Enter the Pull Day
        app.cells["PULL DAY"].tap()
        snapshot("Clean workout")
        
        // Tap plus button to start entering lifts
        app.cells["WEIGHTED PULL UP"].buttons["cell-plus-button"].forceTap()
        
        // Enter First Lifts reps
        app.buttons["9"].tap()
        nextButton.tap()
        app.buttons["1"].tap()
        app.buttons["5"].tap()
        snapshot("ghost lifts")

        okButton.tap()
    }

    /// Snapshot of profile tab, Style picker, boxtable of normal workouts, New workout, with muscle pickers, style pickers, name input view, and exercisePicker
    func testSnapshotsOfExercisePicking() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshot")
        app.launch()

        // Screenshot of profile tab
        app.tabBars.buttons["profile-tab"].tap()
        snapshot("0-profile")

        // Screenshot of WO style picker
        app.tabBars.buttons["workout-tab"].tap()
        snapshot("1-workout")

        // Screenshot of inside of Normal
        app.buttons["NORMAL"].firstMatch.tap()
        snapshot("2-normal-workouts")
        sleep(1)

        // navigate back to menu
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.tabBars.buttons["workout-tab"].tap()

        // Screenshot of New workout being made
        app.buttons["plus-button"].tap()
        // snapshot("3-new-workout")

        // Snapshot of inputting new Name
        app.buttons["workout-name-button"].tap()
        let textField = app.textFields["textfield"]
        textField.typeText("MUSCLE FLEXERS")
        // snapshot("4-name-of-new-workout")
        textField.typeText("\r")

        // Snapshot of Exercise type picker
        app.buttons["workout-style-picker-button"].tap()
        snapshot("5-workout-type-picker")
        app.buttons["approve-button"].tap()

        // Snapshot of Muscle type picker
        app.buttons["muscle-picker-button"].tap()
        
        // Select muscles
        sleep(3)
        
        app.cells["OTHER-muscle-button"].firstMatch.tap()
        app.cells["BACK-muscle-button"].firstMatch.tap()

        //snapshot("6-muscle-picker")
        
        app.buttons["approve-button"].tap()

        // Snapshot of adding an exercise
        app.buttons["exercise-picker-button"].tap()
        // Snap ExercisePicker
        // snapshot("6-ExercisePicker")

        // Make new Exercise
        app.buttons["plus-button"].tap()
        snapshot("7-new-exercise")
        app.buttons["approve-button"].tap()

        // Make second exercise
        app.buttons["plus-button"].tap()
        app.buttons["exercise-name-button"].tap()
        textField.typeText("MY SECOND EXERCISE")
        textField.typeText("\r")
        app.buttons["approve-button"].tap()

        // Make third exercise
        app.buttons["plus-button"].tap()
        app.buttons["exercise-name-button"].tap()
        textField.typeText("MY THIRD EXERCISE")
        textField.typeText("\r")
        app.buttons["approve-button"].tap()

        // Save the chose new 3 Exercises
        app.buttons["approve-button"].tap()

        // Save workout
        app.buttons["approve-button"].tap()
    }
}

// MARK: - Extensions

extension XCUIElement {
    
    /// Lets you tap views that are not tappable
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
        }
    }
}

