//
//  SettingsToggleCell.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/27/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import UIKit

/// Protocol that all Settings Cell View classes should have.
protocol SettingsCell {
    func setData(title: String, key: String, value: Any)
}

/// Table Cell View for Boolean Settings.
class SettingsToggleCell : UITableViewCell, SettingsCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    /// persistence key
    private var m_key = ""
    
    /// Sets the settings data for the cell.
    /// - Parameters:
    ///   - title: Display title of the Settings entry
    ///   - key: Persistence key for the Settings entry
    ///   - value: Current persistence value of the Settings entry
    func setData(title: String, key: String, value: Any) {
        titleLabel.text = title
        m_key = key
        toggle.isOn = value as? Bool ?? false
    }
    
    /// Trigger when the toggle switch value changes. Update the persistence value.
    /// - Parameter sender:
    @IBAction func onToggleChanged(_ sender: Any) {
        if let s = sender as? UISwitch, let key = DefaultsKey(rawValue: m_key) {
            PersistentData.shared.setValue(s.isOn, forKey: key)
        }
    }
}
