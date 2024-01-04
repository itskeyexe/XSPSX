//
//  SystemSettingsViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/25/23.
//

import UIKit
import AVKit
import AVFoundation
import WebKit

class SystemSettingsViewController: UIViewController, AVPlayerViewControllerDelegate, UITableViewDataSource {
    var isJailbreakEnabled = Bool() // Jailbroken mode toggle Flag
    var currentUpdateVersion = "XSPSX 1.11 OFW"
    @IBOutlet weak var viewSettings: UIView!
    private var currentStepIndex = 0
    var cellTapCounts = [IndexPath: Int]()
    var settingsOptionsArray = ["        System Settings v1.01", "About This Console", "Update System Firmware", "Sound Settings", "Toggle Mute", "Data Transfer Utility", "Exit Settings"]
    @IBOutlet weak var settingsTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptionsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = settingsOptionsArray[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.backgroundColor = UIColor.clear // If the text label has its own background
        if indexPath.row != 0 {
            cell.imageView?.image = UIImage(named: "wrench")
        } else {
            cell.imageView?.image = nil
        }
        cell.textLabel?.textColor = UIColor.white

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
           settingsTableView.dataSource = self
           settingsTableView.delegate = self  // Set the delegate
           settingsTableView.reloadData()
            settingsTableView.backgroundColor = UIColor.clear
            settingsTableView.separatorColor = UIColor.clear // If you want to remove the separator lines
        if isJailbreakEnabled {
            currentUpdateVersion = SystemData.shared.currentUpdateVersion
        } else if !isJailbreakEnabled {
            currentUpdateVersion = SystemData.shared.currentUpdateVersion
        }
                    
    }
    func updateButtonPressed(_ sender: Any) {
        // Simulate the update search
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            self.showUpdateNotification()
        }
    }
    func aboutButtonPressed(_ sender: Any) {
        // Create the alert
        let alert = UIAlertController(title: "System Name: My XSPSX", message: "Current update version: \(currentUpdateVersion)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func showUpdateNotification() {
        let updateView = UpdateNotificationView()
        updateView.frame = self.view.bounds // Adjust frame as needed
        self.view.addSubview(updateView)

        updateView.onCancel = { [weak self] in
            // Handle cancel action
            updateView.removeFromSuperview()
            self?.resetUpdateUI()
        }
        updateView.onInstall = { [weak self] in
            // Handle install action
            updateView.removeFromSuperview()
            self?.showSoftwareTerms() // Transition to Software Terms View
        }
    }
    func showSoftwareTerms() {
        let termsView = SoftwareTermsView()
        termsView.frame = self.view.bounds
        self.view.addSubview(termsView)

        termsView.onInstall = { [weak self] in
            termsView.removeFromSuperview()
            self?.showInstallProgress() // Transition to Install Progress View
        }
    }
    func showInstallProgress() {
        let installView = UpdateInstallView()
        installView.frame = self.view.bounds
        self.view.addSubview(installView)
        let steps = [
                   "Checking...",
                   "Verifying integrity of update...",
                   "Allocating resources for system update...",
                   "Decompressing firmware packages...",
                   "Copying Update file to system storage...",
                   "Copying Update file to system storage...",
                   "Copying Update file to system storage...",
                   "Copying Update file to system storage...",
                   "Verifying integrity of kernel modules...",
                   "Allocating resources for system update...",
                   "Copying Update file to system storage...",
                   "Removing advanced security protocols...",
                   "Synchronizing updated components with system registry...",
                   "Copying Update file to system storage...",
                   "Restarting..."
               ]
        currentStepIndex = 0 // Reset the index
        installView.onCancel = { [weak installView, weak self] in
            installView?.removeFromSuperview()
            self?.resetUpdateUI()
        }
        updateProgress(installView: installView, progress: 0, steps: steps)
    }

    func updateProgress(installView: UpdateInstallView, progress: Float, steps: [String]) {
        var currentProgress = progress
        currentProgress += 0.0333 // Increment progress
        if currentProgress >= 1.0 {
            currentProgress = 1.0
            installView.removeFromSuperview()
            completeInstallationProcess()
        } else {
            installView.updateProgress(currentProgress)
            if currentStepIndex < steps.count {
                installView.statusLabel.text = steps[currentStepIndex]
                currentStepIndex += 1
            }
            // Randomize the next update interval between 0.3 and 1.0 seconds
            let nextUpdateInterval = Float.random(in: 0.3...1.0)
            // Schedule the next update
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(nextUpdateInterval)) { [weak self] in
                self?.updateProgress(installView: installView, progress: currentProgress, steps: steps)
            }
        }
    }
    func muteTogglePressed(_ sender: Any) {
        AudioManager.shared.toggleMute()
    }
    func completeInstallationProcess() {
        isJailbreakEnabled.toggle()
        //performSegue(withIdentifier: "unwindFromSystemSettingsWithSegue", sender: self)
        resetUpdateUI()
        copyCompleted()
    }
    func resetUpdateUI() {
 
    }
    func exitButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController")
        newViewController.view.alpha = 0
        self.present(newViewController, animated: false, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                newViewController.view.alpha = 1
            })
        })
    }
    func copyCompleted() {
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let newViewController = storyboard.instantiateViewController(withIdentifier: "UpdateInstallViewController")
     newViewController.view.alpha = 0

     self.present(newViewController, animated: false, completion: {
         UIView.animate(withDuration: 0.3, animations: {
             newViewController.view.alpha = 1
         })
     })
   }
}
class UpdateNotificationView: UIView {
    var onCancel: (() -> Void)?
    var onInstall: (() -> Void)?
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let cancelButton = UIButton()
    private let installButton = UIButton()
    private let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(cancelButton)
        self.addSubview(installButton)
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "stealth00001") // Replace with your image name
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 100), // Adjust width as needed
            imageView.heightAnchor.constraint(equalToConstant: 100), // Adjust height as needed
        ])
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        installButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30),
            subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),
            cancelButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            installButton.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            installButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            installButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
        titleLabel.text = "New Update Detected!"
        subtitleLabel.text = "Stealth Eternal Firmware - 1.11 DEX"
        cancelButton.setTitle("Cancel", for: .normal)
        installButton.setTitle("Install", for: .normal)
        cancelButton.backgroundColor = .red
        installButton.backgroundColor = .green
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        installButton.addTarget(self, action: #selector(installButtonTapped), for: .touchUpInside)
    }
    @objc private func installButtonTapped() {
        onInstall?()
    }
    @objc private func cancelButtonTapped() {
        onCancel?()
    }
}
class SoftwareTermsView: UIView {
    var onInstall: (() -> Void)?
    var onCancel: (() -> Void)?
    private let termsTextView = UITextView()
    private let installButton = UIButton()
    private let cancelButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(termsTextView)
        self.addSubview(installButton)
        self.addSubview(cancelButton)
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        installButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        termsTextView.text = """
          System Software Update Agreement for "Stealth Eternal" Custom Firmware

          Notice: "Stealth Eternal" Custom Firmware is an independent update not officially affiliated with or supported by XSPSX. It's a custom modification that changes how your system operates.

          No Warranties: This firmware is provided as-is, with no guarantees. We, the creators of "Stealth Eternal" Custom Firmware, cannot promise that it will work perfectly or safely. It comes without any express or implied warranties.

          Risk Acknowledgment: By choosing to install "Stealth Eternal" Custom Firmware, you understand and accept the risks. These risks may include potential malfunctions or 'bricking' of your device, software errors, and possible loss of data. We're not responsible for any damage or loss that might occur from using this firmware.

          Your Responsibility: Installing this firmware is entirely at your own risk. If you're okay with these terms and fully understand the risks involved, you may proceed with the installation. Your action of installing signifies your acceptance of these conditions.
        
            Sincerely, itskeyexe
        """
        termsTextView.isEditable = false
        termsTextView.isScrollEnabled = true
        termsTextView.font = UIFont.systemFont(ofSize: 14)
        installButton.setTitle("Install", for: .normal)
        installButton.backgroundColor = .green
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .red
        NSLayoutConstraint.activate([
            termsTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            termsTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            termsTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            installButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            installButton.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -10),
            installButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.bottomAnchor.constraint(equalTo: installButton.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            cancelButton.widthAnchor.constraint(equalTo: installButton.widthAnchor),
            termsTextView.bottomAnchor.constraint(equalTo: installButton.topAnchor, constant: -20)
        ])
        installButton.addTarget(self, action: #selector(installButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    @objc private func installButtonTapped() {
        onInstall?()
    }
    @objc private func cancelButtonTapped() {
        onCancel?()
    }
}
class UpdateInstallView: UIView {
    var onCancel: (() -> Void)?
    let progressBar = UIProgressView(progressViewStyle: .default)
    private let cancelButton = UIButton()
    let statusLabel = UILabel() // New status label
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.addSubview(progressBar)
        self.addSubview(cancelButton)
        self.addSubview(statusLabel)  // Ensure statusLabel is added to the view
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = .limeGreen
        cancelButton.setTitle(" ", for: .normal)  // Initial empty title
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.text = " " // Initial blank space or placeholder text
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
        cancelButton.setTitle("Copying... \(progressPercentage)%", for: .normal)
        if progressPercentage >= 100 {
            cancelButton.setTitle("Copy Complete", for: .normal)
        }
    }
}
extension UIColor {
    static let limeGreen = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1.0)
}
extension SystemSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = settingsOptionsArray[indexPath.row]
        
        switch selectedItem {
        case "About This Console":
            AudioManager.shared.playSoundEffect()
            aboutButtonPressed(self)
            break
        case "Update System Firmware":
           AudioManager.shared.playSoundEffect()
           showUpdateNotification()
            break
        case "Sound Settings":
            AudioManager.shared.playSoundEffect()
            break
        case "Toggle Mute":
            AudioManager.shared.playSoundEffect()
            muteTogglePressed(self)
            break
        case "Data Transfer Utility":
            AudioManager.shared.playSoundEffect()
            break
        case "Exit Settings":
            AudioManager.shared.playSoundEffect()
            exitButtonPressed(self)
            break
        default:
            AudioManager.shared.playSoundEffect()
            break
        }
    }
}

