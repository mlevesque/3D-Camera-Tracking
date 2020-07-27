//
//  PersistentData.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/14/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

/// Enum of all keys for persistent data.
enum DefaultsKey : String {
    case projectName
    case scene
    case take
    case useAudio
}

/// Container for all elements that make up the save name for a recording.
struct NameData {
    let projectName: String
    let scene: String
    let take: Int
}

/// Model for retrieving and saving data that should persist for the app, such as recording naming and settings.
class PersistentData {
    
    // MARK: - Singleton stuff
    
    static let shared = PersistentData()
    private init() {}
    
    // MARK: - Public methods
    
    /// Registers the persistent fields to the UserDefaults.
    func setup() {
        // register Settings fields to UserDefaults
        let preferences = SettingsWrapper.getSettingsData()
        var defaults = [String : Any]()
        for (key, data) in preferences {
            if let val = data.defaultValue {
                defaults[key] = val
            }
        }
        
        // register record name data
        defaults[DefaultsKey.projectName.rawValue] = ConfigWrapper.getString(withKey: "defaultProjectName")
        defaults[DefaultsKey.scene.rawValue] = ConfigWrapper.getString(withKey: "defaultScene")
        defaults[DefaultsKey.take.rawValue] = ConfigWrapper.getInt(withKey: "defaultTake")
        
        UserDefaults.standard.register(defaults: defaults)
        UserDefaults.standard.synchronize()
    }
    
    /// Returns a value from persistence with the given key.
    /// - Parameter key: Enum of key of the value to return
    /// - Returns: The value for the given key
    func getValue<T>(forKey key: DefaultsKey) -> T? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
    
    /// Returns a value as a string from persistence with the given key.
    /// - Parameter key: Enum of key of the value to return
    /// - Returns: The value of the given key as a string. Will be an empty string if the value was nil
    func getString(forKey key: DefaultsKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }
    
    /// Returns a value as an integer from persistence with the given key.
    /// - Parameter key: Enum of key of the value to return
    /// - Returns: The value of the given key as an integer
    func getInt(forKey key: DefaultsKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    /// Returns a value as a boolean from persistence with the given key.
    /// - Parameter key: Enum of key of the value to return
    /// - Returns: The value of the given key as a boolean
    func getBool(forKey key: DefaultsKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    /// Returns a NameData object for the elements used in naming a recording.
    /// - Returns: NameData object
    func getNameData() -> NameData {
        return NameData(
            projectName: getString(forKey: .projectName),
            scene: getString(forKey: .scene),
            take: getInt(forKey: .take))
    }
    
    /// Sets the given value for the given key.
    /// - Parameters:
    ///   - value: The value to set
    ///   - key: The key for the value being set
    func setValue<T>(_ value: T, forKey key: DefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    /// Sets the naming persistence fields with the given NameData object.
    /// - Parameter data: The NameData object containing the values to set
    func setNameData(_ data: NameData) {
        setValue(data.projectName, forKey: .projectName)
        setValue(data.scene, forKey: .scene)
        setValue(data.take, forKey: .take)
    }
    
    /// Saves the persistence data.
    func save() {
        UserDefaults.standard.synchronize()
    }
}
