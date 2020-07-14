//
//  JsonSchemas.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/13/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import Foundation

/// Top level Json Schema.
struct TrackingDataJsonSchema: Codable {
    let data: [DataEntryJsonSchema]
}

/// Recording name values.
struct RecordingNameJsonSchema: Codable {
    let projectName: String
    let scene: String
    let take: Int
}

/// Json schema for a single tracking entry.
struct DataEntryJsonSchema: Codable {
    let t: Double               // time slice
    let px, py, pz: Float       // position
    let qx, qy, qz, qw: Float   // rotation (as quaternion)
}
