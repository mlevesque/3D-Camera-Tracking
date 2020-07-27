//
//  TrackStatusViewController.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/26/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import UIKit
import simd
import ARKit

/// View Controller for the panel on the main view that displays tracking data.
class TrackStatusViewController : UIViewController {
    @IBOutlet var pxLabel: UILabel!
    @IBOutlet var pyLabel: UILabel!
    @IBOutlet var pzLabel: UILabel!
    @IBOutlet var rxLabel: UILabel!
    @IBOutlet var ryLabel: UILabel!
    @IBOutlet var rzLabel: UILabel!
    @IBOutlet var qualityLabel: UILabel!
    
    var inMeters: Bool = true
    
    /// Upon load, initialize the text fields with a "non value".
    override func viewDidLoad() {
        // initialize labels with non-values
        let value = "-"
        pxLabel.text = value
        pyLabel.text = value
        pzLabel.text = value
        rxLabel.text = value
        ryLabel.text = value
        rzLabel.text = value
        qualityLabel.text = value
    }
    
    /// Updates the UI with the given tracking data. Will format the data for the UI and display it.
    /// - Parameters:
    ///   - position: tracking position
    ///   - rotation: tracking rotation
    ///   - quality: tracking quality
    func updateTrackingData(position: simd_float3, rotation: simd_float3, quality: ARCamera.TrackingState) {
        let units: Units = inMeters ? .meters : .feet
        let px = inMeters ? position.x : convertMetersToFeet(meters: position.x)
        let py = inMeters ? position.y : convertMetersToFeet(meters: position.y)
        let pz = inMeters ? position.z : convertMetersToFeet(meters: position.z)
        pxLabel.attributedText = TrackStatusFormatting.position(px, inUnits: units)
        pyLabel.attributedText = TrackStatusFormatting.position(py, inUnits: units)
        pzLabel.attributedText = TrackStatusFormatting.position(pz, inUnits: units)
        
        rxLabel.attributedText = TrackStatusFormatting.rotation(rotation.x)
        ryLabel.attributedText = TrackStatusFormatting.rotation(rotation.y)
        rzLabel.attributedText = TrackStatusFormatting.rotation(rotation.z)
        
        qualityLabel.attributedText = TrackStatusFormatting.quality(quality)
    }
}
