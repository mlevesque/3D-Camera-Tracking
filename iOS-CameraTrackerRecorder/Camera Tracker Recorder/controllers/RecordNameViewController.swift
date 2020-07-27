//
//  RecordNameViewController.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/26/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import UIKit

/// View Controller for the Record Name Panel
class RecordNameViewController : UIViewController {
    @IBOutlet var projectNameLabel: UILabel!
    @IBOutlet var sceneLabel: UILabel!
    @IBOutlet var takeLabel: UILabel!
    @IBOutlet var editButton: UIButton!
    
    /// Sets the enabled flag on the edit button.
    var isEnabled: Bool {
        get { return editButton.isEnabled }
        set(value) { editButton.isEnabled = value }
    }
    
    /// Updates the UI with the given name data.
    /// - Parameter nameData:
    func update(nameData: NameData) {
        projectNameLabel.text = nameData.projectName
        sceneLabel.text = nameData.scene
        takeLabel.text = "\(nameData.take)"
    }
}
