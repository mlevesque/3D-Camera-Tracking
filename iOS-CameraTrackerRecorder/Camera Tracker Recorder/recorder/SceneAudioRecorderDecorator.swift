//
//  SceneAudioRecorderDecorator.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/4/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import Foundation
import AVFoundation
import ARKit

/// Scene Recorder for audio recording. Uses decorator pattern.
class SceneAudioRecorderDecorator : SceneRecorder {
    private let m_sceneRecorder: SceneRecorder
    private var m_audioHandle: AVAudioRecorder?
    
    var isPrepared: Bool { get {return m_sceneRecorder.isPrepared}}
    var isRecording: Bool { get {return m_sceneRecorder.isRecording}}
    var name: String { get {return m_sceneRecorder.name}}
    
    // MARK: Constructor/Destructor
    
    init(sceneRecorder: SceneRecorder) throws {
        self.m_sceneRecorder = sceneRecorder
    }
    
    deinit {
        stopRecording()
    }
    
    // MARK: Public Methods
    
    /// Returns the URL directory for the audio file.
    /// - Returns: URL directory
    func getBasePath() -> URL? {
        return m_sceneRecorder.getBasePath()
    }
    
    /// Returns true if any one of the files for this recorder and all containing recorders already exists.
    /// - Returns: True if file exists. False if not.
    func doesFileExist() -> Bool {
        // if containing recorder file exists, then return true
        if m_sceneRecorder.doesFileExist() {
            return true
        }
        
        // check if audio file exists
        guard let audioFile = getFileURL() else {
            return false
        }
        return FileManager.default.fileExists(atPath: audioFile.path)
    }
    
    /// Prepares recording by creating the audio file.
    /// - Throws: RecorderError if file cannot be created
    func prepareRecording() throws {
        // don't prepare if already prepared
        guard !isPrepared else {
            return
        }
        
        // create audio file
        guard let audioFile = getFileURL() else {
            throw RecorderError.badURL
        }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        do {
            try m_audioHandle = AVAudioRecorder(url: audioFile, settings: settings)
        }
        catch {
            throw RecorderError.cannotCreateFile
        }
        guard let successful = m_audioHandle?.prepareToRecord() else {
            throw RecorderError.cannotCreateFile
        }
        guard successful else {
            throw RecorderError.cannotCreateFile
        }
        
        // prepare other
        try m_sceneRecorder.prepareRecording()
    }
    
    /// Starts the audio recording as well as starting the containing recorder.
    /// - Throws: RecorderError if recording cannot be started
    func startRecording() throws {
        // Do nothing if recording has already started
        guard !isRecording else {
            return
        }
        
        // if not prepared, then prepare it
        if !isPrepared {
            try prepareRecording()
        }
        
        // start recording audio
        guard let successful = m_audioHandle?.record() else {
            throw RecorderError.cannotStartRecording
        }
        guard successful else {
            throw RecorderError.cannotStartRecording
        }
        
        // start recording other
        try m_sceneRecorder.startRecording()
    }
    
    /// AR Session update method. Simply calls the method for the containing recorder since audio recording doesn't need
    /// it.
    /// - Parameters:
    ///   - session: Current AR Session
    ///   - frame: Current AR Frame
    func sessionUpdate(_ session: ARSession, didUpdate frame: ARFrame) {
        m_sceneRecorder.sessionUpdate(session, didUpdate: frame)
    }
    
    /// Stops audio recording and stops containing scene recorder
    func stopRecording() {
        m_audioHandle?.stop()
        m_sceneRecorder.stopRecording()
    }
    
    // MARK: Private Methods
    
    /// Returns the URL for the file location
    /// - Returns: The file location URL
    private func getFileURL() -> URL? {
        return getBasePath()?.appendingPathComponent("\(name).m4a", isDirectory: false)
    }
}
