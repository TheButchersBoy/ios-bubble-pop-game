//
//  Settings.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 12/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import Foundation

// Struct for game settings
struct Settings: Codable {
    var playTime: Int = 60
    var maxBubbles: Int = 15
}
