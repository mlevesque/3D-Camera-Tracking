//
//  SettingsWrapper.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/27/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

typealias SettingsEntry = (title: String, type: String, defaultValue: Any?)

/// Wrapper for accessing Settings resource data.
class SettingsWrapper {
    private init() {}
    
    /// Returns dictionary of Settings data entries.
    /// - Returns:
    static func getSettingsData() -> [String : SettingsEntry] {
        // get settings fields
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension: "bundle"),
              let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")),
              let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String : AnyObject]] else {
                return [:]
        }
        var results = [String : SettingsEntry]()
        for pref in preferences {
            if let key = pref["Key"] as? String {
                results[key] = (
                    title: pref["Title"] as? String ?? "",
                    type: pref["Type"] as? String ?? "",
                    defaultValue: pref["DefaultValue"])
            }
        }
        return results
    }
}
