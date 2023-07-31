import UIKit
import SpriteKit
import AVFoundation
import AVFAudio
import SwiftyGif

// imported AVFoundation and AVFAudio so we have access to the theme song for pacMan.


class ViewControllerr: UIViewController {
    @IBOutlet var skView : SKView?
    @IBOutlet var scoreLabel : UILabel?
    var scoreLabell: UILabel!
    var highScoreLabel: UILabel?
    var highScore = 0
    var allScore = [Int]()
    var aaPlayer: AVAudioPlayer?
    var playPauseButton: UIButton!
   
   
    
 // aaPlayer is for the themeSong.

    override func viewDidLoad() {
          super.viewDidLoad()
        
        // Add the score label
           scoreLabell = UILabel()
           scoreLabell.textColor = .white
           scoreLabell.font = UIFont(name: "ChalkDuster", size: 17)
           view.addSubview(scoreLabell)

           // Set up constraints for the score label
           scoreLabell.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               scoreLabell.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60),
               scoreLabell.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 13),
               scoreLabell.widthAnchor.constraint(equalToConstant: 200),
               scoreLabell.heightAnchor.constraint(equalToConstant: 30)
           ])
        
        // Add the play/pause button
          playPauseButton = UIButton(type: .system)
          playPauseButton.setTitle("Pause", for: .normal)
          playPauseButton.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
          playPauseButton.setTitleColor(.white, for: .normal)
          playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
          playPauseButton.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(playPauseButton)

          // Set up constraints for the button
          NSLayoutConstraint.activate([
              playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              playPauseButton.topAnchor.constraint(equalTo: scoreLabell!.bottomAnchor, constant: 10),
              playPauseButton.widthAnchor.constraint(equalToConstant: 100),
              playPauseButton.heightAnchor.constraint(equalToConstant: 40)
          ])


        if let path = Bundle.main.path(forResource: "PacMan", ofType: "mp3") {
                    let url = URL(fileURLWithPath: path)
                    do {
                        aaPlayer = try AVAudioPlayer(contentsOf: url)
                        aaPlayer?.play()
                        aaPlayer?.numberOfLoops = -1
                // aaPlayer?.numberOfLoops = -1 makes sure the theme song plays as long as the game is playing.
                        
                    } catch {
                        print("Error loading audio file")
                    }
                }
        
          // Retrieve high score from UserDefaults
          if let savedHighScore = UserDefaults.standard.value(forKey: "highScore") as? Int {
              self.highScore = savedHighScore
              print("This is the high score: \(savedHighScore)")
              // Update high score label with saved value
              self.highScoreLabel?.text = "High Score: \(savedHighScore)"
          }

          let scene = SKScene(fileNamed: "PacMan") as! PacManScene
          scene.scaleMode = .aspectFit
          skView!.presentScene(scene)

        NotificationCenter.default.addObserver(forName: Notification.Name("didChangeScore"), object: nil, queue: nil, using: { (n : Notification) in
            self.scoreLabell?.text = "Your Score: \(scene.score)"

            self.highScoreLabel?.text =  "High Score: \(self.highScore)"

            self.allScore.append(scene.score)
            // Update the highScore
            if let maxScore = self.allScore.max(), maxScore > self.highScore {
                self.highScore = maxScore
                print("New high score: \(self.highScore)")

                // Save high score to UserDefaults
                UserDefaults.standard.set(self.highScore, forKey: "highScore")
                UserDefaults.standard.synchronize() // Add this line to immediately save changes to disk

                // Update high score label
                self.highScoreLabel?.text = "High Score: \(self.highScore)"
            }
        })

        scoreLabell = UILabel(frame: CGRect(x: 13, y: 60, width: 200, height: 30))
        scoreLabell?.textColor = .white
        scoreLabell?.textColor = .black
        scoreLabell?.textColor = .clear
        scoreLabell?.textColor = .white
        scoreLabell?.font = UIFont(name: "ChalkDuster", size: 17)

        view.addSubview(scoreLabell!)

        // Set up the label
        highScoreLabel = UILabel()
        highScoreLabel!.text = "High Score"
        highScoreLabel!.textColor = .white
        highScoreLabel!.font = UIFont(name: "ChalkDuster", size: 16)
        highScoreLabel!.translatesAutoresizingMaskIntoConstraints = false  // Disable autoresizing masks

        // Add the label to the view
        view.addSubview(highScoreLabel!)

        // Set up constraints for the label
        NSLayoutConstraint.activate([
            // Center the label horizontally in the view
            
            highScoreLabel!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 330),
            
            
            highScoreLabel!.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 3),
          
            // Position the label 80 points from the top of the view
            highScoreLabel!.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 90),
            
            // Set a fixed width of 200 points for the label
            highScoreLabel!.widthAnchor.constraint(equalToConstant: 240),
            
            // Set a fixed height of 30 points for the label
            highScoreLabel!.heightAnchor.constraint(equalToConstant: 30)
        ])

    }

    @objc func playPauseButtonTapped() {
        if skView!.isPaused {
            // If the game is paused, resume the game
            skView!.isPaused = false
            playPauseButton.setTitle("Pause", for: .normal)
            (skView!.scene as! PacManScene).resumeGame()
        } else {
            // If the game is not paused, pause the game
            skView!.isPaused = true
            playPauseButton.setTitle("Play", for: .normal)
            (skView!.scene as! PacManScene).pauseGame()
        }
    }

    @IBAction func takeMotionFrom(gestureRecognizer : UIPanGestureRecognizer) {
        let motionDetectDelta = CGFloat(20)
        let velocity = gestureRecognizer.velocity(in: skView)
        if velocity.y > motionDetectDelta {
            (skView!.scene as! PacManScene).pacManDirection = .Up
        } else if velocity.y < -motionDetectDelta {
            (skView!.scene as! PacManScene).pacManDirection = .Down
        } else if velocity.x < -motionDetectDelta {
            // this is the amount of time this takes
            (skView!.scene as! PacManScene).pacManDirection = .Left
        } else if velocity.x > motionDetectDelta {
            (skView!.scene as! PacManScene).pacManDirection = .Right
        }
    }
}
