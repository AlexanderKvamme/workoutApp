//
//  workoutAppUITests.swift
//  workoutAppUITests
//
//  Created by Alexander Kvamme on 27/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import XCTest

class workoutAppUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Set up snapshot
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // Fastlane Snapshots
    func testScreenshots() {
        
        // FIXME: - Add my own screenshotting automation
        
//        let app = XCUIApplication()
//        XCUIDevice.shared.orientation = .portrait
//        
//        let tabBarsQuery = XCUIApplication().tabBars
//        // Home
//        tabBarsQuery.buttons.element(boundBy: 0).tap()
//        snapshot("0-Home")
//        
//        // Map
//        tabBarsQuery.buttons.element(boundBy: 1).tap()
//        app.otherElements["eventlocation"].tap()
//        snapshot("1-Map")
//        
//        // Twitter
//        tabBarsQuery.buttons.element(boundBy: 2).tap()
//        snapshot("2-Twiter")
    }
    
}
