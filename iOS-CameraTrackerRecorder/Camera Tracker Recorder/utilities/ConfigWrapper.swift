//
//  ValueLookup.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/14/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

/// Wrapper class for accessing data from the Config.plist resource file.
class ConfigWrapper {
    /// Cached config dictionary
    static var dictionary: NSDictionary? = nil
    
    /// Returns a string from the config plist for the given key.
    /// - Parameter key: Key defined in the config plist file
    /// - Returns: String value from the given key. If invalid, will return "#####"
    static func getString(withKey key: String) -> String {
        return getValue(withKey: key) as? String ?? "#####"
    }
    
    /// Returns a boolean value from the config plist for the given key.
    /// - Parameter key: Key defined in the config plist file
    /// - Returns: Boolean value from the given key. If invalid, will return false
    static func getBool(withKey key: String) -> Bool {
        return getValue(withKey: key) as? Bool ?? false
    }
    
    /// Returns an integer value from the config plist for the given key.
    /// - Parameter key: Key defined in the config plist file
    /// - Returns: Integer value from the given key. If invalid, will return 0
    static func getInt(withKey key: String) -> Int {
        return getValue(withKey: key) as? Int ?? 0
    }
    
    /// Returns a value from the config plist for the given key.
    /// - Parameter key: Key defined in the config plist file
    /// - Returns: Any optional value from the given key. Returns nil if key does not exist
    static func getValue(withKey key: String) -> Any? {
        if dictionary == nil {
            if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
                if let dict = NSDictionary(contentsOfFile: path) {
                    dictionary = dict
                }
            }
        }
        return dictionary?[key]
    }
}
