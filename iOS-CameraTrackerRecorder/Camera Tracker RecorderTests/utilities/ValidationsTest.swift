//
//  ValidationsTest.swift
//  Camera Tracker RecorderTests
//
//  Created by Michael Levesque on 7/25/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import XCTest
@testable import Cam_Track_Rec

class ValidationsTest : XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testProjectNameValidations() {
        // Valid strings
        XCTAssertTrue(Validations.isProjectNameValid(""))
        XCTAssertTrue(Validations.isProjectNameValid(" "))
        XCTAssertTrue(Validations.isProjectNameValid("a"))
        XCTAssertTrue(Validations.isProjectNameValid("test"))
        XCTAssertTrue(Validations.isProjectNameValid("abcdefghijklmno")) // length test
        XCTAssertTrue(Validations.isProjectNameValid("-----"))
        XCTAssertTrue(Validations.isProjectNameValid("hi hello"))
        XCTAssertTrue(Validations.isProjectNameValid("k.1.g"))
        
        // Invalid strings
        XCTAssertFalse(Validations.isProjectNameValid("gh/k"))
        XCTAssertFalse(Validations.isProjectNameValid("s(l"))
        XCTAssertFalse(Validations.isProjectNameValid("y)k"))
        XCTAssertFalse(Validations.isProjectNameValid("sd:rt"))
        XCTAssertFalse(Validations.isProjectNameValid("abcdefghijklmnop")) // length test
    }
    
    func testSceneValidations() {
        // Valid strings
        XCTAssertTrue(Validations.isSceneValid(""))
        XCTAssertTrue(Validations.isSceneValid(" "))
        XCTAssertTrue(Validations.isSceneValid("a"))
        XCTAssertTrue(Validations.isSceneValid("123B"))
        XCTAssertTrue(Validations.isSceneValid("abcdefgh")) // length test
        XCTAssertTrue(Validations.isSceneValid("-----"))
        XCTAssertTrue(Validations.isSceneValid("hi hello"))
        XCTAssertTrue(Validations.isSceneValid("k.1.g"))
        
        // Invalid strings
        XCTAssertFalse(Validations.isSceneValid("gh/k"))
        XCTAssertFalse(Validations.isSceneValid("s(l"))
        XCTAssertFalse(Validations.isSceneValid("y)k"))
        XCTAssertFalse(Validations.isSceneValid("sd:rt"))
        XCTAssertFalse(Validations.isSceneValid("abcdefghi")) // length test
    }
    
    func testTakeValidations() {
        // Valid strings
        XCTAssertTrue(Validations.isTakeValid("1"))
        XCTAssertTrue(Validations.isTakeValid("45"))
        XCTAssertTrue(Validations.isTakeValid("123"))
        
        // Invalid strings
        XCTAssertFalse(Validations.isTakeValid(""))
        XCTAssertFalse(Validations.isTakeValid(" "))
        XCTAssertFalse(Validations.isTakeValid("a"))
        XCTAssertFalse(Validations.isTakeValid("0.3"))
        XCTAssertFalse(Validations.isTakeValid("-90"))
        XCTAssertFalse(Validations.isTakeValid("1234")) // length test
    }
    
    func testDefaultValueValidations() {
        let projectName = ConfigWrapper.getString(withKey: ConfigKeys.defaultProjectName)
        let scene = ConfigWrapper.getString(withKey: ConfigKeys.defaultScene)
        let take = ConfigWrapper.getInt(withKey: ConfigKeys.defaultTake)
        XCTAssertTrue(Validations.isProjectNameValid(projectName))
        XCTAssertTrue(Validations.isSceneValid(scene))
        XCTAssertTrue(Validations.isTakeValid("\(take)"))
    }
}
