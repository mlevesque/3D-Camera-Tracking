//
//  SettingsViewController.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/14/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation
import UIKit

/// View controller for the Settings view, allowing user to set various settings that are also present in the Settings
/// app. This uses the data from the Settings bundle resource to populate the UI.
class SettingsViewController : UITableViewController {
    /// Cached settings hierarchy
    var settingsBySection = SettingsWrapper.getSettingsHierarchy()
    
    /// Returns the number of sections based on the settings data
    /// - Parameter tableView:
    /// - Returns:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsBySection.count
    }

    /// Returns the number of settings entries for the given section.
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsBySection[section].entries.count
    }
    
    /// Returns section titles from the settings data for a given section.
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns: Section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        return settingsBySection[section].title.uppercased()
    }

    /// Returns a table cell for the given index path and based on teh settings data.
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns:
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = settingsBySection[indexPath.section].entries[indexPath.row]
        switch data.type {
        case "PSToggleSwitchSpecifier":
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath)
            if let settingsCell = cell as? SettingsCell, let key = DefaultsKey(rawValue: data.key) {
                settingsCell.setData(title: data.title, key: data.key, value: PersistentData.shared.getBool(forKey:key))
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

