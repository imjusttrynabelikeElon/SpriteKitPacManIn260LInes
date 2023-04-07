//
//  homeScreen.swift
//  PacMan00
//
//  Created by Karon Bell on 4/6/23.
//

import Foundation
import UIKit
import SwiftyGif
import AVKit
import AVFAudio

class homeScreen: UIViewController, SwiftyGifDelegate {
    
    @IBOutlet var pacManGif: UIImageView!
    
    
    var aaPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Change the background color to black
           view.backgroundColor = .black
           
        if let path = Bundle.main.path(forResource: "pacManEat", ofType: "mp3") {
                    let url = URL(fileURLWithPath: path)
                    do {
                        aaPlayer = try AVAudioPlayer(contentsOf: url)
                        aaPlayer?.numberOfLoops = -1
                        aaPlayer?.play()
                // aaPlayer?.numberOfLoops = -1 makes sure the theme song plays as long as the game is playing.
                        
                    } catch {
                        print("Error loading audio file")
                    }
                }
        
        self.pacManGif.delegate = self
        
        do {
            let image = try UIImage(gifName: "pacMann")
            self.pacManGif.setGifImage(image, loopCount: -1)
            self.pacManGif.startAnimatingGif()
        } catch {
            // Handle the error
            print("Error loading image: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: 3.9, delay: 0, options: .curveEaseOut, animations: {
            self.view.transform = CGAffineTransform.identity
        }) { _ in
            // Animation completed
            UIView.animate(withDuration: 2.3, animations: {
                self.view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2).concatenating(CGAffineTransform(scaleX: 5, y: 5))
            }) { _ in
                // Animation completed
                print("Yess")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "viewControllerr") as! ViewControllerr
            
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: {
                    // Remove homeScreen as the parent view controller
                                   self.removeFromParent()
                                   self.view.removeFromSuperview()
                    if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                        let window = windowScene.windows.first {
                        // Do something with the window
                        self.aaPlayer?.stop()
                    }


                  
                })
            

            }
        }
    }

    
    func gifDidStop(sender: UIImageView) {
        print("gifDidStop")
    }
    
    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifURLDidFail(sender: UIImageView, url: URL, error: Error?) {
        print("gifURLDidFail")
    }
    
    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }
}
