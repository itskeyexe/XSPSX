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
        ["Stealth Toolbox", "CPUP File Manager", "Music Tools", "Exit Toolbox", "Placeholder1", "Placeholder2"],
        ["Kernel Tools", "Flash LV0", "Flash LV1", "CFW Mode", ".rif Licenses", "Kernel Mode"],
        ["010011100", "Toggle QA Flag", "Aurora Sync", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Utilities", "XSPSX Developer Tools", "Placeholder1", "Placeholder2", "Placeholder3", "Placeholder4"],
    ]
    var optionsData = ["Option 1", "Option 2"]
    @IBOutlet weak var option1Btn: UIButton!
    @IBOutlet weak var option2Btn: UIButton!
    @IBOutlet weak var optionsView: UIView!
    var currentCategory: String?
    @IBOutlet weak var optionsTableView: UITableView!
    var currentSelectedItem: String?
    let categories = ["Stealth Toolbox", "System Tools", "Music Tools", "Utilities"]
    let musicFiles: [String] = ["Dark and Silence", "Safe House by Feather", "Okean Elzi  -  Obnimi (Callmearco Remix)",  "multiMAN Soundtrack (Official)","Stranger Things Theme Song (C418 REMIX)", "PlayStation 4 System Music - OFFICIAL Home Menu (HIGH QUALITY)"]
    var currentSongIndex = 0
    var selectedSegmentIndex = 0
    var lastSelectedIndexPath: IndexPath?
    @IBOutlet weak var cpuTempLabel: UILabel!
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
        optionsView.isHidden = true
        setupTableView()
        updateCPUTempLabel()
    }
    private func setupCustomSegmentedControl() {
        let segmentImages = ["toolbox000", "microchip", "wrench", "folder"] // Replace with actual image names
        customSegmentedControl.configure(withImageNames: segmentImages, selectedIndex: 0)
        customSegmentedControl.customDelegate = self
        view.addSubview(customSegmentedControl)
        customSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
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
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == optionsTableView {
            return optionsData.count
        } else {
            return categoryData[selectedSegmentIndex].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == optionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsCell", for: indexPath)
            let option = optionsData[indexPath.row]
            cell.textLabel?.text = option
            // Customize the options cell as needed
            return cell
        } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
                let rowData = categoryData[selectedSegmentIndex][indexPath.row]
                cell.textLabel?.text = rowData
                cell.backgroundColor = .clear

                // Set and resize the icon image
                if let iconImage = UIImage(named: "wrench")?.resizedImage(newSize: CGSize(width: 75, height: 75)) { // Adjust size as needed
                    cell.imageView?.image = iconImage
                }
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.clipsToBounds = true

                // Custom attributes for text
                let customYellow = UIColor(hex: "d4d300") ?? .white
                let fontSize: CGFloat = 17
                let attributedString = NSAttributedString(string: rowData, attributes: [
                    .strokeColor: UIColor.black,
                    .foregroundColor: customYellow,
                    .strokeWidth: -3.0,
                    .font: UIFont.systemFont(ofSize: fontSize)
                ])
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.textLabel?.attributedText = attributedString

                cell.selectionStyle = .none

                return cell
        }
    }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lastIndexPath = lastSelectedIndexPath, lastIndexPath == indexPath {
            // The same cell was tapped a second time
            performActionForItem(at: indexPath)
        } else {
            lastSelectedIndexPath = indexPath
            // Normal action for first tap
        }
    }
    
    private func performActionForItem(at indexPath: IndexPath) {
        let selectedItem = categoryData[selectedSegmentIndex][indexPath.row]
        // Add your switch or if-else logic here based on the selectedItem
        switch selectedItem {
        case "Exit Toolbox":
            AudioManager.shared.playSoundEffect()
            exitButtonPressed(self)
        case "CPUP File Manager":
            AudioManager.shared.playSoundEffect()
            launchDesktopViewController()
        case "Music Tools":
            AudioManager.shared.playSoundEffect()
            musicToolsView.isHidden = false
        case "Kernel Mode":
            AudioManager.shared.playSoundEffect()
            displayOptionsView()
        case "Toggle QA Flag":
            AudioManager.shared.playSoundEffect()
            displayOptionsView()
        default:
            break
        }
    }
    
    func displayOptionsView() {
        optionsView.isHidden = false
    }

    @IBAction func option1Pressed(_ sender: Any) {
        //these functions will set the cfw mode, lv1/2 system calls
        optionsView.isHidden = true
        showAlertWithIcon(message: "Option 1 Pressed", iconName: "toolbox000")
        //set retail mode
        //set Stealth mode
        //update the system data
        //share the new data tot he debug settings page
    }
    
    @IBAction func option2Pressed(_ sender: Any) {
        //these functions will set the cfw mode, lv1/2 system calls
        optionsView.isHidden = true
        showAlertWithIcon(message: "Option 2 Pressed", iconName: "toolbox000")
        //set retail mode
        //set Stealth mode
        //update the system data
        //share the new data tot he debug settings page
    }
    func segmentDidChange(to index: Int) {
        // Update the current category based on the selected index
        AudioManager.shared.playSoundEffect()
        tableView.isHidden = false
        optionsView.isHidden = true
        musicToolsView.isHidden = true
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




    


