//
//  leaderboardViewController.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 6/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    // Load from GameViewController
    var playerName: String?
    var playerScore: Int!
    
    // Variables
    let storage: Storage = Storage()
    var leaderboard: [Leaderboard] = []
    let maxRows: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaderboardTableView.dataSource = self
        leaderboardTableView.delegate = self
        
        do {
            // Load stored leaderboard
            leaderboard = try storage.loadLeaderboard()
        } catch {
            playerNameLabel.text = "No High Scores"
        }
        
        if let name = playerName {
            // Set player detail labels
            playerScoreLabel.text = "\(playerScore!) points"
            playerNameLabel.text = name
            // Create new leaderboard score and add to leaderboard
            let newScore = Leaderboard(playerName: name, playerScore: playerScore)
            leaderboard.append(newScore)
            sortLeaderboard()
            leaderboardTableView.reloadData()
            do {
                // Save leaderboard data
                try storage.saveData(scores: leaderboard)
            } catch {
                print("Error: coult not save leaderboard data")
            }
        } else {
            // Set labels when viewing Leaderboard from HomeView
            playerNameLabel.text = "Top scores"
            playerScoreLabel.text = ""
        }
    }
    
    // Sort scores in leaderboard by highest scores first
    func sortLeaderboard() {
        leaderboard.sort(by: { $0.playerScore > $1.playerScore })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(leaderboard.count, maxRows)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailsCell", for: indexPath)
        // Get labels from the row cells
        let playerNameLabelCell: UILabel = cell.viewWithTag(1) as! UILabel
        let playerScoreLabelCell: UILabel = cell.viewWithTag(2) as! UILabel
        // Set new row cells
        playerNameLabelCell.text = "\(indexPath.row + 1). \(leaderboard[indexPath.row].playerName)"
        playerScoreLabelCell.text = "\(leaderboard[indexPath.row].playerScore) points"
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
