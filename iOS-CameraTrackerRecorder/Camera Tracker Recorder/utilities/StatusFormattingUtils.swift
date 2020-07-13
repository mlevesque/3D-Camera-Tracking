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

fileprivate let posNumAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
fileprivate let posUnitAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10)]
fileprivate let rotNumAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
fileprivate let rotUnitAtt: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
fileprivate let qualityGoodAtt: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14),
                                                                 .foregroundColor: UIColor.green]
fileprivate let qualityCautionAtt: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14),
                                                                    .foregroundColor: UIColor.yellow]
fileprivate let qualityBadAtt: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14),
                                                                .foregroundColor: UIColor.red]

func formatPosition(_ value: Float) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(NSAttributedString(string: String(format: "%.2f", value), attributes: posNumAtt))
    result.append(NSAttributedString(string: "m", attributes: posUnitAtt))
    return result
}

func formatRotation(_ value: Float) -> NSAttributedString {
    let val = Int(round((180.0 / .pi) * value))
    let result = NSMutableAttributedString()
    result.append(NSAttributedString(string: "\(val)", attributes: rotNumAtt))
    result.append(NSAttributedString(string: "°", attributes: rotUnitAtt))
    return result
}

func formatQuality(_ trackingState: ARCamera.TrackingState) -> NSAttributedString {
    switch trackingState {
        case .normal:
            return NSAttributedString(string: "Good", attributes: qualityGoodAtt)
        case .limited(.excessiveMotion):
            return NSAttributedString(string: "Excessive Motion", attributes: qualityCautionAtt)
        case .limited(.initializing):
            return NSAttributedString(string: "Initializing", attributes: qualityCautionAtt)
        case .limited(.insufficientFeatures):
            return NSAttributedString(string: "Not Enough Features", attributes: qualityCautionAtt)
        case .limited(.relocalizing):
            return NSAttributedString(string: "Relocalizing", attributes: qualityCautionAtt)
        case .limited(_):
            return NSAttributedString(string: "Limited", attributes: qualityCautionAtt)
        case .notAvailable:
            return NSAttributedString(string: "Not Available", attributes: qualityBadAtt)
    }
}
