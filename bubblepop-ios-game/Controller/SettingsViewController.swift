//
//  SettingsViewController.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 6/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var maxBubblesLabel: UILabel!
    @IBOutlet weak var maxBubblesSlider: UISlider!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var gameTimeSlider: UISlider!
    
    // Variables
    let storage = Storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var settings: Settings
        do {
            // Load stored settings
            settings = try storage.loadSettings()
        } catch {
            // Use default settings
            settings = Settings()
        }
        maxBubblesSlider.value = Float(settings.maxBubbles)
        gameTimeSlider.value = Float(settings.playTime)
        // Update slider values
        gameTimeSliderChanged(self)
        maxBubblesSliderChanged(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Save settings
        let settings = Settings(playTime: Int(gameTimeSlider.value), maxBubbles: Int(maxBubblesLabel.text!)!)
        do {
            try storage.saveData(settings: settings)
        } catch {
            print("Cannot save setting data")
        }
    }
    
    @IBAction func maxBubblesSliderChanged(_ sender: Any) {
        let time = Int(maxBubblesSlider.value)
        maxBubblesLabel.text = "\(time)"
    }
    
    @IBAction func gameTimeSliderChanged(_ sender: Any) {
        gameTimeLabel.text = Utils.formatTime(Int(gameTimeSlider.value))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
