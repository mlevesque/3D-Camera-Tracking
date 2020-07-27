//
//  TimerButton.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/27/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import UIKit

/// Added ability to add timer value easily to a button.
class TimerButton : UIButton {
    
    /// Sets the title of the button to the given amount of times, in seconds. Title will be formatted.
    /// - Parameter t: time, in seconds
    func setTimer(_ t: Double) {
        let txt = TrackStatusFormatting.time(inSeconds: t)
        setAttributedTitle(txt, for: .normal)
        setAttributedTitle(txt, for: .disabled)
    }
}
