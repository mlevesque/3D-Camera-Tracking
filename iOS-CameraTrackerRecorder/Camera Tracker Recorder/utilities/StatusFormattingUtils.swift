//
//  utils.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 4/18/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation
import UIKit
import ARKit

// text attributes
fileprivate let posNumAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
fileprivate let posUnitAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10)]
fileprivate let rotNumAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
fileprivate let rotUnitAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
fileprivate let qualityGoodAtt: [NSAttributedString.Key: Any]
    = [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(named: "status_green") ?? UIColor.green]
fileprivate let qualityCautionAtt: [NSAttributedString.Key: Any]
    = [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(named: "status_yellow") ?? UIColor.yellow]
fileprivate let qualityBadAtt: [NSAttributedString.Key: Any]
    = [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(named: "status_red") ?? UIColor.red]

/// Returns formatted text for the given position value.
/// - Parameter value: position value
/// - Returns: formatted text for the position
func formatPosition(_ value: Float) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(NSAttributedString(string: String(format: "%.2f", value), attributes: posNumAtt))
    result.append(NSAttributedString(string: "m", attributes: posUnitAtt))
    return result
}

/// Returns formatted text for the given rotation value.
/// - Parameter value: rotation value
/// - Returns: formatted text for the rotation
func formatRotation(_ value: Float) -> NSAttributedString {
    let val = Int(round((180.0 / .pi) * value))
    let result = NSMutableAttributedString()
    result.append(NSAttributedString(string: "\(val)", attributes: rotNumAtt))
    result.append(NSAttributedString(string: "°", attributes: rotUnitAtt))
    return result
}

/// Returns formatted text for the given tracking state status.
/// - Parameter trackingState: tracking state status
/// - Returns: formatted text for the tracking status
func formatQuality(_ trackingState: ARCamera.TrackingState) -> NSAttributedString {
    switch trackingState {
        case .normal:
            let text = ConfigWrapper.getString(withKey: "trackStatusGood")
            return NSAttributedString(string: text, attributes: qualityGoodAtt)
        case .limited(.excessiveMotion):
            let text = ConfigWrapper.getString(withKey: "trackStatusExcessiveMotion")
            return NSAttributedString(string: text, attributes: qualityCautionAtt)
        case .limited(.initializing):
            let text = ConfigWrapper.getString(withKey: "trackStatusInitializing")
            return NSAttributedString(string: text, attributes: qualityCautionAtt)
        case .limited(.insufficientFeatures):
            let text = ConfigWrapper.getString(withKey: "trackStatusNotEnoughFeatures")
            return NSAttributedString(string: text, attributes: qualityCautionAtt)
        case .limited(.relocalizing):
            let text = ConfigWrapper.getString(withKey: "trackStatusRelocalizing")
            return NSAttributedString(string: text, attributes: qualityCautionAtt)
        case .limited(_):
            let text = ConfigWrapper.getString(withKey: "trackStatusLimited")
            return NSAttributedString(string: text, attributes: qualityCautionAtt)
        case .notAvailable:
            let text = ConfigWrapper.getString(withKey: "trackStatusNotAvailable")
            return NSAttributedString(string: text, attributes: qualityBadAtt)
    }
}
