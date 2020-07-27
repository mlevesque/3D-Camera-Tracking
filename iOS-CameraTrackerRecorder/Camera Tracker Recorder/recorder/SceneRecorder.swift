//
//  SceneRecorder.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/30/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import ARKit

enum RecorderError: Error {
    case badURL
    case badName
    case cannotCreateFile
    case cannotStartRecording
}

protocol SceneRecorderStatus : class {
    var isPrepared: Bool { get }
    var isRecording: Bool { get }
    var name: String { get }
    var elapsedTime: Double { get }
    func getBasePath() -> URL?
    func doesFileExist() -> Bool
    func willRecordAudio() -> Bool
}

protocol SceneRecorder : SceneRecorderStatus {
    func prepareRecording() throws
    func startRecording() throws
    func sessionUpdate(_ session: ARSession, didUpdate frame: ARFrame)
    func stopRecording()
}
