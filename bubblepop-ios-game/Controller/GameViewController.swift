//
//  GameViewController.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 4/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    // Load from HomeViewController
    var settings: Settings?
    var playerName: String?
    
    // Variables
    var timeRemaining: Int = 5
    var playerScore: Int = 0
    var highScore: Int = 0
    var bubbleCount: Int = 0
    var maxBubbles: Int = 15
    var bubbles: [BubbleType] = []
    var previousBubblePopped: BubbleType?
    var timer: Timer?
    let randomSource: GKRandomSource = GKARC4RandomSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load settings
        if let gameSettings = settings {
            timeRemaining = gameSettings.playTime
            maxBubbles = gameSettings.maxBubbles
        }
        loadCurrentHighScore()
        timerLabel.text = Utils.formatTime(timeRemaining)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    // Update game view every second
    @objc func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            timerLabel.text = Utils.formatTime(timeRemaining)
            
            removeBubbles()
            addBubbles()
        }
        else {
            // End game and transition to leaderboard scene
            timer?.invalidate()
            timer = nil
            self.performSegue(withIdentifier: "LeaderboardViewSegue", sender: self)
        }
    }
    
    // Load and set current high score form saved data
    func loadCurrentHighScore() {
        do {
            var leaderboard = try Storage().loadLeaderboard()
            // Sort scores by highest first
            leaderboard.sort(by: { $0.playerScore > $1.playerScore })
            highScore = leaderboard[0].playerScore
            highScoreLabel.text = String(highScore)
        } catch {
            // Set default score if no saved data
            highScore = 0
        }
    }
    
    // Add a random number of bubbles to the view
    func addBubbles() {
        if bubbleCount < maxBubbles {
            let amountToAdd = randomSource.nextInt(upperBound: (maxBubbles - bubbleCount)+1)
            for _ in 0...amountToAdd {
                let bubble = createBubble()
                // Add bubble to view
                self.view.addSubview(bubble)
                self.view.sendSubviewToBack(bubble)
                bubbleCount += 1
            }
        }
    }
    
    // Remove a random amount of bubbles
    func removeBubbles() {
        var amountToRemove = randomSource.nextInt(upperBound: bubbleCount+1)
        // Loop through bubbles and remove until amountToRemove = 0
        for subview in self.view.subviews {
            if subview.tag > 0 {
                if amountToRemove > 0 {
                    removeBubble(subview as! BubbleView)
                    amountToRemove -= 1
                    bubbleCount -= 1
                }
                else {
                    break
                }
            }
        }
    }
    
    // Create a new bubble
    @objc func createBubble() -> BubbleView {
        var bubble: BubbleView
        // Continue to create bubbles until a valid bubble position is found
        repeat {
            // Set bubble to coordinates to a random position within the view
            let xPos = (self.view.frame.width-100) * CGFloat(randomSource.nextUniform())
            let yPos = (self.view.frame.height-125) * CGFloat(randomSource.nextUniform())
            bubble = BubbleView(frame: CGRect(x: xPos, y: yPos, width: 50, height: 50))
        } while !locationIsValid(of: bubble)
        
        bubble.bubbleType = getRandomBubbleType()
        bubble.tag = generateTag()
        setBubbleImage(of: bubble)
        return bubble
    }
    
    // Remove a bubble from the view
    func removeBubble(_ bubble: BubbleView) {
        if let bubbleInView = self.view.viewWithTag(bubble.tag) {
            bubbleInView.removeFromSuperview()
        }
    }
    
    // Generate and return a unique tag
    func generateTag() -> Int {
        // Loop until a valid tag is found
        while true {
            let tag = randomSource.nextInt(upperBound: 50) + 1
            guard let _ = self.view.viewWithTag(tag) else {
                return tag
            }
        }
    }
    
    // Determine if bubble location does not overlap existing bubbles
    func locationIsValid(of bubble: BubbleView) -> Bool {
        // Loop through all bubbles and determine if position overlaps
        for subview in self.view.subviews {
            if let bubbleOnScreen = subview as? BubbleView {
                if bubbleOnScreen.frame.intersects(bubble.frame) {
                    return false
                }
            }
        }
        return true
    }
    
    // Decide bubble's probability of appearance randomly
    func getRandomBubbleType() -> BubbleType {
        // Generate number between 0 and 99
        let num: Int = randomSource.nextInt(upperBound: 100)
        switch num {
        case 0...39:
            return BubbleType(color: "red", points: 1)
        case 40...69:
            return BubbleType(color: "pink", points: 2)
        case 70...84:
            return BubbleType(color: "green", points: 5)
        case 85...94:
            return BubbleType(color: "blue", points: 8)
        default: // 95...99
            return BubbleType(color: "black", points: 10)
        }
    }
    
    // Set bubble image based on color
    func setBubbleImage(of bubble: BubbleView) {
        if let color = bubble.bubbleType?.color {
            switch color {
            case "red":
                bubble.image = UIImage(named: "bubble_red.png")
            case "pink":
                bubble.image = UIImage(named: "bubble_pink.png")
            case "green":
                bubble.image = UIImage(named: "bubble_green.png")
            case "blue":
                bubble.image = UIImage(named: "bubble_blue.png")
            case "black":
                bubble.image = UIImage(named: "bubble_black.png")
            default:
                break
            }
        }
    }
    
    // Determine if player touched a bubble and if so add points to score
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch?.location(in: self.view)

        for subview in self.view.subviews {
            if let poppedBubble = subview as? BubbleView {
                if (poppedBubble.layer.presentation()?.hitTest(touchLocation!)) != nil {
                    let points = determinePoints(from: poppedBubble.bubbleType!)
                    playerScore += points
                    scoreLabel.text = String(playerScore)
                    updateHighScore()
                    // remove bubble
                    poppedBubble.removeFromSuperview()
                    bubbleCount -= 1
                }
            }
        }
    }
    
    // Determine points earned from popping bubble
    func determinePoints(from bubble: BubbleType) -> Int {
        if previousBubblePopped?.color != bubble.color {
            previousBubblePopped = bubble
            return bubble.points
        }
        else {
            // If bubble is the same color as the previous bubble popped, times points by 1.5
            let points = Double(bubble.points) * 1.5
            return Int(round(points))
        }
    }
    
    // Update high score if player score is greater
    func updateHighScore() {
        if playerScore > highScore {
            highScore = playerScore
            highScoreLabel.text = String(highScore)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LeaderboardViewSegue" {
            let leaderboardViewController = segue.destination as! LeaderboardViewController
            leaderboardViewController.playerScore = self.playerScore
            leaderboardViewController.playerName = self.playerName
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}
