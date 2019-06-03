//
//  HomeViewController.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 5/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var playerNameTextInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerNameTextInput.delegate = self
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        // Check if name is empty, if so animate
        if playerNameTextInput.text == "" {
            UIView.animate(withDuration: 0.2, animations: {
                self.playerNameTextInput.layer.borderColor = UIColor.red.cgColor
                self.playerNameTextInput.layer.borderWidth = 1.0
            })
        }
        else {
            // Reset textfield style and seque to GameView
            UIView.animate(withDuration: 0.2, animations: {
                self.playerNameTextInput.layer.borderWidth = 0.25
                self.playerNameTextInput.layer.borderColor = UIColor.lightGray.cgColor
            })
            performSegue(withIdentifier: "GameViewSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewSegue" {
            let gameViewController = segue.destination as! GameViewController
            do {
                gameViewController.playerName = playerNameTextInput.text
                // Set saved settings
                gameViewController.settings = try Storage().loadSettings()
            } catch {
                // Set default settings
                gameViewController.settings = Settings()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated
        super.didReceiveMemoryWarning()
    }
}
