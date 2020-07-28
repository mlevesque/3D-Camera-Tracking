//
//  RecordButtonViewController.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/26/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import UIKit

/// Deletage for record button view controller. Allows parent view to detect when the record button is pressed.
protocol RecordButtonActionDelegate : class {
    func onRecordPressed() // optional
}
extension RecordButtonActionDelegate {
    func onRecordPressed() {}
}

/// View controller for the functionality of the record button and its appearance.
class RecordButtonViewController : UIViewController {
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cautionIcon: UIView!
    
    weak var delegate: RecordButtonActionDelegate?
    
    /// Reference to the status of the current recorder
    private weak var m_recorderStatus: SceneRecorderStatus?
    
    /// Clean up observer when destroyed.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Update UI when loaded.
    override func viewWillAppear(_ animated: Bool) {
        update()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    /// Triggered when app enters foreground. This updates the record button, specifically the file exists status in
    /// case the user deleted the file while the app was in the background.
    @objc func onEnterForeground() {
        update()
    }
    
    /// Sets the recorder static to
    /// - Parameter status: current recorder status
    func setRecorder(withSceneRecorderStatus status: SceneRecorderStatus?) {
        m_recorderStatus = status
        update()
    }
    
    /// Updates the look of the recrd button based on the recorder status
    func update() {
        // hide icon
        cautionIcon.isHidden = true

        // display mic icon based on if if useAudio is set
        let micIcon = m_recorderStatus?.willRecordAudio() ?? false
            ? UIImage(named: "icon_mic") : UIImage(named: "icon_nomic")
        recordButton.setImage(micIcon, for: .normal)
        recordButton.imageView?.contentMode = .scaleAspectFit
        recordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)

        // update look of record button based on whether or not we are recording
        let isRecording = m_recorderStatus?.isRecording ?? false

        // display button as stop button if currently recording
        if isRecording {
            let title = ConfigWrapper.getString(withKey: ConfigKeys.recordButtonTitleStop)
            recordButton.backgroundColor = UIColor.gray
            recordButton.setTitle(title, for: UIControl.State.normal)
        }

        // display as red record button if not currently recording
        else {
            let title = ConfigWrapper.getString(withKey: ConfigKeys.recordButtonTitleRecord)
            recordButton.backgroundColor = UIColor.red
            recordButton.setTitle(title, for: UIControl.State.normal)

            // show caution icon if file exists for current name data
            if m_recorderStatus?.doesFileExist() ?? false {
                cautionIcon.isHidden = false
            }
        }
    }
    
    /// Will display a prompt to the user indicating that the current name data will cause a new recording to overwrite
    /// an existing recording file.
    func showFileExistsPromptBeforeRecording() {
        // Initialize Alert Controller
        let title = ConfigWrapper.getString(withKey: ConfigKeys.overwriteAlertTitle)
        let description = ConfigWrapper.getString(withKey: ConfigKeys.overwriteAlertDescription)
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        // Initialize Actions
        let yesTitle = ConfigWrapper.getString(withKey: ConfigKeys.overwriteAlertActionOverwrite)
        let yesAction = UIAlertAction(title: yesTitle, style: .destructive) { (action) -> Void in
            self.delegate?.onRecordPressed()
        }
        let noTitle = ConfigWrapper.getString(withKey: ConfigKeys.overwriteAlertActionCancel)
        let noAction = UIAlertAction(title: noTitle, style: .cancel) { (action) -> Void in
        }
         
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
         
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Action for when the record button is tapped. This will trigger the onRecordPressed method in the delegate to
    /// signal that recording should start/stop
    /// - Parameter sender:
    @IBAction func onRecordTouched(_ sender: Any) {
        // do nothing if there is no recorder
        guard m_recorderStatus != nil else {
            return
        }
        
        // update UI
        update()
        
        // check if file already exists and if so, prompt user
        let recorder = m_recorderStatus!
        if !recorder.isRecording && recorder.doesFileExist() {
            showFileExistsPromptBeforeRecording()
        }
        else {
            delegate?.onRecordPressed()
        }
    }
}
