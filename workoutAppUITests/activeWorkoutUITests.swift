//
//  activeWorkoutUITests.swift
//  workoutAppUITests
//
//  Created by Alexander Kvamme on 21/11/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import XCTest
//import Pods_workoutApp
//@testable import workoutApp

class activeWorkoutUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
    
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    func testTempTestTextInput() {
        let app = XCUIApplication()
        app.launchArguments.append("ACTIVE_WORKOUT_UITESTS")
        app.launch()
        
        // Screenshot of WO style picker
        app.tabBars.buttons["workout-tab"].tap()
        app.buttons["NORMAL"].tap()
        app.cells["LONG WORKOUT"].tap()
        
        // Buttons
        let okButton = app.buttons["OK"]
        let nextButton = app.buttons["customNextButton"].firstMatch
        
        // Fill sets values
        app.cells["WEIGHTED PULL UP"].buttons["cell-plus-button"].forceTap()
        app.buttons["1"].tap()
        nextButton.tap()
        app.buttons["1"].tap()
        app.buttons["1"].tap()
        okButton.tap()
        
        // FIXME: Try to get value from collectionViewcell and print out the lift its representing
//        let textView = app.cells["WEIGHTED PULL UP"].textFields.firstMatch
        let textView = app.cells["WEIGHTED PULL UP"].collectionViews.firstMatch
        
//        XCUIApplication().tables/*@START_MENU_TOKEN@*/.collectionViews/*[[".cells[\"WEIGHTED PULL UP\"].collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.cells.children(matching: .button).element.tap()
//        XCUIApplication().tables/*@START_MENU_TOKEN@*/.cells["WEIGHTED PULL UP"].collectionViews.textFields["1"]/*[[".cells[\"WEIGHTED PULL UP\"].collectionViews",".cells.textFields[\"1\"]",".textFields[\"1\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[1,0]]@END_MENU_TOKEN@*/.tap()
//
        let text =  XCUIApplication().tables.cells["WEIGHTED PULL UP"].collectionViews.firstMatch.textFields.firstMatch.value as! String
        
        assert(text == "1")
    }
    
    func testExerciseCellsAreReorderable() {

        let app = XCUIApplication()
        app.launchArguments.append("ACTIVE_WORKOUT_UITESTS")
        app.launch()
        
        // Screenshot of WO style picker
        app.tabBars.buttons["workout-tab"].tap()
        app.buttons["NORMAL"].tap()
        app.cells["LONG WORKOUT"].tap()
        
        // Buttons
        let okButton = app.buttons["OK"]
        let nextButton = app.buttons["customNextButton"].firstMatch
        
        let pullUpCell = app.cells["PULL UP"]

        // Fill sets values
        app.cells["WEIGHTED PULL UP"].buttons["cell-plus-button"].forceTap()
        app.buttons["1"].tap()
        nextButton.tap()
        app.buttons["1"].tap()
        app.buttons["1"].tap()
        okButton.tap()
        
        //        app.cells["PULL UP"].buttons["cell-plus-button"].forceTap()
        //        app.buttons["2"].tap()
        //        okButton.tap()
        //
        //        app.cells["WMS AUS PULL"].buttons["cell-plus-button"].forceTap()
        //        app.buttons["3"].tap()
        //        okButton.tap()
        //
        //        app.cells["CHEST TO BAR"].buttons["cell-plus-button"].forceTap()
        //        app.buttons["4"].tap()
        //        okButton.tap()
        //
        //        app.cells["ASSISTED CHEST TO BAR"].buttons["cell-plus-button"].forceTap()
        //        app.buttons["5"].tap()
        //        okButton.tap()
        //
        //        app.cells["NEGATIVE MUSCLE UP"].buttons["cell-plus-button"].forceTap()
        //        app.buttons["6"].tap()
        //        okButton.tap()
        //
        //        app.cells["BICEP FLEX"].buttons["cell-plus-button"].forceTap()
        //        app.buttons["7"].tap()
        //        okButton.tap()
        

        // FIXME: TEMP SCROLL TO T
        app.cells["TRICEPS FLEX"].tap()
        app.cells["TRICEPS FLEX"].buttons["cell-plus-button"].forceTap()
        app.buttons["8"].tap()
        okButton.tap()
        
        // MARK: Done with first set of entries 1-8
        
        // Set up cells
        let weightedCell = app.cells["WEIGHTED PULL UP"]
        let bicepsCell = app.cells["BICEP FLEX"]
        let tricepsCell = app.cells["TRICEPS FLEX"]
        
        // Move bottom cell up
        var start = tricepsCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        var finish = pullUpCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        start.press(forDuration: 2, thenDragTo: finish)
        
        // Move more up
        weightedCell.tap()
        
        // Move topmost cell down
        start = weightedCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        finish = bicepsCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        start.press(forDuration: 2, thenDragTo: finish)

        // Move down to see
        tricepsCell.tap()
        
        // MARK: Sencod pass of sets
        
        // second set of triceps flexers
        app.cells["TRICEPS FLEX"].tap()
        tricepsCell.buttons["cell-plus-button"].forceTap()
        app.buttons["8"].tap()
        app.buttons["2"].tap()
        okButton.tap()
        
        // Scroll down to weighted cell in the bot and enter second set of 12/12

        let tablesQuery = XCUIApplication().tables
        tablesQuery.cells["NEGATIVE MUSCLE UP"].children(matching: .collectionView).element.swipeUp()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["BICEP FLEX"]/*[[".cells[\"BICEP FLEX\"].staticTexts[\"BICEP FLEX\"]",".staticTexts[\"BICEP FLEX\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        tablesQuery.cells["WEIGHTED PULL UP"].buttons["+"].forceTap()
        
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        nextButton.tap()
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        okButton.tap()

        // Scroll up and assert correct value
        
        // FIXME: Bra hittil
        app.cells["TRICEPS FLEX"].tap()
        
        let tricepsFlexCell = app.tables.cells["TRICEPS FLEX"]

        print("tests should be done")
        
        /*
         - weighred pulls should be 1/11, 12/12
         - triceps 8, 82
        
         - cell[0] er 1, 82, mens den burde vært 82 82... jeg tror dette er fordi datasourcen ikke blir byttet. Fordi datarourcen har tydeligvis 1/11, 82
        */
        
    }
}
