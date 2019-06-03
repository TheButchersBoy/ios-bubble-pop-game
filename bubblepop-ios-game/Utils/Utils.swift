//
//  Utils.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 9/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import Foundation

class Utils{
    // Format the number into time
    static func formatTime(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}
