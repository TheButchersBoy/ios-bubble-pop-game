//
//  BubbleType.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 8/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import Foundation
import UIKit

class BubbleType {
    let points: Int
    let color: String
    
    init(color: String, points: Int) {
        self.points = points
        self.color = color
    }
}
