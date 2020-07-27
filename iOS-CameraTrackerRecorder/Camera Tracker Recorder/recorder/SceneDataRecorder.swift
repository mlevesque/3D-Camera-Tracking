//
//  SceneDataRecorder.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/4/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import Foundation
import ARKit
import simd

final class SceneDataRecorder : SceneRecorder {
    private let m_name: String
    private var m_prepared: Bool
    private var m_recording: Bool
    private var m_jsonWriter: JsonStreamWriter?
    private var m_startTimestamp: Double?
    private var m_previousTimestamp: Double?
    private var m_frameCount: Int
    
    var isPrepared: Bool { get { return m_prepared } }
    var isRecording: Bool { get { return m_recording } }
    var name: String { get { return m_name } }
    var elapsedTime: Double {
        get {
            if let start = m_startTimestamp, let current = m_previousTimestamp {
                return current - start
            }
            return 0.0
        }
    }
    
    // MARK: Static Methods
    
    static private func buildFileName(nameData: NameData) -> String {
        return "\(nameData.projectName)-\(nameData.scene)-\(nameData.take)"
    }
    
    // MARK: Constructor/Destructor
    
    init(nameData: NameData) throws {
        m_name = SceneDataRecorder.buildFileName(nameData: nameData)
        m_prepared = false
        m_recording = false
        m_frameCount = 0
    }
    
    deinit {
        stopRecording()
    }
    
    // MARK: Public Methods
    
    /// Returns the base URL directory for where the file will be written to.
    /// - Returns: Directory URL
    func getBasePath() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// Returns true if the file already exists.
    /// - Returns: True if it exists. False if not.
    func doesFileExist() -> Bool {
        guard let txtFile = getFileURL() else {
            return false
        }
        return FileManager.default.fileExists(atPath: txtFile.path)
    }
    
    /// Returns false as this does not record audio.
    /// - Returns: False
    func willRecordAudio() -> Bool {
        return false
    }
    
    /// Prepares for recording by creating the file
    /// - Throws: RecorderError if file location is bad or file could not be created
    func prepareRecording() throws {
        // don't prepare if already prepared
        guard !isPrepared else {
            return
        }
        
        // grab file location
        guard let txtFile = getFileURL() else {
            throw RecorderError.badURL
        }
        
        // create text file
        guard FileManager.default.createFile(atPath: txtFile.path, contents: nil, attributes: nil) else {
            throw RecorderError.cannotCreateFile
        }
        
        // mark flag
        m_prepared = true
    }
    
    /// Starts the recording and sets up the stream writer.
    /// - Throws: RecorderError exception if the stream writer could not be created for could not be written to
    func startRecording() throws {
        // Do nothing if recording has already started
        guard !isRecording else {
            return
        }
        
        // if not prepared, then prepare it
        if !isPrepared {
            try prepareRecording()
        }
        
        // get file location for data file
        guard let jsonFileURL = getFileURL() else {
            throw RecorderError.badURL
        }
        
        // attempt to set up file handle for writing
        var successful: Bool
        do {
            try m_jsonWriter = JsonStreamWriter(url: jsonFileURL)
            successful = m_jsonWriter?.addKey("data") ?? false
            successful = successful && (m_jsonWriter?.startArray() ?? false)
        }
        catch {
            successful = false
        }
        if !successful {
            throw RecorderError.cannotStartRecording
        }
        
        m_frameCount = 0
        
        // mark flag
        m_recording = true;
    }
    
    /// AR Session Update. Will add a tracking entry to the Json file if recording is happening.
    /// - Parameters:
    ///   - session: Current AR Session
    ///   - frame: Current AR Frame
    func sessionUpdate(_ session: ARSession, didUpdate frame: ARFrame) {
        if m_recording {
            let frameData = buildFrameData(frame: frame)
            _ = m_jsonWriter?.addValue(frameData, newLineEntry: true, newLinesInParsedObject: false)
            m_frameCount += 1
        }
    }
    
    /// Ends recording and closes the file
    func stopRecording() {
        m_jsonWriter?.closeFile()
        m_recording = false
    }
    
    // MARK: Private Methods
    
    /// Returns the URL for the file location
    /// - Returns: The file location URL
    private func getFileURL() -> URL? {
        return getBasePath()?.appendingPathComponent("\(name).json", isDirectory: false)
    }
    
    /// Returns frame data to be added to the file from the given AR Frame.
    /// - Parameter frame: AR Frame containing tracking data
    /// - Returns: Json entry of the frame tracking data
    private func buildFrameData(frame: ARFrame) -> DataEntryJsonSchema {
        // get camera transform for position and rotation data
        let transform = frame.camera.transform
        let quat = simd_quaternion(transform)
        let quatVec = quat.vector
        
        // calculate frame time
        var diff: Double = 0
        if let prev = m_previousTimestamp {
            diff = frame.timestamp - prev
        }
        else {
            m_startTimestamp = frame.timestamp
        }
        m_previousTimestamp = frame.timestamp
        
        // build object
        return DataEntryJsonSchema(
            t: diff,
            px: transform.columns.3.x,
            py: transform.columns.3.y,
            pz: transform.columns.3.z,
            qx: quatVec.x,
            qy: quatVec.y,
            qz: quatVec.z,
            qw: quatVec.w
        )
    }
}
