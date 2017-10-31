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
        
        // Set up snapshot
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testFastlaneSnapshots() {
        snapshotOfWorkoutInUse()
        snapshotOfOtherThings()
    }
    
    // MARK: Methods
    
    func snapshotOfWorkoutInUse() {
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshotu")
        app.launch()
        
        app.tabBars.buttons["workout-tab"].tap()
        app.buttons["NORMAL"].tap()
        app.cells["PULL DAY"].tap()
        
        // Enter first Exercise
        app.cells["WEIGHTED PULL UP"].buttons["cell-plus-button"].forceTap()
        
        let okButton = app.buttons["OK"]
        let nextButton = app.children(matching: .window).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .button).element(boundBy: 7)
        
        // First lift
        app.buttons["8"].tap()
        nextButton.tap()
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        nextButton.tap()
        
        // Second lift
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
        
        // Second Exercise
        app.cells["PULL UP"].buttons["cell-plus-button"].forceTap()
        
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        nextButton.tap()
        
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        nextButton.tap()
        
        app.buttons["0"].tap()
        okButton.tap()
        
        // Third Exercise
        app.cells["AUSTRALIAN PULL UP"].buttons["cell-plus-button"].forceTap()
        app.buttons["1"].tap()
        app.buttons["7"].tap()
        nextButton.tap()
        
        app.buttons["1"].tap()
        app.buttons["4"].tap()
        nextButton.tap()
        
        app.buttons["1"].tap()
        app.buttons["3"].tap()
        okButton.tap()
        
        // Save button
        app.buttons["footer-save-button"].tap()
        snapshot("great job 9 exercises")
        app.buttons["approve-modal-button"].tap()
        
        // PART 2
        // Make new workout, and snapshot the comparison between current, and old ghost lifts
        
        app.cells["PULL DAY"].tap()
        snapshot("Clean workout")
        
        app.cells["WEIGHTED PULL UP"].buttons["cell-plus-button"].forceTap()
        
        app.buttons["9"].tap()
        nextButton.tap()
        
        app.buttons["1"].tap()
        app.buttons["5"].tap()
        snapshot("ghost lifts")

        okButton.tap()
    }

    func snapshotOfOtherThings() {

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("--fastlaneSnapshotu")
        app.launch()

        // Screenshot of profile tab
        app.tabBars.buttons["profile-tab"].tap()
        snapshot("0-profile")

        // Screenshot of WO style picker
        app.tabBars.buttons["workout-tab"].tap()
        snapshot("1-workout")

        // Screenshot of inside of Normal
        app.buttons["NORMAL"].tap()
        snapshot("2-normal-workouts")
        sleep(1)

        // navigate back to menu
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.tabBars.buttons["workout-tab"].tap()

        // Screenshot of New workout being made
        app.buttons["plus-button"].tap()
        snapshot("3-new-workout")

        // Snapshot of inputting new Name
        app.buttons["workout-name-button"].tap()
        let textField = app.textFields["textfield"]
        textField.typeText("MUSCLE FLEXERS")
        snapshot("4-name-of-new-workout")
        textField.typeText("\r")

        // Snapshot of Exercise type picker
        app.buttons["workout-style-picker-button"].tap()
        snapshot("5-workout-type-picker")
        app.buttons["approve-button"].tap()

        // Snapshot of Muscle type picker
        app.buttons["muscle-picker-button"].tap()
        snapshot("6-muscle-picker")
        app.buttons["approve-button"].tap()

        // Snapshot of adding an exercise
        app.buttons["exercise-picker-button"].tap()

        // Make new Exercise
        app.buttons["plus-button"].tap()
        snapshot("6-new-exercise")
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

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            // let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(0.0, 0.0))
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
        }
    }
}

