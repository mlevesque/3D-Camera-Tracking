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
    
    @IBOutlet var positionDisplays: [UILabel]!
    @IBOutlet var rotationDisplays: [UILabel]!
    @IBOutlet var qualityDisplay: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var recButton: UIButton!
    
    @IBOutlet var projectText: UILabel!
    @IBOutlet var sceneText: UILabel!
    @IBOutlet var takeText: UILabel!
    
    static let notificationName = Notification.Name("MainViewController")
    
    private var sceneRecorder: SceneRecorder?
    private var useAudio: Bool = false
    
    private var projectName: String = "Project Name"
    private var sceneValue: String = "123A"
    private var takeValue: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup notifications
        NotificationCenter.default.addObserver(self,
            selector: #selector(onUpdateTextNotification(notification:)),
            name: MainViewController.notificationName,
            object: nil)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show tracking points
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene
        
        // Update Text UI
        updateText()
        
        // set delegate to update UI every frame
        sceneView.session.delegate = self
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    self.useAudio = allowed
                    self.prepareRecorder()
                }
            }
        } catch {
            useAudio = false
            prepareRecorder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        // stop recording
        sceneRecorder?.stopRecording()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // transfer text data to Edit Text view
        if segue.destination is EditTextViewController {
            if let vc = segue.destination as? EditTextViewController {
                vc.setText(project: projectName, scene: sceneValue, take: "\(takeValue)")
            }
        }
    }
    
    
    
    
    
    private func incrementTake() {
        // increment value
        takeValue = takeValue + 1
        
        // setup new recorder
        prepareRecorder()
        
        // update UI
        updateText()
    }
    
    private func prepareRecorder() {
        // stop and previous recording
        sceneRecorder?.stopRecording()
        
        // create new recorder with new name
        do {
            var sceneDataRecorder: SceneRecorder
                = try SceneDataRecorder(projectName: projectName, scene: sceneValue, take: takeValue)
            if useAudio {
                sceneDataRecorder = try SceneAudioRecorderDecorator(sceneRecorder: sceneDataRecorder)
            }
            sceneRecorder = sceneDataRecorder
        }
        catch {
            // TODO: display error
        }
        
        // TODO: Handle if file already exists with new name
    }
    
    private func getRecorderName() -> String {
        return "\(projectName)-\(sceneValue)-\(takeValue)"
    }
    
    private func updateRecordButton() {
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
    
    private func updateText() {
        projectText.text = projectName
        sceneText.text = sceneValue
        takeText.text = "\(takeValue)"
    }
    
    @objc private func onUpdateTextNotification(notification: Notification) {
        // set new values
        if let project = notification.userInfo?[TextKeys.ProjectName] as? String {
            projectName = project
        }
        if let scene = notification.userInfo?[TextKeys.SceneValue] as? String {
            sceneValue = scene
        }
        if let take = notification.userInfo?[TextKeys.TakeValue] as? String {
            takeValue = Int(take) ?? takeValue
        }
        
        // setup recorder with the new name
        prepareRecorder()
        
        // update the UI
        updateText()
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

// MARK: UI Actions

extension MainViewController {
    @IBAction func onResetOriginTouchUp(_ sender: Any) {
        sceneView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .resetSceneReconstruction])
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    @IBAction func onRecordTouchUp(_ sender: Any) {
        let isRecording = sceneRecorder?.isRecording ?? false
        
        do {
            if isRecording {
                // stop recording and save data
                sceneRecorder?.stopRecording()
                
                // prepare for next take
                incrementTake()
            }
            else {
                // @TODO Add warning if overwriting file
                try sceneRecorder?.startRecording()
            }
        }
        catch {
            // @TODO display error
        }
        
        // update UI
        updateRecordButton()
    }
}
