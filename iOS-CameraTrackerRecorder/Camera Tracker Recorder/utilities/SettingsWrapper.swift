//
//  SettingsWrapper.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/27/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

typealias SettingsEntry = (key: String, title: String, type: String, defaultValue: Any?)
typealias SettingsSection = (title: String, entries: [SettingsEntry])

/// Wrapper for accessing Settings resource data.
class SettingsWrapper {
    private init() {}
    
    static let key = "Key"
    static let title = "Title"
    static let type = "Type"
    static let defaultValue = "DefaultValue"
    
    static let typeGroup = "PSGroupSpecifier"
    
    /// Returns dictionary of Settings data entries.
    /// - Returns:
    static func getSettingsData() -> [SettingsEntry] {
        // get settings fields
        let preferences = getPrefs()
        var results = [SettingsEntry]()
        for pref in preferences {
            if let key = pref[key] as? String {
                results.append((
                    key: key,
                    title: pref[title] as? String ?? "",
                    type: pref[type] as? String ?? "",
                    defaultValue: pref[defaultValue]))
            }
        }
        return results
    }
    
    /// Returns an array of sections of settings entries defined by groups in the Settings bundle
    /// - Returns: Array of SettingsSections
    static func getSettingsHierarchy() -> [SettingsSection] {
        let preferences = getPrefs()
        var results = [SettingsSection]()
        var section: SettingsSection?
        for pref in preferences {
            
            // handle group as a new section
            if let t = pref[type] as? String, t == typeGroup {
                if let s = section {
                    results.append(s)
                }
                section = SettingsSection(title: pref[title] as? String ?? "", entries: [])
            }
            else {
                // if section is nil here, then the list of settings is starting outside a group
                if section == nil {
                    section = SettingsSection(title: "", entries: [])
                }
            
                // handle all other settings
                if let key = pref[key] as? String {
                    section?.entries.append((
                    key: key,
                    title: pref[title] as? String ?? "",
                    type: pref[type] as? String ?? "",
                    defaultValue: pref[defaultValue]))
                }
            }
        }
        
        // add last section
        if let s = section, !s.entries.isEmpty {
            results.append(s)
        }
        
        return results
    }
    
    /// Helper method to get a list of settings preferences.
    /// - Returns: Array of Dictionaries of each Settings entry
    static private func getPrefs() -> [[String : AnyObject]] {
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension: "bundle"),
              let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")),
              let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String : AnyObject]] else {
                return []
        }
        return preferences
    }
}
