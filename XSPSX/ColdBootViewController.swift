//
//  ViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/18/23.
//

import UIKit
import AVKit
import AVFoundation

class ColdBootViewController: UIViewController, AVPlayerViewControllerDelegate {
    var isJailbreakEnabled = false
    @IBOutlet weak var videoLayer: UIView!
    @IBOutlet weak var stealthCFWView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coldboot()
        AudioManager.shared.playColdBootSound()
        
        if isJailbreakEnabled {
            AudioManager.shared.playDefaultBackgroundMusic()
            stealthCFWView.isHidden = false
            stealthCFWView.alpha = 0
            UIView.animate(withDuration: 2.0, animations: {
                self.stealthCFWView.alpha = 0.59
            }) { (completed) in
                if completed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.69) {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.stealthCFWView.alpha = 0
                        }) { (completed) in
                            if completed {
                                self.stealthCFWView.isHidden = true
                            }
                        }
                    }
                }
            }
        } else {
            stealthCFWView.isHidden = true
            AudioManager.shared.stopBackgroundAudio()
        }
    }

        func coldboot() {
            guard let path = Bundle.main.path(forResource: "cyan4", ofType: "mp4") else {
                return
            }
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            playerLayer.videoGravity = .resizeAspectFill
            videoLayer.layer.addSublayer(playerLayer)
            NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            player.play()
        }
        
    @objc func videoDidFinishPlaying(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController") as? XSPSXViewController {
            newViewController.isJailbreakEnabled = self.isJailbreakEnabled // Pass the flag
            newViewController.view.alpha = 0

            self.present(newViewController, animated: false, completion: {
                UIView.animate(withDuration: 0.3, animations: {
                    newViewController.view.alpha = 1
                })
            })
        }
    }

    
    @IBAction func unwindToColdBoot(_ unwindSegue: UIStoryboardSegue) {
        // This method allows the segue to unwind back to this view controller.
        // You don't need to add any code in here unless you want to execute code when the segue unwinds.
    }

}

  
    

