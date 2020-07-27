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
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var resetOriginButton: UIButton!
    @IBOutlet var timer: TimerButton!
    
    // Child controllers
    private var trackStatusController: TrackStatusViewController?
    private var recordButtonController: RecordButtonViewController?
    private var recordNameController: RecordNameViewController?
    
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
        
        // update UI
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // start AR session
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
        // update UI
        updateUI()
        
        // reinitialize recorder
        prepareRecorder(shouldUseAudio: PersistentData.shared.getBool(forKey: .useAudio))
    }
    
    /// Updates the UI elements with the latest Persistence data.
    func updateUI() {
        trackStatusController?.inMeters = PersistentData.shared.getBool(forKey: .useMetricSystem)
        recordNameController?.update(nameData: PersistentData.shared.getNameData())
        
        if sceneRecorder == nil || sceneRecorder!.isRecording == false {
            timer.setTimer(PersistentData.shared.getDouble(forKey: .previousRecordingTime))
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
            try sceneRecorder?.startRecording()
        }
        catch {
            // TODO: display error
            print("Something went wrong")
        }
        
        // update UI
        recordButtonController?.update()
        settingsButton.isEnabled = false
        recordNameController?.isEnabled = false
        resetOriginButton.isEnabled = false
        timer.isEnabled = false
    }
    
    /// Stops recording, increments the take value, and updates UI
    func stopRecording() {
        guard let recorder = sceneRecorder, recorder.isRecording else {
            return
        }
        recorder.stopRecording()
        
        // update UI
        settingsButton.isEnabled = true
        recordNameController?.isEnabled = true
        resetOriginButton.isEnabled = true
        
        // save last record time
        timer.isEnabled = true
        PersistentData.shared.setValue(recorder.elapsedTime, forKey: .previousRecordingTime)
        
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
            useAudio = shouldUseAudio
            
            // create new recorder with new name
            let nameData = PersistentData.shared.getNameData()
            do {
                var sceneDataRecorder: SceneRecorder
                    = try SceneDataRecorder(nameData: nameData)
                if useAudio {
                    sceneDataRecorder = try SceneAudioRecorderDecorator(sceneRecorder: sceneDataRecorder)
                }
                sceneRecorder = sceneDataRecorder
                
                // update record button
                recordButtonController?.setRecorder(withSceneRecorderStatus: sceneRecorder)
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
        
        trackStatusController?.updateTrackingData(position: p, rotation: r, quality: frame.camera.trackingState)
        sceneRecorder?.sessionUpdate(session, didUpdate: frame)
        
        // update timer
        if sceneRecorder?.isRecording ?? false {
            timer.setTimer(sceneRecorder?.elapsedTime ?? 0.0)
        }
    }
}

// MARK: Methods for Record Button Delegate

extension MainViewController : RecordButtonActionDelegate {
    /// Triggered when the record button is tapped. Toggle recording.
    func onRecordPressed() {
        guard sceneRecorder != nil else {
            return
        }
        
        if sceneRecorder!.isRecording {
            stopRecording()
        }
        else {
            startRecording()
        }
    }
}

// MARK: Methods transitioning to and from Main View

extension MainViewController : UIAdaptivePresentationControllerDelegate {
    /// Prepare for segue transition.
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // handle embed segue controller referencing
        switch segue.identifier {
        case "embedTrackStatus":
            trackStatusController = segue.destination as? TrackStatusViewController
        case "embedRecord":
            recordButtonController = segue.destination as? RecordButtonViewController
            recordButtonController?.delegate = self
        case "embedRecordName":
            recordNameController = segue.destination as? RecordNameViewController
        default:
            break
        }
        
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
    
    /// Triggered when the timer is tapped. Will reset the timer, but only when there is no recording.
    /// - Parameter sender: 
    @IBAction func onTimerTouchUp(_ sender: Any) {
        if sceneRecorder == nil || sceneRecorder!.isRecording == false {
            PersistentData.shared.setValue(0.0, forKey: .previousRecordingTime)
        }
    }
}
