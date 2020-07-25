//
//  ViewController.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/2/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class MainViewController: UIViewController {
    // positional display UI
    @IBOutlet var positionDisplays: [UILabel]!
    @IBOutlet var rotationDisplays: [UILabel]!
    @IBOutlet var qualityDisplay: UILabel!
    
    // AR View
    @IBOutlet var sceneView: ARSCNView!
    
    // Buttons
    @IBOutlet var recButton: UIButton!
    @IBOutlet var recButtonIcon: UIView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var editNameButton: UIButton!
    @IBOutlet var resetOriginButton: UIButton!
    
    // Text Fields
    @IBOutlet var projectText: UILabel!
    @IBOutlet var sceneText: UILabel!
    @IBOutlet var takeText: UILabel!
    
    private var sceneRecorder: SceneRecorder?
    private var useAudio = false
    private var audioIsSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup scene view
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.session.delegate = self
        
        // set useAudio as false until audio can be set up
        useAudio = false
        let shouldUseAudio = PersistentData.shared.getBool(forKey: .useAudio)
        prepareRecorder(shouldUseAudio: shouldUseAudio)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTextUI()
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // setup listener for persist data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPersistDataChanged),
            name: UserDefaults.didChangeNotification,
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove listeners
        NotificationCenter.default.removeObserver(self)
        
        sceneView.session.pause()
        stopRecording()
    }
    
    /// Triggered when any persistent data has changed. This will update the UI and recorder.
    @objc func onPersistDataChanged() {
        // reinitialize recorder
        prepareRecorder(shouldUseAudio: PersistentData.shared.getBool(forKey: .useAudio))
        
        // update UI
        updateTextUI()
    }
    
    /// Restarts the AR session to reset the world origin.
    func resetOrigin() {
        sceneView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .resetSceneReconstruction])
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    /// Will display a prompt to the user indicating that the current name data will cause a new recording to overwrite
    /// an existing recording file.
    func showFileExistsPromptBeforeRecording() {
        // Initialize Alert Controller
        let title = getConfigString(withKey: "overwriteAlertTitle")
        let description = getConfigString(withKey: "overwriteAlertDescription")
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        // Initialize Actions
        let yesTitle = getConfigString(withKey: "overwriteAlertActionOverwrite")
        let yesAction = UIAlertAction(title: yesTitle, style: .destructive) { (action) -> Void in
            self.startRecording()
        }
        let noTitle = getConfigString(withKey: "overwriteAlertActionCancel")
        let noAction = UIAlertAction(title: noTitle, style: .cancel) { (action) -> Void in
        }
         
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
         
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Starts recording and updates UI
    func startRecording() {
        guard sceneRecorder?.isRecording == false else {
            return
        }
        
        do {
            try sceneRecorder?.startRecording()
        }
        catch {
            // TODO: display error
        }
        
        // update UI
        updateRecordButtonUI()
        settingsButton.isEnabled = false
        editNameButton.isEnabled = false
        resetOriginButton.isEnabled = false
    }
    
    /// Stops recording, increments the take value, and updates UI
    func stopRecording() {
        guard let recorder = sceneRecorder, recorder.isRecording else {
            return
        }
        recorder.stopRecording()
        
        // update UI
        settingsButton.isEnabled = true
        editNameButton.isEnabled = true
        resetOriginButton.isEnabled = true
        
        // increment take - Record button will be updated in the changeNameData call
        let take = PersistentData.shared.getInt(forKey: .take)
        PersistentData.shared.setValue(take + 1, forKey: .take)
    }
    
    /// Initializes a new instance for the recorder using the current name data
    /// - Parameter shouldUseAudio: Whether to setup the recording with audio or not
    private func prepareRecorder(shouldUseAudio: Bool) {
        // stop and previous recording
        sceneRecorder?.stopRecording()

        // determine if audio should be enabled
        if shouldUseAudio && !audioIsSetup {
            setupRecordingForAudio()
        }
        else {
            // create new recorder with new name
            let nameData = PersistentData.shared.getNameData()
            do {
                var sceneDataRecorder: SceneRecorder
                    = try SceneDataRecorder(nameData: nameData)
                if shouldUseAudio {
                    sceneDataRecorder = try SceneAudioRecorderDecorator(sceneRecorder: sceneDataRecorder)
                }
                sceneRecorder = sceneDataRecorder
                
                // update record button
                updateRecordButtonUI()
            }
            catch {
                // TODO: display error
            }
        }
    }
    
    /// Handle asking for permission to use the microphone, then will prepare recording appropriately.
    private func setupRecordingForAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    self.audioIsSetup = true
                    self.prepareRecorder(shouldUseAudio:allowed && PersistentData.shared.getBool(forKey:.useAudio))
                }
            }
        } catch {
            prepareRecorder(shouldUseAudio: false)
        }
    }
    
    /// Updates the look of the record button UI
    private func updateRecordButtonUI() {
        // hide icon
        recButtonIcon.isHidden = true
        
        // update look of record button based on whether or not we are recording
        let isRecording = sceneRecorder?.isRecording ?? false
        
        // display button as stop button if currently recording
        if isRecording {
            let title = getConfigString(withKey: "recordButtonTitleStop")
            recButton.backgroundColor = UIColor.gray
            recButton.setTitle(title, for: UIControl.State.normal)
        }
            
        // display as red record button if not currently recording
        else {
            let title = getConfigString(withKey: "recordButtonTitleRecord")
            recButton.backgroundColor = UIColor.red
            recButton.setTitle(title, for: UIControl.State.normal)
            
            // show caution icon if file exists for current name data
            if sceneRecorder?.doesFileExist() ?? false {
                recButtonIcon.isHidden = false
            }
        }
    }
    
    /// Updates the look of the Text UI
    private func updateTextUI() {
        let d = PersistentData.shared.getNameData()
        projectText.text = d.projectName
        sceneText.text = d.scene
        takeText.text = "\(d.take)"
    }
}

// MARK: AR Scene View Delegate Methods

extension MainViewController : ARSCNViewDelegate {
    /*
        // Override to create and configure nodes for anchors added to the view's session.
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let node = SCNNode()
         
            return node
        }
    */
}

// MARK: AR Session Delegate Methods

extension MainViewController : ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = frame.camera.transform
        let p = vector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        let r = frame.camera.eulerAngles
        
        positionDisplays[0].attributedText = formatPosition(p.x)
        positionDisplays[1].attributedText = formatPosition(p.y)
        positionDisplays[2].attributedText = formatPosition(p.z)
        
        rotationDisplays[0].attributedText = formatRotation(r.x)
        rotationDisplays[1].attributedText = formatRotation(r.y)
        rotationDisplays[2].attributedText = formatRotation(r.z)
        
        qualityDisplay.attributedText = formatQuality(frame.camera.trackingState)
        
        sceneRecorder?.sessionUpdate(session, didUpdate: frame)
    }
}

// MARK: Methods transitioning to and from Main View

extension MainViewController : UIAdaptivePresentationControllerDelegate {
    /// Prepare for segue transition.
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set the presentation delegate to self
        // this lets us capture the event when the new view controller is dismissed by swiping
        segue.destination.presentationController?.delegate = self
    }
    
    /// Triggered when the user dismisses a popover view with a swipe.
    /// - Parameter presentationController:
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        switch presentationController.presentedViewController {
        case let con as EditTextViewController:
            PersistentData.shared.setNameData(con.getNameData())
        default:
            break
        }
    }
    
    /// Triggers when returning to Main View from the Edit Name Data View.
    /// - Parameter unwindSegue:
    @IBAction func unwindFromEdit(_ unwindSegue: UIStoryboardSegue) {
        if let con = unwindSegue.source as? EditTextViewController {
            PersistentData.shared.setNameData(con.getNameData())
        }
    }
    
    /// Triggers when returning to Main View from the Settings View.
    /// - Parameter unwindSegue:
    @IBAction func unwindFromSettings(_ unwindSegue: UIStoryboardSegue) {
    }
}

// MARK: UI Actions

extension MainViewController {
    
    /// Triggered when the Reset Origin button is tapped.
    /// - Parameter sender:
    @IBAction func onResetOriginTouchUp(_ sender: Any) {
        resetOrigin()
    }
    
    /// Triggered when the Record button is tapped.
    /// - Parameter sender:
    @IBAction func onRecordTouchUp(_ sender: Any) {
        guard sceneRecorder != nil else {
            return
        }
        
        // check if file already exists and if so, prompt user
        let recorder = sceneRecorder!
        if (!recorder.isRecording) {
            if sceneRecorder!.doesFileExist() {
                showFileExistsPromptBeforeRecording()
            }
            else {
                startRecording()
            }
        }
        else {
            stopRecording()
        }
    }
}
