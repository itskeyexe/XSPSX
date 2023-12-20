//
//  MusicPlayerViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 11/11/23.
//

import AVFoundation
import AVKit
import UIKit

class MusicPlayerViewController: UIViewController, AVAudioPlayerDelegate {
    
    var visualizerView: VisualizerView!
    var visualizerTimer: Timer?
    var audioPlayer: AVAudioPlayer!
    var progressUpdateTimer: Timer?
    private var animeVideoPlayer: AVPlayer?
    private var xspsxVideoPlayer: AVPlayer?
    @IBOutlet weak var animeView: UIView!
    @IBOutlet weak var xspsxView: UIView!
    @IBOutlet weak var xspsxView2: UIView!
    private var DuplicatexspsxVideoPlayer: AVPlayer?
    
    // Add properties for UI elements
       var titleLabel: UILabel!
       var songProgressBar: UIProgressView!
       var playPauseButton: UIButton!
       var goBackButton: UIButton!
       var selectSongButton: UIButton!
       var songSelectionView: UIView!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
               // Add the title label
               titleLabel = UILabel(frame: CGRect(x: 0, y: view.bounds.height - 70, width: view.bounds.width, height: 30))
               titleLabel.textAlignment = .center
               titleLabel.textColor = .white
               titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
               titleLabel.text = "War Drums Meditation"
               view.addSubview(titleLabel)
               
               // Add the song progress bar
               songProgressBar = UIProgressView(progressViewStyle: .default)
               songProgressBar.frame = CGRect(x: 0, y: view.bounds.height - 40, width: view.bounds.width, height: 20)
               view.addSubview(songProgressBar)
               
               // Add the Play/Pause button
               playPauseButton = UIButton(type: .system)
               playPauseButton.setTitle("", for: .normal)
               playPauseButton.frame = CGRect(x: view.bounds.width / 2 - 40, y: view.bounds.height - 100, width: 80, height: 40)
               playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
               view.addSubview(playPauseButton)
               
               // Add the "Go Back" button
               goBackButton = UIButton(type: .system)
               goBackButton.setTitle("Go Back", for: .normal)
               goBackButton.frame = CGRect(x: 20, y: 20, width: 80, height: 40)
               goBackButton.addTarget(self, action: #selector(goBackButtonPressed), for: .touchUpInside)
               view.addSubview(goBackButton)
        
               // Add the "Select Song" button
               selectSongButton = UIButton(type: .system)
               selectSongButton.setTitle("Select Song", for: .normal)
               selectSongButton.frame = CGRect(x: 20, y: goBackButton.frame.maxY + 10, width: 100, height: 40)
               selectSongButton.addTarget(self, action: #selector(selectSong), for: .touchUpInside)
               view.addSubview(selectSongButton)
        
            // Set the color of each button to cyan
            playPauseButton.tintColor = .cyan
            goBackButton.tintColor = .cyan
            selectSongButton.tintColor = .cyan
            songProgressBar.tintColor = .cyan
            songProgressBar.trackTintColor = .gray
            songProgressBar.alpha = 0.5
        
        
        // Initialize the song selection view
        let viewWidth: CGFloat = 210  // Adjust width as needed
        let viewHeight: CGFloat = view.bounds.height
        let offScreenX: CGFloat = -viewWidth
        songSelectionView = UIView(frame: CGRect(x: offScreenX, y: 0, width: viewWidth, height: viewHeight))
        songSelectionView.backgroundColor = .clear
        view.addSubview(songSelectionView)
        
        // Adding a background image
        let backgroundImage = UIImageView(frame: songSelectionView.bounds)
        backgroundImage.image = UIImage(named: "MusicBackground") // Replace with your image name
        backgroundImage.contentMode = .scaleAspectFill  // Or any other content mode that fits your needs
        backgroundImage.clipsToBounds = true
        songSelectionView.addSubview(backgroundImage)

        // Send the background image to the back of the view
        songSelectionView.sendSubviewToBack(backgroundImage)

        // Starting Y position for the song buttons
        let buttonsStartY: CGFloat = selectSongButton.frame.maxY + 20  // Adjust as needed for spacing

        // Add song selection buttons to this view
        let buttonTitles = ["Song 1", "Song 2", "Song 3", "Song 4", "Song 5"]
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.frame = CGRect(x: 20, y: buttonsStartY + CGFloat(index * 50), width: 210, height: 40)
            button.tintColor = .cyan  // Set button color to cyan
            button.addTarget(self, action: #selector(songButtonPressed(_:)), for: .touchUpInside)
            songSelectionView.addSubview(button)
        }


        
                //visualizer
                visualizerView = VisualizerView(frame: view.bounds)
                visualizerView.backgroundColor = .clear
                view.addSubview(visualizerView)
        
            // Configure the Play/Pause button for iOS 15.0 or later
            var config = UIButton.Configuration.plain()
            config.imagePlacement = .trailing
            config.imagePadding = 10         // Add padding between the image and text
            config.title = ""
            config.baseForegroundColor = .systemBlue // Or any color you prefer
            config.baseBackgroundColor = .clear      // Or any color you prefer

            // Set the initial image for the button
            config.image = UIImage(systemName: "play.fill")

            playPauseButton.configuration = config

    
        
        // Set up the audio player
        let path = Bundle.main.path(forResource: "War Drums Meditation", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
        

        setupAnimeVideoPlayer()
        setupXSPSXVideoPlayer()
        startXSPSXVideoPlayback()
        startXSPSXVideo2Playback()
        

        // Set up the view hierarchy order
            view.bringSubviewToFront(xspsxView)
            view.bringSubviewToFront(visualizerView)
            view.bringSubviewToFront(xspsxView2)
            
            view.bringSubviewToFront(titleLabel)
            view.bringSubviewToFront(songProgressBar)
       
            view.bringSubviewToFront(songSelectionView)
        view.bringSubviewToFront(goBackButton)
        view.bringSubviewToFront(selectSongButton)
        view.bringSubviewToFront(playPauseButton)

    }
    
    private func setupAnimeVideoPlayer() {
        if let videoURL = Bundle.main.url(forResource: "anime", withExtension: "mov") {
            let playerItem = AVPlayerItem(url: videoURL)
            let player = AVPlayer(playerItem: playerItem)
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = animeView.bounds
            
            animeView.layer.insertSublayer(playerLayer, at: 0)
            
            // Observe when the video reaches its end
            NotificationCenter.default.addObserver(self, selector: #selector(animePlayerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            self.animeVideoPlayer = player
        }
    }
    
    private func setupXSPSXVideoPlayer() {
        if let videoURL = Bundle.main.url(forResource: "1cyan", withExtension: "mov") {
            let playerItem = AVPlayerItem(url: videoURL)
            let player = AVPlayer(playerItem: playerItem)
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = xspsxView.bounds
            
            xspsxView.layer.insertSublayer(playerLayer, at: 0)
            //view.bringSubviewToFront(xspsxView)
            
            // Loop the video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { [weak player] _ in
                player?.seek(to: CMTime.zero)
                player?.play()
            }
            
            self.xspsxVideoPlayer = player
        }
    }
    
    private func setupDuplicateXSPSXVideoPlayer() {
        if let videoURL = Bundle.main.url(forResource: "1cyan", withExtension: "mov") {
            let playerItem = AVPlayerItem(url: videoURL)
            let player = AVPlayer(playerItem: playerItem)
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = xspsxView2.bounds
            
            xspsxView2.layer.insertSublayer(playerLayer, at: 0)
            
            // Set the alpha of the view
            xspsxView2.alpha = 0.5

            // Loop the video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { [weak player] _ in
                player?.seek(to: CMTime.zero)
                player?.play()
            }
            
            self.DuplicatexspsxVideoPlayer = player
        }
    }

    

    private func startAnimeVideoPlayback() {
        self.animeVideoPlayer?.play()
    }
    

    private func startXSPSXVideoPlayback() {
        self.xspsxVideoPlayer?.play()
    }
    
    private func startXSPSXVideo2Playback() {
        self.DuplicatexspsxVideoPlayer?.play()
    }
    
    @objc func animePlayerItemDidReachEnd(_ notification: Notification) {
        if let player = self.animeVideoPlayer {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    // MARK: - Audio Player Delegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        visualizerTimer?.invalidate()
        visualizerTimer = nil
        visualizerView.isHidden = true
        // Reset the visualizer view if necessary
        progressUpdateTimer?.invalidate()
            progressUpdateTimer = nil
            songProgressBar.setProgress(0.0, animated: false)  // Optionally reset progress bar
    }

    
    // MARK: - Audio Visualization
    
    @objc func updateVisualizer() {
        audioPlayer.updateMeters()
        
        // Access audio levels for each channel (left and right)
        let leftChannel = audioPlayer.averagePower(forChannel: 0)
        let rightChannel = audioPlayer.averagePower(forChannel: 1)
        
        // Update your visualizer with the audio data
        visualizerView.update(withLeftChannel: leftChannel, rightChannel: rightChannel)
    }
    
    // MARK: - Play/Pause Button Action
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        var currentConfig = sender.configuration ?? UIButton.Configuration.plain()

        if audioPlayer.isPlaying {
            audioPlayer.pause()
            visualizerTimer?.invalidate()
            progressUpdateTimer?.invalidate()  // Stop the progress update timer
            currentConfig.title = ""
            currentConfig.image = UIImage(systemName: "play.fill")
            sender.configuration = currentConfig
        } else {
            audioPlayer.play()
            visualizerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateVisualizer), userInfo: nil, repeats: true)
            progressUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSongProgressBar), userInfo: nil, repeats: true)
            visualizerView.isHidden = false
            startAnimeVideoPlayback()
            currentConfig.title = ""
            currentConfig.image = UIImage(systemName: "pause.fill")
            sender.configuration = currentConfig
        }
    }

    
    // MARK: - Go Back Button Action
    @IBAction func goBackButtonPressed(_ sender: UIButton) {
        // Pause the audio player if it's playing
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            visualizerTimer?.invalidate()
        }

        // Prepare for transition (if any preparation is needed)

        // Delay the transition by 0.3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Instantiate XSPSXViewController from the storyboard
            if let xspsxViewController = self.storyboard?.instantiateViewController(withIdentifier: "XSPSXViewController") as? XSPSXViewController {
                // Present the new view controller
                self.present(xspsxViewController, animated: true, completion: nil)
            }
        }
    }


    

    @objc func selectSong(_ sender: UIButton) {
        let shouldShow = songSelectionView.frame.origin.x < 0
        let newOriginX = shouldShow ? 0 : -songSelectionView.frame.width

        UIView.animate(withDuration: 0.5) {
            self.songSelectionView.frame.origin.x = newOriginX
        }
    }


    
    @objc func songButtonPressed(_ sender: UIButton) {
        guard let selectedSongTitle = sender.currentTitle else { return }

          // Animate the closing of the song selection view
          UIView.animate(withDuration: 0.5) {
              self.songSelectionView.frame.origin.x = -self.songSelectionView.frame.width
          }
        // Update the title label
        titleLabel.text = selectedSongTitle

        // Logic to play the selected song
        // This is placeholder logic and should be replaced with your actual song playing code
        if let path = Bundle.main.path(forResource: selectedSongTitle, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print("Error initializing audio player for selected song: \(error.localizedDescription)")
            }
        }
    }

    

    @objc private func updateSongProgressBar() {
           let currentTime = audioPlayer.currentTime
           let duration = audioPlayer.duration
           let progress = Float(currentTime / duration)
           songProgressBar.setProgress(progress, animated: true)
       }
}




class VisualizerView: UIView {
    
    private var leftChannelLevel: Float = 0.0
    private var rightChannelLevel: Float = 0.0
    private var barsAlpha: CGFloat = 0.0
    private var currentColorIndex: Int = 0
    private let barColors: [UIColor] = [.cyan, .yellow]
    private var maxBarsAlpha: CGFloat = 0.55
    private var colorChangeCounter: Int = 0
    private let colorChangeInterval: Int = 20
    
    init(frame: CGRect, maxBarsAlpha: CGFloat = 0.55) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.maxBarsAlpha = maxBarsAlpha
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawVisualizer()
    }
    
    func update(withLeftChannel left: Float, rightChannel right: Float) {
        leftChannelLevel = left
        rightChannelLevel = right
        
        setNeedsDisplay()
    }
    
    private func drawVisualizer() {
        guard let context = UIGraphicsGetCurrentContext() else { return }

           // Update barsAlpha for fade-in and fade-out effect
           if barsAlpha < maxBarsAlpha {
               barsAlpha += 0.02
           } else {
               barsAlpha -= 0.02
           }

           // Ensure barsAlpha stays within the desired range
           barsAlpha = min(max(barsAlpha, 0.5), maxBarsAlpha)

           // Handle color change
           colorChangeCounter += 1
           if colorChangeCounter >= colorChangeInterval {
               currentColorIndex = (currentColorIndex + 1) % barColors.count
               colorChangeCounter = 0
           }
           
           let currentColor = barColors[currentColorIndex]
           let nextColor = barColors[(currentColorIndex + 1) % barColors.count]
           let interpolatedColor = interpolateColor(from: currentColor, to: nextColor, with: CGFloat(colorChangeCounter) / CGFloat(colorChangeInterval))

           context.setFillColor(interpolatedColor.withAlphaComponent(barsAlpha).cgColor)
        
        let barWidth: CGFloat = 10.0
        let barSpacing: CGFloat = 5.0
        let totalBars = Int(bounds.width / (barWidth + barSpacing))
        
        for i in 0..<totalBars {
            let barHeight = bounds.height * CGFloat.random(in: 0.1...1.0)
            let barX = CGFloat(i) * (barWidth + barSpacing) + 10.0

            let barRect = CGRect(x: barX, y: bounds.height - barHeight, width: barWidth, height: barHeight)
            context.fill(barRect)
        }
    }
    
    private func interpolateColor(from startColor: UIColor, to endColor: UIColor, with fraction: CGFloat) -> UIColor {
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0

        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)

        let red = startRed + (endRed - startRed) * fraction
        let green = startGreen + (endGreen - startGreen) * fraction
        let blue = startBlue + (endBlue - startBlue) * fraction
        let alpha = startAlpha + (endAlpha - startAlpha) * fraction

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
