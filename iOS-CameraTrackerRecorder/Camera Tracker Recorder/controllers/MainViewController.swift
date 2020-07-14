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
    
    // Text Fields
    @IBOutlet var projectText: UILabel!
    @IBOutlet var sceneText: UILabel!
    @IBOutlet var takeText: UILabel!
    
    private var sceneRecorder: SceneRecorder?
    private var data: PersistentData = PersistentData()
    private var audioIsSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup scene view
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.session.delegate = self
        
        changeNameData(data.nameData)
        
        // set useAudio as false until audio can be set up
        let useAudio = data.settings.useAudio
        data.settings.useAudio = false
        ToggleAudioRecording(useAudio)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        stopRecording()
    }
    
    /// Prepare for segue transition.
    /// - Parameters:
    ///   - segue:
    ///   - sender: 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if we are seguing to the edit text view, send over the recording text
        switch segue.destination {
        case let con as EditTextViewController:
            con.setNameData(data.nameData)
        default:
            break
        }
        
        // set the presentation delegate to self
        // this lets us capture the event when the new view controller is dismissed by swiping
        segue.destination.presentationController?.delegate = self
    }
    
    /// Changes the name data to the given data. Any recording will stop, a new recorder will be prepared, and UI
    /// will be updated.
    /// - Parameters:
    ///   - nameData
    func changeNameData(_ nameData: NameData) {
        // stop recording in case we are
        stopRecording()
        
        // set updated data
        data.nameData = nameData
        
        // reinitialize recorder
        prepareRecorder()
        
        // update UI
        updateRecordButtonUI()
        updateTextUI()
    }
    
    /// Toggles audio recording. If toggled on for the first time since the app started, then will set up audio and
    /// get permission if needed
    /// - Parameter value: useAudio flag
    func ToggleAudioRecording(_ value: Bool) {
        // if enabled, setup for audio recording
        if value && !audioIsSetup {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
                audioSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        self.audioIsSetup = true
                        self.ToggleAudioRecording(allowed)
                    }
                }
            } catch {
                ToggleAudioRecording(false)
            }
        }
        else {
            data.settings.useAudio = value
            prepareRecorder()
        }
    }
    
    /// Restarts the AR session to reset the world origin.
    func resetOrigin() {
        sceneView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .resetSceneReconstruction])
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    /// Starts recording and updates UI
    func startRecording() {
        guard sceneRecorder?.isRecording == false else {
            return
        }
        
        do {
            // TODO: Check if file exists
            try sceneRecorder?.startRecording()
        }
        catch {
            // TODO: display error
        }
        
        // update UI
        updateRecordButtonUI()
    }
    
    /// Stops recording, increments the take value, and updates UI
    func stopRecording() {
        guard let recorder = sceneRecorder, recorder.isRecording else {
            return
        }
        recorder.stopRecording()
        
        // increment take - Record button will be updated in the changeNameData call
        let d = data.nameData
        changeNameData(NameData(projectName: d.projectName, scene: d.scene, take: Int(d.take) + 1))
    }
    
    /// Initializes a new instance for the recorder using the current name data
    private func prepareRecorder() {
        // stop and previous recording
        sceneRecorder?.stopRecording()
        
        // create new recorder with new name
        do {
            var sceneDataRecorder: SceneRecorder
                = try SceneDataRecorder(nameData: data.nameData)
            if data.settings.useAudio {
                sceneDataRecorder = try SceneAudioRecorderDecorator(sceneRecorder: sceneDataRecorder)
            }
            sceneRecorder = sceneDataRecorder
        }
        catch {
            // TODO: display error
        }
    }
    
    /// Updates the look of the record button UI
    private func updateRecordButtonUI() {
        // update look of record button based on whether or not we are recording
        let isRecording = sceneRecorder?.isRecording ?? false
        
        // display button as stop button if currently recording
        if isRecording {
            recButton.backgroundColor = UIColor.gray
            recButton.setTitle("Stop", for: UIControl.State.normal)
        }
            
        // display as red record button if not currently recording
        else {
            recButton.backgroundColor = UIColor.red
            recButton.setTitle("Record", for: UIControl.State.normal)
        }
    }
    
    /// Updates the look of the Text UI
    private func updateTextUI() {
        let d = data.nameData
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

// MARK: Adaptive Presentation Controller Delegate Methods

extension MainViewController : UIAdaptivePresentationControllerDelegate {
    
    /// Triggered when the user dismisses a popover view with a swipe.
    /// - Parameter presentationController:
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        switch presentationController.presentedViewController {
        case let con as EditTextViewController:
            changeNameData(con.getNameData())
        default:
            break
        }
    }
}

// MARK: UI Actions

extension MainViewController {
    @IBAction func onResetOriginTouchUp(_ sender: Any) {
        resetOrigin()
    }
    
    @IBAction func onRecordTouchUp(_ sender: Any) {
        guard sceneRecorder != nil else {
            return
        }
        
        let recorder = sceneRecorder!
        if (!recorder.isRecording) {
            startRecording()
        }
        else {
            stopRecording()
        }
    }
    
    @IBAction func unwindFromEdit(_ unwindSegue: UIStoryboardSegue) {
        if let con = unwindSegue.source as? EditTextViewController {
            changeNameData(con.getNameData())
        }
    }
    
    @IBAction func unwindFromSettings(_ unwindSegue: UIStoryboardSegue) {
    }
}
