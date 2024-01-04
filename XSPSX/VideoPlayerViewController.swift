//
//  VideoPlayerViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 11/16/23.
//

import Foundation
import UIKit
import AVFoundation
class VideoPlayerViewController: UIViewController {
    
    var videoPlayer: AVPlayer!
    var progressUpdateTimer: Timer?
    
    @IBOutlet weak var videoView: UIView!
    
    // UI elements
    var titleLabel: UILabel!
    var playPauseButton: UIButton!
    var goBackButton: UIButton!
    var selectVideoButton: UIButton!
    var videoSelectionView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the audio session for ambient playback
          let audioSession = AVAudioSession.sharedInstance()
          do {
              try audioSession.setCategory(.ambient)
              try audioSession.setActive(true)
          } catch {
              print("Failed to set audio session category: \(error)")
          }
        
        videoView.backgroundColor = .clear
        
        
        
        // Add a title label for the video
        titleLabel = UILabel(frame: CGRect(x: 0, y: view.bounds.height - 70, width: view.bounds.width, height: 30))
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = "Select a Video"
        view.addSubview(titleLabel)
        
        // Add the Play/Pause button
        playPauseButton = UIButton(type: .system)
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.frame = CGRect(x: view.bounds.width / 2 - 40, y: view.bounds.height - 100, width: 80, height: 40)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
        playPauseButton.tintColor = .cyan
        view.addSubview(playPauseButton)
        
        // Add the "Go Back" button
        goBackButton = UIButton(type: .system)
        goBackButton.setTitle("Go Back", for: .normal)
        goBackButton.frame = CGRect(x: 20, y: 20, width: 80, height: 40)
        goBackButton.addTarget(self, action: #selector(goBackButtonPressed), for: .touchUpInside)
        goBackButton.tintColor = .cyan
        view.addSubview(goBackButton)
        
        // Add the "Select Video" button
        selectVideoButton = UIButton(type: .system)
        selectVideoButton.setTitle("Select Video", for: .normal)
        selectVideoButton.frame = CGRect(x: 20, y: goBackButton.frame.maxY + 10, width: 100, height: 40)
        selectVideoButton.addTarget(self, action: #selector(selectVideo), for: .touchUpInside)
        selectVideoButton.tintColor = .cyan
        view.addSubview(selectVideoButton)
        
        // Set up the video player
        setupVideoPlayer()
        
        // Initialize the video selection view
         let viewWidth: CGFloat = 210  // Adjust width as needed
         let viewHeight: CGFloat = view.bounds.height
         let offScreenX: CGFloat = -viewWidth
         videoSelectionView = UIView(frame: CGRect(x: offScreenX, y: 0, width: viewWidth, height: viewHeight))
         videoSelectionView.backgroundColor = .clear
         view.addSubview(videoSelectionView)

         // Starting Y position for the video buttons
         let buttonsStartY: CGFloat = selectVideoButton.frame.maxY + 20  // Adjust as needed for spacing

         // Add video selection buttons to this view
         let buttonTitles = ["gentro", "gentro", "gentro", "gentro", "gentro"]
         for (index, title) in buttonTitles.enumerated() {
             let button = UIButton(type: .system)
             button.setTitle(title, for: .normal)
             button.frame = CGRect(x: 20, y: buttonsStartY + CGFloat(index * 50), width: viewWidth - 40, height: 40)
             button.tintColor = .cyan  // Set button color to cyan
             button.addTarget(self, action: #selector(videoButtonPressed(_:)), for: .touchUpInside)
             
             
             // Adding a background image
             let backgroundImage = UIImageView(frame: videoSelectionView.bounds)
             backgroundImage.image = UIImage(named: "MusicBackground")
             backgroundImage.alpha = 0.5// Replace with your image name
             backgroundImage.contentMode = .scaleAspectFill  // Or any other content mode that fits your needs
             backgroundImage.clipsToBounds = true
             videoSelectionView.addSubview(backgroundImage)
             videoSelectionView.addSubview(button)
                 view.bringSubviewToFront(selectVideoButton)
                 view.bringSubviewToFront(goBackButton)
         }
    }
    

    private func setupVideoPlayer() {
         videoPlayer = AVPlayer()
         let playerLayer = AVPlayerLayer(player: videoPlayer)
         playerLayer.frame = videoView.bounds
         playerLayer.videoGravity = .resizeAspect
         videoView.layer.addSublayer(playerLayer)

         // Add observer for video completion
         NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
     }

     @objc func videoDidEnd(notification: NSNotification) {
         // Hide the videoView or perform other actions when the video ends
         videoView.isHidden = true
         // Resume the background audio
           AudioManager.shared.resumeBackgroundAudio()
     }

     @objc func videoButtonPressed(_ sender: UIButton) {
         videoView.isHidden = false  // Make the video view visible again

         guard let selectedVideoTitle = sender.currentTitle else { return }
         let videoFileName = videoFileName(for: selectedVideoTitle)
         if let videoURL = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") {
             let playerItem = AVPlayerItem(url: videoURL)
             videoPlayer.replaceCurrentItem(with: playerItem)
             startVideoPlayback()
         }
         titleLabel.text = selectedVideoTitle
     }


    func videoFileName(for title: String) -> String {
        switch title {
        case "(Key) MW2 Terminal +1100": return "(Key) MW2 Terminal +1100"
        case "(Key) MW2 Derail Knife shot": return "(Key) MW2 Derail Knife shot"
        case "(Key) MW2 Rust Black hawk Down": return "(Key) MW2 Rust Black hawk Down"
        case "(Key) +550 Terminal": return "(Key) +550 Terminal"
        case "(Key) +500 Sub Base": return "(Key) +500 Sub Base"
        default: return "Select a Video"
        }
    }

    private func startVideoPlayback() {
        // Pause the background audio
            AudioManager.shared.pauseBackgroundAudio()
        videoPlayer.play()
    }
    
    private func pauseVideoPlayback() {
        videoPlayer.pause()
    }

    @objc func playPauseButtonPressed(_ sender: UIButton) {
        if videoPlayer.rate == 0 {
            startVideoPlayback()
            sender.setTitle("Pause", for: .normal)
        } else {
            pauseVideoPlayback()
            sender.setTitle("Play", for: .normal)
        }
    }

    @objc func goBackButtonPressed(_ sender: UIButton) {
        pauseVideoPlayback()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let xspsxViewController = self.storyboard?.instantiateViewController(withIdentifier: "XSPSXViewController") as? XSPSXViewController {
                self.present(xspsxViewController, animated: true, completion: nil)
            }
        }
    }

    @objc func selectVideo(_ sender: UIButton) {
        let shouldShow = videoSelectionView.frame.origin.x < 0
        let newOriginX = shouldShow ? 0 : -videoSelectionView.frame.width

        UIView.animate(withDuration: 0.5) {
            self.videoSelectionView.frame.origin.x = newOriginX
        }
    }
}
