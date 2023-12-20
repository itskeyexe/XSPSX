//
//  RsxToolboxViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/27/23.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import WebKit


class RsxToolboxViewController: UIViewController, AVPlayerViewControllerDelegate, CustomSegmentedControlDelegate, UITableViewDataSource, UITableViewDelegate {
        var isJailbroken: Bool = false {
            didSet {
                if isJailbroken {
                    AudioManager.shared.playDefaultBackgroundMusic()
                } else {
                    AudioManager.shared.stopBackgroundAudio()
                }
            }
        }
    var categoryData = [
        ["Stealth Toolbox", "CPUP File Manager", "Exit", "Placeholder", "Placeholder1", "Placeholder2"],
        ["Kernel Tools", "XSPSX Themes", "System Info", "Transfer Utility", "Placeholder1", "Placeholder2"],
        ["Music Tools", "Photo Gallery", "Video Player", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Utilities", "Game Zero", "Placeholder1", "Placeholder2", "Placeholder3", "Placeholder4"],
    ]
    var currentCategory: String?
    var currentSelectedItem: String?
    let categories = ["Stealth Toolbox", "System Tools", "Music Tools", "Utilities"]
    let musicFiles: [String] = ["Dark and Silence", "Safe House by Feather", "Okean Elzi  -  Obnimi (Callmearco Remix)",  "multiMAN Soundtrack (Official)","Stranger Things Theme Song (C418 REMIX)", "PlayStation 4 System Music - OFFICIAL Home Menu (HIGH QUALITY)"]
    var currentSongIndex = 0
    var selectedSegmentIndex = 0

    @IBOutlet weak var cpuTempLabel: UILabel!
    @IBOutlet weak var systemToolsButton: UIButton!
    // Add CustomSegmentedControl property
    var customSegmentedControl = CustomSegmentedControl()
    var tableView: UITableView!
    let padding: CGFloat = 390 // Adjust as needed
    //music tools view
    @IBOutlet weak var musicToolsView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var customMxTitle: UILabel!
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var animeView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    var player: AVPlayer?
    var playerLooper: AVPlayerLooper?
    // Jailbroken mode toggle Flag (assuming you have this flag here)
    var isJailbreakEnabled = Bool()
    // Property to hold the selected theme color
    var selectedThemeColor: UIColor?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoLoop()
        setupCustomSegmentedControl()
        isJailbroken = true
        musicToolsView.isHidden = true
        setupTableView()
        updateCPUTempLabel()
    }
    private func setupCustomSegmentedControl() {
        let segmentImages = ["toolbox000", "wrench", "microchip", "folder"] // Replace with actual image names
        customSegmentedControl.configure(withImageNames: segmentImages, selectedIndex: 0)
        customSegmentedControl.customDelegate = self
        view.addSubview(customSegmentedControl)
        customSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        // Set constraints for customSegmentedControl
        NSLayoutConstraint.activate([
            customSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            customSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            customSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            customSegmentedControl.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = true
        tableView.clipsToBounds = true
        tableView.isHidden = true
        tableView.backgroundColor = .clear // Set table view background to clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: customSegmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 385), // Increased padding
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryData[selectedSegmentIndex].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
              let rowData = categoryData[selectedSegmentIndex][indexPath.row]
              cell.textLabel?.text = rowData
           cell.backgroundColor = .clear
           cell.imageView?.image = UIImage(named: "wrench")
           cell.imageView?.contentMode = .scaleAspectFit
           cell.imageView?.clipsToBounds = true
           cell.layoutSubviews()
           return cell
       }

    func segmentDidChange(to index: Int) {
        // Update the current category based on the selected index
        tableView.isHidden = false
        selectedSegmentIndex = index
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlertWithIcon(message: "Welcome to Stealth Toolbox", iconName: "toolbox000")
    }
    @IBAction func systemToolsPressed(_ sender: Any) {
        AudioManager.shared.playSoundEffect()
       launchDesktopViewController()
    }
    func launchDesktopViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let desktopVC = storyboard.instantiateViewController(withIdentifier: "DesktopViewController") as? DesktopViewController else {
            return
        }
        player?.pause()
        self.present(desktopVC, animated: true, completion: nil)
    }
    @objc func updateCPUTempLabel() {
        let randomTemp = Int.random(in: 37...69)
        cpuTempLabel.text = "CPU \(randomTemp)°C"
    }
    func generateRandomNumber() -> Int {
        return Int.random(in: 0...255)
    }
    func displayFakeIPAddress() {
    }
    func setupVideoLoop() {
        if let videoURL = Bundle.main.url(forResource: "cyan4", withExtension: "mp4") {
            let playerItem = AVPlayerItem(url: videoURL)
                let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                            playerLayer.videoGravity = .resizeAspectFill
                                playerLayer.frame = view.bounds
                        view.layer.insertSublayer(playerLayer, at: 0)
            player.play()
            self.player = player
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }
    func updateSongDisplay() {
        let currentSong = musicFiles[currentSongIndex]
        songTitle.text = currentSong
        updateBackgroundAudio(with: currentSong)
    }
    @IBAction func nextSongButtonPressed(_ sender: Any) {
        currentSongIndex = (currentSongIndex + 1) % musicFiles.count
        updateSongDisplay()
    }
    @IBAction func previousSongButtonPressed(_ sender: Any) {
        currentSongIndex = (currentSongIndex - 1 + musicFiles.count) % musicFiles.count
        updateSongDisplay()
    }
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        AudioManager.shared.toggleMute()

        // Update button title based on the mute state
        let buttonTitle = AudioManager.shared.isMuted() ? "Unmute" : "Mute"
        playPauseButton.setTitle(buttonTitle, for: .normal)
    }
    func updateBackgroundAudio(with musicFile: String) {
        AudioManager.shared.stopBackgroundAudio()
        AudioManager.shared.playBackgroundAudio(fileName: musicFile)
    }
    @IBAction func exitButtonPressed(_ sender: Any) {
        AudioManager.shared.playSoundEffect()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController")
                    newViewController.view.alpha = 0
                        self.present(newViewController, animated: false, completion: {
                            UIView.animate(withDuration: 0.3, animations: {
                                        newViewController.view.alpha = 1
                })
            })
        }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}




    


