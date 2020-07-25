//
//  Validations.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/24/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

class Validations {
    
    /// Returns true if the given full string for project name is valid. Validity means that it is within the size limit
    /// and doesn't have illegal characters for a filename.
    /// - Parameter str: Full string for the project name
    /// - Returns: True if it is valid. False if not.
    static func isProjectNameValid(_ str: String) -> Bool {
        return str.count <= ConfigWrapper.getInt(withKey: "sizeProjectName") && isValidFilename(str)
    }
    
    /// Returns true if the given full string for the scene is valid. Validity means that it is within the size limit
    /// and doesn't have illegal characters for a filename.
    /// - Parameter str: Full string for the scenee
    /// - Returns: True if it is valid. False if not.
    static func isSceneValid(_ str: String) -> Bool {
        return str.count <= ConfigWrapper.getInt(withKey: "sizeScene") && isValidFilename(str)
    }
    
    /// Returns true if the given full string for the take is valid. Validity means that it is within the size limit
    /// and is only numbers.
    /// - Parameter str: Full string for the take
    /// - Returns: True if it is valid. False if not.
    static func isTakeValid(_ str: String) -> Bool {
        return str.count <= ConfigWrapper.getInt(withKey: "sizeTake") && isNumbersOnly(str)
    }
    
    /// Returns true if the given string is a valid filename.
    /// - Parameter str: string to test
    /// - Returns: true if is valid
    static func isValidFilename(_ str: String) -> Bool {
        let r = str.range(of: #"^[\w\-. ]*$"#, options: .regularExpression)
        return r != nil
    }

    /// Returns true if the given string contains only numbers.
    /// - Parameter str: string to test
    /// - Returns: true if is valid
    static func isNumbersOnly(_ str: String) -> Bool {
        let r = str.range(of: #"^[\d]*$"#, options: .regularExpression)
        return r != nil
    }
}
