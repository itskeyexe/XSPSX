//
//  XMBViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/19/23.
//
import UserNotifications
import UIKit
import AVKit
import AVFoundation
import WebKit
import Messages
import MessageUI



class XSPSXViewController: UIViewController, AVPlayerViewControllerDelegate, CustomSegmentedControlDelegate, UIScrollViewDelegate {
    func getDevHDD0Contents() -> [String] {
        return SystemData.shared.listFiles(at: SystemData.shared.baseDirectoryURL).map { $0.lastPathComponent }
    }
    var isJailbreakEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isJailbreakEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isJailbreakEnabled")
        }
    }
    @IBOutlet weak var themeOptionsView: UIView!
    @IBOutlet weak var themeOption1: UIButton!
    @IBOutlet weak var themeOption2: UIButton!
    @IBOutlet weak var themeOption3: UIButton!
    @IBOutlet weak var themeOption4: UIButton!
    var selectedTheme: Theme?
    var themes: [Theme] = [
           Theme(name: "Stars", videoFileName: "starsXMB"),
           Theme(name: "Xray", videoFileName: "Xray"),
           Theme(name: "Water", videoFileName: "underwaterXMB"),
           Theme(name: "XSPSX", videoFileName: "cyan4")
       ]
    // Add a property to keep track of the last selected item
    var isFirstTap = true
    var blinkingIndexPath: IndexPath?
    var selectedIndexPath: IndexPath?
    var lastSelectedIndexPath: IndexPath?
    var currentUpdateVersion: String = "XSPSX 1.11 OFW" // Default version
    var customSegmentedControl: CustomSegmentedControl!
    var selectedIndex: Int = 0
    let padding: CGFloat = 340
    //JailbreakViewUI elements// show these if the jailbreak toggle flag is enabled otherwise hide and disable the buttons and UI elements
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var cpuTempLabel: UILabel!
    @IBOutlet weak var gpuTempLabel: UILabel!
    //Package Installer view, this will be active and enabled if jailbreak mode is enabled and package manager is selected
    @IBOutlet weak var timeDateLabel: UILabel!
    var dateTimer: Timer?
    @IBOutlet weak var StatusLabelPkgMngr: UILabel!
    @IBOutlet weak var gameThumbnail: UIImageView!
    var tableView: UITableView!
    @IBOutlet weak var videoLayer: UIView!
    @IBOutlet weak var signInWebView: WKWebView!
    @IBOutlet weak var storeWebView: WKWebView!
    var backgroundAudioPlayer: AVAudioPlayer?
    var previousSelectedVerticalRow: Int?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var currentCategory: String?
    var currentSelectedItem: String?
    var previouslySelectedIndexPath: IndexPath?
    @IBOutlet weak var batteryIcon: UIImageView!
    var packageFileDirectoryDataSource = ["Install Package Files"]
    let batteryImageArray = ["battery0", "battery01", "battery02", "battery03"]
    let categories = ["Users","System", "Media", "Games", "Network", "Friends"]
    var categoryData = [
        ["itskeyexe", "Dill353", "log off", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["System Settings",  "System Info", "Transfer Utility", "XSPSX Themes", "Placeholder1", "Placeholder2"],
        ["Music Player", "Photo Gallery", "Video Player", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Save Data", "Games", "RetroArch", "Game Zero", "Placeholder1", "Placeholder2", "Placeholder3", "Placeholder4"],
        ["Sign in", "XSPSX Store", "Web Browser", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Online:", "Message", "Achievements", "Placeholder1", "Placeholder2", "Placeholder3"]
    ]
    let jailbrokenCategoryData = [
        ["itskeyexe", "Dill353", "log off", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["System Settings",  "System Info", "Transfer Utility", "XSPSX Themes", "Placeholder1", "Debug"],
        ["Music Player", "Photo Gallery", "Video Player", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Save Data", "Games", "RetroArch", "Game Zero", "Package Manager", "Update Spoofer", "Stealth Toolbox", "Syscall Enabler"],
        ["Sign in", "XSPSX Store", "Web Browser", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Online:", "Message", "Achievements", "Placeholder1", "Placeholder2", "Placeholder3"]
    ]
    let nonJailbrokenCategoryData = [
        ["itskeyexe", "Dill353", "log off", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["System Settings",  "System Info", "Transfer Utility", "XSPSX Themes", "Placeholder1", "Placeholder2"],
        ["Music Player", "Photo Gallery", "Video Player", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Save Data", "Games", "RetroArch", "Game Zero", "Placeholder1", "Placeholder2", "Placeholder3", "Placeholder4"],
        ["Sign in", "XSPSX Store", "Web Browser", "Placeholder1", "Placeholder2", "Placeholder3"],
        ["Online:", "Message", "Achievements", "Placeholder1", "Placeholder2", "Placeholder3"]
    ]
    //Systemdata
    func loadPackageFileDirectoryData() {
        let fileURLs = SystemData.shared.listFiles(at: SystemData.shared.gamesDirectoryURL)
        packageFileDirectoryDataSource = fileURLs.map { $0.lastPathComponent }
    }
    let iconMapping: [String: String] = [
        // Users category icons
        "itskeyexe": "folderStar",
        "Dill353": "folderStar",
        "log off": "folderStar",
        "Placeholder1": "folderStar",
        // System category icons
        "System Settings": "wrench",
        "XSPSX Themes": "themes",
        "System Info": "wrench",
        "Transfer Utility": "wrench",
        "Debug": "toolFolder",
        "Placeholder": "wrench",
        "placeholder": "wrench",
        // Media category icons
        "Music Player": "note",
        "Photo Gallery": "note",
        "Video Player": "note",
        // Games category icons
        "Games": "gameCover",
        "Save Data": "memoryCard",
        "RetroArch": "retroarch",
        "Game Zero": "gameZero",
        "Package Manager": "folderStar",
        "Update Spoofer": "spoofFolder",
        "Stealth Toolbox": "toolFolder",
        "Syscall Enabler": "folderStar",
        // Network category icons
        "Sign in": "pointer",
        "XSPSX Store": "storeIcon",
        "Web Browser": "browser0",
        // Friends category icons
        "Online:": "folderStar",
        "Message": "folderStar",
        "Achievements": "folderStar"
    ]
//Load View ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem = nil
        selectedTheme = themes.first(where: { $0.videoFileName == "starsXMB" }) ?? themes.first
        themeOptionsView.isHidden = true
        themeOption1.addTarget(self, action: #selector(themeOptionSelected(_:)), for: .touchUpInside)
        themeOption2.addTarget(self, action: #selector(themeOptionSelected(_:)), for: .touchUpInside)
        themeOption3.addTarget(self, action: #selector(themeOptionSelected(_:)), for: .touchUpInside)
        themeOption4.addTarget(self, action: #selector(themeOptionSelected(_:)), for: .touchUpInside)
                themeOption1.tag = 0
                themeOption2.tag = 1
                themeOption3.tag = 2
                themeOption4.tag = 3
        coldboot()
        gameThumbnail.alpha = 0
        gameThumbnail.isHidden = true
        loadPackageFileDirectoryData()
        currentUpdateVersion = SystemData.shared.currentUpdateVersion
        customSegmentedControl = CustomSegmentedControl()
        customSegmentedControl.customDelegate = self
        view.addSubview(customSegmentedControl)
        customSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            customSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -155),
            customSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customSegmentedControl.heightAnchor.constraint(equalToConstant: 120)
        ])
        tableView = UITableView()
        tableView.isScrollEnabled = true
        tableView.clipsToBounds = false
        tableView.isHidden = true
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding), // Adjust the trailing constraint
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(customSegmentedControl)
        customSegmentedControl.layer.zPosition = 1
        updateBatteryStatus()
        if tableView != nil {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("errror reloading")
        }
        updateDateTimeLabel()
        dateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDateTimeLabel), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAchievementUnlocked(_:)), name: .achievementUnlocked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        updateBatteryStatus()
        let isJailbreakEnabled = self.isJailbreakEnabled
        setupUIForJailbreak(isJailbreakEnabled)
        displayFakeIPAddress()
        SystemData.shared.currentUpdateVersion = "XSPSX 1.11 OFW"
        if isJailbreakEnabled {
            let jailbrokenCategoryData = [
                ["itskeyexe", "Dill353", "log off", "Placeholder1", "Placeholder2", "Placeholder3"],
                ["System Settings", "System Info", "Transfer Utility", "XSPSX Themes", "Placeholder1", "Debug"],
                ["Music Player", "Photo Gallery", "Video Player", "Placeholder1", "Placeholder2", "Placeholder3"],
                ["Save Data", "Games",  "RetroArch", "Game Zero", "Package Manager", "Update Spoofer", "Stealth Toolbox", "Syscall Enabler"],
                ["Sign in", "XSPSX Store", "Web Browser", "Placeholder1", "Placeholder2", "Placeholder3"],
                ["Online:", "Message", "Achievements", "Placeholder1", "Placeholder2", "Placeholder3"]
            ]
            categoryData = jailbrokenCategoryData
            customSegmentedControl.setupSegments(imageNames: ["user","settings", "note", "controller", "xspsxinjtrClearPlus", "friends"]) // Replace with your actual image names
            startUpdatingCPUTempLabel()
            startUpdatingGPUTempLabel()
            SystemData.shared.currentUpdateVersion = "XSPSX Stealth Eternal 1.11 CFW"
            if tableView != nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("errror reloading")
            }
        } else {
            customSegmentedControl.setupSegments(imageNames: ["user","settings", "note", "controller", "globe", "friends"]) 
            categoryData = nonJailbrokenCategoryData
            if tableView != nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("errror reloading")
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(cpuTempLabel)
        view.bringSubviewToFront(gpuTempLabel)
        view.bringSubviewToFront(ipAddressLabel)
        view.bringSubviewToFront(timeDateLabel)
        view.bringSubviewToFront(batteryIcon)
        view.bringSubviewToFront(gameThumbnail)
        view.bringSubviewToFront(customSegmentedControl)
        let topInset = customSegmentedControl.frame.maxY
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    @IBAction func themeOptionSelected(_ sender: UIButton) {
            selectedTheme = themes[sender.tag]
            coldboot()
            themeOptionsView.isHidden = true
            view.sendSubviewToBack(themeOptionsView)
            tableView.isHidden = false
            tableView.reloadData()
            view.bringSubviewToFront(tableView)
            print("Theme changed and table view updated")
        }
    @IBAction func unwindFromSystemSettings(segue: UIStoryboardSegue) {
        if let systemSettingsVC = segue.source as? SystemSettingsViewController {
            isJailbreakEnabled = systemSettingsVC.isJailbreakEnabled
        } else if let coldBootVC = segue.source as? ColdBootViewController {
            isJailbreakEnabled = coldBootVC.isJailbreakEnabled
        }
        updateUIBasedOnJailbreakStatus()
    }
    func segmentTapped(at index: Int) {
        selectedIndex = index
        if tableView != nil {
            tableView.isHidden = false // Unhide the tableView when a segment is tapped
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("table should show and data reloaded")
            }
        }
    }
    func segmentDidChange(to index: Int) {
        selectedIndex = index
        tableView.isHidden = false
        gameThumbnail.isHidden = true
        guard selectedIndex < categoryData.count else {
            print("Invalid selectedIndex: \(selectedIndex)")
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let firstItemIndexPath = IndexPath(row: 0, section: 0)
            if self.tableView.numberOfRows(inSection: 0) > 0 {
                self.tableView.scrollToRow(at: firstItemIndexPath, at: .top, animated: false)
            }
        }
    }
    private func updateCellAppearance(at indexPath: IndexPath, in tableView: UITableView, isHighlighted: Bool) {
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    func highlightCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
    }
    func unhighlightCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
    }
//XMB Styling---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    func performActionForSelectedItem(_ item: String, inCategory category: String) {
        switch category {
        case "Games":
            switch item {
            case "Games":
                AudioManager.shared.playSoundEffect()
                presentGameCoverViewController()
            case "Save Data":
                AudioManager.shared.playSoundEffect()
            case "RetroArch":
                AudioManager.shared.playSoundEffect()
                launchEmbeddedApp() //try to launch emulator
            case "Game Zero":
                AudioManager.shared.playSoundEffect()
                launchGameBootViewController()
            case "Package Manager":
                    if isJailbreakEnabled {
                        AudioManager.shared.playSoundEffect()
                        showPackageManager()
                        showAlertWithIcon(message: "Package Installer Enabled", iconName: "folder")
                    } else {
                        let alert = UIAlertController(title: "[!]Invalid Access[!]", message: "Jailbreak System Software to Enable this Program!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        AudioManager.shared.playSoundEffect0()
                    }
                    break
            case "Update Spoofer":
                if isJailbreakEnabled {
                    AudioManager.shared.playSoundEffect()
                    launchSpooferViewController()
                } else {
                    // Handle the non-jailbroken scenario, if applicable
                    AudioManager.shared.playSoundEffect0()
                    // Create the alert
                    let alert = UIAlertController(title: "[!]Invalid Access[!]", message: "Jailbreak System Software to Enable this Program!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                break
            case "Stealth Toolbox":
                if isJailbreakEnabled {
                    AudioManager.shared.playSoundEffect()
                    let alert = UIAlertController(title: "Launching!", message: "Stealth Toolbox", preferredStyle: .alert)
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = UIImage(named: "stealth00001")
                    alert.view.addSubview(imageView)
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                        imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 45),
                        imageView.widthAnchor.constraint(equalToConstant: 250),
                        imageView.heightAnchor.constraint(equalToConstant: 250)
                    ])
                    self.present(alert, animated: true, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            alert.dismiss(animated: true, completion: {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let newViewController = storyboard.instantiateViewController(withIdentifier: "RsxToolboxViewController")
                                newViewController.view.alpha = 0
                                self.present(newViewController, animated: false, completion: {
                                    UIView.animate(withDuration: 0.3, animations: {
                                        newViewController.view.alpha = 1
                                    })
                                })
                            })
                        }
                    })
                } else {
                    // Handle the non-jailbroken scenario
                    AudioManager.shared.playSoundEffect0()
                    let alert = UIAlertController(title: "[!]Invalid Access[!]", message: "Jailbreak System Software to Enable this Program!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                break
            case "Syscall Enabler":
                if isJailbreakEnabled {
                    // Toggle the syscall flag
                    let currentToggleState = SystemData.shared.syscallToggle
                    SystemData.shared.syscallToggle = !currentToggleState
                    AudioManager.shared.playFeatUnlockedSoundEffect()
                    // Prepare the alert message
                    let toggleStateMessage = SystemData.shared.syscallToggle ? "Disabled" : "Enabled"
                    let alertMessage = "CFW Syscalls \(toggleStateMessage)"
                    let alertViewController = UIViewController()
                    alertViewController.view.backgroundColor = UIColor.clear
                    alertViewController.modalPresentationStyle = .overFullScreen
                    let customView = UIView()
                    customView.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Semi-transparent black
                    customView.layer.cornerRadius = 10 // Rounded corners
                    let screenWidth = UIScreen.main.bounds.width
                    let customViewWidth: CGFloat = 260 // Adjust the width as needed
                    let customViewHeight: CGFloat = 80 // Adjust the height as needed
                    let xPosition = screenWidth - customViewWidth - 20 // 20 points padding from the right edge
                    let yPosition: CGFloat = 20 // 20 points padding from the top edge
                    customView.frame = CGRect(x: xPosition, y: yPosition, width: customViewWidth, height: customViewHeight)
                    let trophyImageView = UIImageView(image: UIImage(named: "syscall")) // Add your trophy icon to the assets
                    trophyImageView.contentMode = .scaleAspectFit
                    trophyImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
                    let label = UILabel()
                    label.frame = CGRect(x: 80, y: 10, width: customViewWidth - 90, height: 60)
                    label.text = alertMessage
                    label.textColor = .white
                    label.numberOfLines = 2
                    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                    label.textAlignment = .left
                    customView.addSubview(trophyImageView)
                    customView.addSubview(label)
                    alertViewController.view.addSubview(customView)
                    alertViewController.view.alpha = 0
                    self.present(alertViewController, animated: false) {
                        UIView.animate(withDuration: 0.5, animations: {
                            customView.frame = CGRect(x: xPosition, y: yPosition + 50, width: customViewWidth, height: customViewHeight)
                            alertViewController.view.alpha = 1
                        }, completion: { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                UIView.animate(withDuration: 0.5, animations: {
                                    customView.frame = CGRect(x: xPosition, y: yPosition, width: customViewWidth, height: customViewHeight)
                                    alertViewController.view.alpha = 0
                                }, completion: { _ in
                                    alertViewController.dismiss(animated: false, completion: nil)
                                })
                            }
                        })
                    }
                } else {
                    let alert = UIAlertController(title: "[!]Invalid Access[!]", message: "Jailbreak System Software to Enable this Program!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                break
            default:
                AudioManager.shared.playBackEffect()
            }
        case "Media":
            switch item {
            case "Music Player":
                AudioManager.shared.playSoundEffect()
                launchMusicPlayerViewController()
            case "Photo Gallery":
                AudioManager.shared.playSoundEffect()
                launchFavoritesAlbumViewController()
            case "Video Player":
                AudioManager.shared.playSoundEffect()
                launchVideoPlayerViewController()
            default:
                break
            }
        case "System":
            switch item {
            case "System Settings":
                AudioManager.shared.playSoundEffect()
                launchSystemSettingsViewController()
            case "System Info":
                AudioManager.shared.playSoundEffect()
                let alert = UIAlertController(title: "About XSPSX", message: "Mini iOS Console Developed by itskeyexe", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case "Transfer Utility":
                AudioManager.shared.playSoundEffect()
                let alert = UIAlertController(title: "Data Transfer Utility", message: "Send and Recieve Files/Data/Saves/Games to another users console coming soon.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case "XSPSX Themes":
                AudioManager.shared.playSoundEffect()
                print("themes view should be showing")
                        themeOptionsView.isHidden = false
                view.bringSubviewToFront(themeOptionsView)
            case "Debug":
                AudioManager.shared.playSoundEffect()
                let alert = UIAlertController(title: "[!]Invalid Access[!]", message: "You must be a Dev or Jailbreak System Software to Enable this Program!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        case "Network":
            switch item {
            case "Sign in":
                AudioManager.shared.playSoundEffect()
                checkSystemStatusBeforeSignIn() // Then perform system checks
            case "XSPSX Store":
                AudioManager.shared.playSoundEffect()
                  if let storeURL = URL(string: "https://xspsxinjector.me/store.html") {
                      let request = URLRequest(url: storeURL)
                      storeWebView.load(request) // Corrected to use storeWebView
                  }
                  storeWebView.isHidden = false
                  UIView.animate(withDuration: 3.0) {
                      self.storeWebView.alpha = 1.0
                  }
                  view.bringSubviewToFront(storeWebView)
                  addCloseButtonToStoreWebView()
            case "Web Browser":
                AudioManager.shared.playSoundEffect()
                launchWebBrowser()
            default:
                break
            }
        case "Friends":
            if item == "Online:" {
                AudioManager.shared.playSoundEffect()
            } else if item == "Message" {
                let messagingVC = MessagingViewController()
                self.present(messagingVC, animated: true, completion: nil)
                AudioManager.shared.playSoundEffect()
            } else if item == "Achievements" {
                AudioManager.shared.playSoundEffect()
            }
            break
       
        default:
            AudioManager.shared.playSoundEffect()
        }
    }
    func loadSignInPage() {
        if let loginURL = URL(string: "https://xspsxinjector.me/login.html") {
            let request = URLRequest(url: loginURL)
            signInWebView.load(request)
            signInWebView.isHidden = false
            UIView.animate(withDuration: 3.0) {
                self.signInWebView.alpha = 1.0
            }
            view.bringSubviewToFront(signInWebView)
            addCloseButtonToSignInWebView()
        }
    }
    func checkSystemStatusBeforeSignIn() {
        let currentVersion = SystemData.shared.currentUpdateVersion
        let isJailbroken = UserDefaults.standard.bool(forKey: "isJailbreakEnabled")
        let isSyscallToggled = UserDefaults.standard.bool(forKey: "syscallToggle")
        let minimumVersion = "1.11 OFW"
        let customFirmwareMinimumVersion = "1.16 OFW"
        let maximumAllowedVersion = "9.99 OFW"
        let versionComparison = compareVersions(currentVersion, minimumVersion)
        let customFirmwareComparison = compareVersions(currentVersion, customFirmwareMinimumVersion)
        _ = compareVersions(currentVersion, maximumAllowedVersion)
        DispatchQueue.main.async { [weak self] in
            if versionComparison == .orderedAscending {
                // Firmware version is too low
                self?.showAlert(message: "Please update to the latest firmware version to access online services.")
            } else if isJailbroken && !isSyscallToggled && customFirmwareComparison != .orderedDescending {
                // Jailbroken, syscall toggle is off, and firmware is not high enough
                self?.showAlert(message: "Custom firmware detected, please update to minimum version of 1.16 OFW to access online services or risk the BANNING of your XSPSX account.")
            } else {
                // Conditions are met, either not jailbroken or syscall toggle is on
                self?.loadSignInPage()
            }
        }
    }
    func getThumbnailName(for item: String) -> String {
        switch item {
        case "Games": return "darkThumbTestTemplate"
        case "Save Data": return "darkThumbTestTemplateSave"
        case "RetroArch": return "darkThumbTestTemplateRetroArch"
        case "Game Zero": return "darkThumbTestTemplateGame0"
        case "Package Manager": return "blankThumb"
        case "Music Player": return "darkThumbTestTemplateMusic"
        case "Photo Gallery": return "darkThumbTest0"
        case "Video Player": return "darkThumbTest0"
        case "Sign in": return "darkThumbTest0"
        case "XSPSX Store": return "darkThumbTestTemplateStore"
        case "Web Browser": return "darkThumbTestTemplateBrowser"
        case "Achievements": return "darkThumbTestTemplateFeats"
        case "Update Spoofer": return "darkThumbTestTemplateSpoofer"
        case "Stealth Toolbox": return "darkThumbTestTemplateToolbox"
        case "Syscall Toggler": return "darkThumbTestTemplateSyscalls"
        default: return "blankThumb"
        }
    }
    func resetTableViewState() {
        isFirstTap = true
        if isJailbreakEnabled {
            categoryData = jailbrokenCategoryData
        } else {
            categoryData = nonJailbrokenCategoryData
        }
        if let indexPath = selectedIndexPath {
            tableView.reloadData()
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        selectedIndexPath = nil
    }
//Will be used to handle package manager------------------------------------------------------------------------------------------------------------------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI() // Call the refresh method
    }
    func refreshUI() {
            // Reload the table view data
            tableView.reloadData()
            // Reset any other UI elements or states as needed
        }
    func performStatusLabelAnimation() {
        AudioManager.shared.playBackEffect()
        let messages = [" [!] Initializing. [!] ", " [!] Running Kernel Exploit. [!] ", " [!] Successfully Installed. [!] ", " [!] System Execution now Available. [!] "]
        let totalDuration = 5.26
        let singleMessageDuration = totalDuration / Double(messages.count)
        for (index, message) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + singleMessageDuration * Double(index)) {
                self.StatusLabelPkgMngr.text = message
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.showOtherElementsWithFlicker()
        }
    }
    func showOtherElementsWithFlicker() {
        let elementsToShow: [UIView] = []
        elementsToShow.forEach { $0.isHidden = false }
        elementsToShow.forEach { element in
            UIView.animate(withDuration: 0.1, animations: {
                element.alpha = 0
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    element.alpha = 1
                }
            }
        }
    }
    func showThumbnailForSelectedItem(_ item: String) {
        let thumbnailName = getThumbnailName(for: item)
        gameThumbnail.image = UIImage(named: thumbnailName)
        gameThumbnail.isHidden = false
        gameThumbnail.alpha = 0 // Start with transparent
        UIView.animate(withDuration: 1.0, animations: {
            self.gameThumbnail.alpha = 1.0 // Animate to fully visible
        })
    }
    func addCloseButtonToSignInWebView() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal) // System close icon
        closeButton.addTarget(self, action: #selector(closeSignInWebView), for: .touchUpInside)
        closeButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        closeButton.tag = 1001
        signInWebView.superview?.addSubview(closeButton)
    }
    @objc func closeSignInWebView() {
        // Animating the disappearance
        UIView.animate(withDuration: 1.0) {
            self.signInWebView.alpha = 0.0
        } completion: { _ in
            self.signInWebView.isHidden = true
            // Hide the close button here
            self.signInWebView.superview?.viewWithTag(1001)?.isHidden = true
        }
        signInWebView.superview?.sendSubviewToBack(signInWebView)
    }
    func addCloseButtonToStoreWebView() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal) // System close icon
        closeButton.addTarget(self, action: #selector(closeStoreWebView), for: .touchUpInside)
        closeButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        closeButton.tag = 1002
        storeWebView.superview?.addSubview(closeButton)
    }
    @objc func closeStoreWebView() {
        UIView.animate(withDuration: 1.0) {
            self.storeWebView.alpha = 0.0
        } completion: { _ in
            self.storeWebView.isHidden = true
            self.signInWebView.superview?.viewWithTag(1002)?.isHidden = true
        }
        storeWebView.superview?.sendSubviewToBack(storeWebView)
    }
    func launchWebBrowser() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController")
        player?.pause()
        newViewController.view.alpha = 0
        self.present(newViewController, animated: false, completion: {
            // Perform fade-in animation with a duration of 0.3 seconds
            UIView.animate(withDuration: 0.3, animations: {
                newViewController.view.alpha = 1
            })
        })
    }
    private func updateUIBasedOnJailbreakStatus() {
          if isJailbreakEnabled {
              categoryData = jailbrokenCategoryData // Your jailbreak-enabled data array
              ipAddressLabel.isHidden = false
              view.bringSubviewToFront(ipAddressLabel)
              setupUIForJailbreak(isJailbreakEnabled)
              AudioManager.shared.playBackgroundAudio(fileName:"Dark and Silence")
          } else {
              categoryData = nonJailbrokenCategoryData // Your default data array
              ipAddressLabel.isHidden = true
              AudioManager.shared.stopBackgroundAudio()
          }
          DispatchQueue.main.async {
                  self.tableView.reloadData()
              }
          displayFakeIPAddress()
          player?.play()
      }
      @objc func batteryLevelDidChange(notification: Notification) {
          DispatchQueue.main.async {
              self.updateBatteryStatus()
          }
      }
      func updateBatteryStatus() {
          UIDevice.current.isBatteryMonitoringEnabled = true
          let batteryLevel = UIDevice.current.batteryLevel
          if batteryLevel >= 0.75 {
              batteryIcon.image = UIImage(named: batteryImageArray[0])
          } else if batteryLevel >= 0.5 {
              batteryIcon.image = UIImage(named: batteryImageArray[1])
          } else if batteryLevel >= 0.25 {
              batteryIcon.image = UIImage(named: batteryImageArray[2])
          } else {
              batteryIcon.image = UIImage(named: batteryImageArray[3])
          }
      }
      @objc func handleAchievementUnlocked(_ notification: Notification) {
          if let achievement = notification.userInfo?["achievement"] as? Achievement {
              self.showAlertWithIcon(message: achievement.title, iconName: achievement.iconName)
          }
      }
      override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          if isJailbreakEnabled {
              showAlertWithIcon(message: "ETERNAL!", iconName: "stealth00001")
              refreshUI()
          } else {
              showAlertWithIcon(message: "Welcome to XSPSX!", iconName: "featsTrophy")
          }
          DispatchQueue.main.async {
              self.tableView.reloadData()
          }
      }
// Deep Functions for nav -------------------------------------------------------------------------------------------------------------------------------------------------------------
    func showPackageManager() {
        
        DispatchQueue.main.async {
            let packageManagerVC = PackageManagerViewController()
            packageManagerVC.modalPresentationStyle = .overFullScreen // or .overCurrentContext
            self.present(packageManagerVC, animated: true, completion: nil)
        }
       

    }
    
    func presentGameCoverViewController() {
        let gameCoverViewController = GameCoverViewController()
        DispatchQueue.main.async {
            self.present(gameCoverViewController, animated: true, completion: nil)
        }
    }

    func launchSystemSettingsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let systemSettingsVC = storyboard.instantiateViewController(withIdentifier: "SystemSettingsViewController") as? SystemSettingsViewController else {
            return // Failed to instantiate the view controller
        }
        player?.pause()
        self.present(systemSettingsVC, animated: true, completion: nil)
    }
    func launchSpooferViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let spooferVC = storyboard.instantiateViewController(withIdentifier: "SpooferViewController") as? SpooferViewController else {
            return
        }
        player?.pause()
        self.present(spooferVC, animated: true, completion: nil)
    }
    func launchVideoPlayerViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let videoPlayerVC = storyboard.instantiateViewController(withIdentifier: "VideoPlayerViewController") as? VideoPlayerViewController else {
            return
        }
        player?.pause()
        self.present(videoPlayerVC, animated: true, completion: nil)
    }
    func launchDesktopViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let desktopVC = storyboard.instantiateViewController(withIdentifier: "DesktopViewController") as? DesktopViewController else {
            return
        }
        player?.pause()
        self.present(desktopVC, animated: true, completion: nil)
    }
//RetroArch Launch -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    func launchEmbeddedApp() {
     //launch the main retroarch emulator
        //this is the brains of the console
    }
    func compareVersions(_ v1: String, _ v2: String) -> ComparisonResult {
        // Function to extract the numeric part of the version string
        func extractNumericVersion(_ version: String) -> [Int] {
            let components = version.components(separatedBy: CharacterSet.decimalDigits.inverted)
            return components.compactMap { Int($0) }
        }
        let versionNumbers1 = extractNumericVersion(v1)
        let versionNumbers2 = extractNumericVersion(v2)
        for (num1, num2) in zip(versionNumbers1, versionNumbers2) {
            if num1 < num2 {
                return .orderedAscending
            } else if num1 > num2 {
                return .orderedDescending
            }
        }
        return versionNumbers1.count < versionNumbers2.count ? .orderedAscending : versionNumbers1.count > versionNumbers2.count ? .orderedDescending : .orderedSame
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "System Check", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func launchMusicPlayerViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let musicVC = storyboard.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController else {
            return
        }
        player?.pause()
        self.present(musicVC, animated: true, completion: nil)
        
    }
    func launchGameBootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let desktopVC = storyboard.instantiateViewController(withIdentifier: "GameBootViewController") as? GameBootViewController else {
            return
        }
        player?.pause()
        self.present(desktopVC, animated: true, completion: nil)
    }
    func launchFavoritesAlbumViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let photoVC = storyboard.instantiateViewController(withIdentifier: "FavoritesAlbumViewController") as? FavoritesAlbumViewController else {
            return
        }
        player?.pause()
        self.present(photoVC, animated: true, completion: nil)
    }
    @IBAction func closePkgButtonPressed(_ sender: Any) {

    }
    private func startDownloadProcess() {
        let progressView = downloadPkgProgressView(frame: view.bounds)
        view.addSubview(progressView)
        progressView.onCancel = { [weak progressView] in
            progressView?.removeFromSuperview()
            // Perform any additional cancellation handling here
        }
        // Start updating the progress - this should be tied to your actual download logic
        updateDownloadProgress(progressView: progressView, progress: 0)
    }
    private func updateDownloadProgress(progressView: downloadPkgProgressView, progress: Float) {
        var currentProgress = progress
        let progressIncrement = 1.0 / 7 // Increment progress to complete in 7 seconds
        currentProgress += Float(progressIncrement)
        if currentProgress >= 1.0 {
            progressView.updateProgress(1.0)
            // Handle completion of download here
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Delay for demonstration
                progressView.removeFromSuperview()
            }
        } else {
            progressView.updateProgress(currentProgress)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.updateDownloadProgress(progressView: progressView, progress: currentProgress)
            }
        }
    }

    func coldboot() {
         // Check if a theme is selected and the video file exists
         guard let theme = selectedTheme,
               let path = Bundle.main.path(forResource: theme.videoFileName, ofType: "mp4") else {
             return
         }

         // Create an AVPlayer with the video URL
         let player = AVPlayer(url: URL(fileURLWithPath: path))

         // Create an AVPlayerLayer to display the video
         let playerLayer = AVPlayerLayer(player: player)
         playerLayer.frame = self.view.bounds
         playerLayer.videoGravity = .resizeAspectFill

         // Add the player layer to the view's layer
         self.view.layer.addSublayer(playerLayer)

         // Observe the notification for when the video finishes playing
         NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

         // Keep references to the player and player layer
         self.player = player
         self.playerLayer = playerLayer

         // Start playing the video
         player.play()
     }
    
    @objc func updateDateTimeLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "[MMM dd, yyyy HH:mm:ss]"
        let currentDateTime = Date()
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        timeDateLabel.text = formattedDateTime
    }
    func startUpdatingCPUTempLabel() {
        guard isJailbreakEnabled else {
            return
        }
        updateCPUTempLabel()
        Timer.scheduledTimer(timeInterval: 180.0, target: self, selector: #selector(updateCPUTempLabel), userInfo: nil, repeats: true)
    }
    @objc func updateCPUTempLabel() {
        let randomTemp = Int.random(in: 37...69)
        cpuTempLabel.text = "CPU: \(randomTemp)°C"
    }
    @objc func updateGPUTempLabel() {

        let randomTemp = Int.random(in: 37...69)
        gpuTempLabel.text = "RSX GPU: \(randomTemp)°C"
    }
    func startUpdatingGPUTempLabel() {
        guard isJailbreakEnabled else {
            return
        }
        updateGPUTempLabel()
        Timer.scheduledTimer(timeInterval: 180.0, target: self, selector: #selector(updateGPUTempLabel), userInfo: nil, repeats: true)
    }
    func generateRandomNumber() -> Int {
        return Int.random(in: 0...255)
    }
    @objc func videoDidFinishPlaying(_ notification: Notification) {
        guard let player = player else {
            return
        }
        player.seek(to: .zero)
        player.play()
    }
    func displayFakeIPAddress() {
        let number1 = generateRandomNumber()
        let number2 = generateRandomNumber()
        let number3 = generateRandomNumber()
        let number4 = generateRandomNumber()
        let fakeIPAddress = "\(number1).\(number2).\(number3).\(number4)"
        ipAddressLabel.text = "Connected: \(fakeIPAddress)"
    }
    @objc func appDidEnterBackground() {
        // No longer resetting the jailbreak flag here
        // isJailbreakEnabled = false
    }
    private func setupUIForJailbreak(_ enabled: Bool) {
            ipAddressLabel.isHidden = !enabled
            // Enable interaction for the UI elements when jailbreak is enabled
            ipAddressLabel.isUserInteractionEnabled = enabled
            print("jailbreak enabled views should be visiblex2")
        }
    @objc func appWillTerminate() {
        // Clear the user defaults to revert to non-jailbreak mode
        // Reset the jailbreak flag when the app is about to terminate
        isJailbreakEnabled = false
        UserDefaults.standard.removeObject(forKey: "isJailbreakEnabled")
    }
    deinit {
        // Remove the observer when the view controller is deallocated
        dateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    func relaunchApp() {
        if let url = URL(string: "myapp://xspsxrsx") {

            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    print("Failed to relaunch the app.")
                    exit(0)
                }
            }
        }
    }
}
class downloadPkgProgressView: UIView {
    var onCancel: (() -> Void)?
    let progressBar = UIProgressView(progressViewStyle: .default)
    private let cancelButton = UIButton()
    let statusLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        self.backgroundColor = .black
        self.alpha = 0.88
        self.addSubview(progressBar)
        self.addSubview(cancelButton)
        self.addSubview(statusLabel)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = .limeGreen
        cancelButton.setTitle(" ", for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.text = " "
        NSLayoutConstraint.activate([
            progressBar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            progressBar.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
            cancelButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            cancelButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 200),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            statusLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10),
            statusLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    @objc private func cancelButtonTapped() {
        onCancel?()
    }
    func updateProgress(_ progress: Float) {
        progressBar.setProgress(progress, animated: true)
        let progressPercentage = Int(progress * 100)
        cancelButton.setTitle("Installing... \(progressPercentage)%", for: .normal)
        if progressPercentage >= 90 {
            cancelButton.setTitle("pkg file 1.11 Installed!", for: .normal)
        } else if progressPercentage == 100 {
            cancelButton.setTitle("pkg file 1.11 Installed!", for: .normal)
        }
    }
}

class Theme {
    var name: String
    var videoFileName: String

    init(name: String, videoFileName: String) {
        self.name = name
        self.videoFileName = videoFileName
    }
}

extension XSPSXViewController: PackageManagerDelegate {
    func packageManagerDidFinish() {
        refreshUI()
    }
}
