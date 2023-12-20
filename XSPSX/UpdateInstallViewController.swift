//
//  UpdateInstallViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 11/25/23.
//

import UIKit
import AVKit
import AVFoundation

class UpdateInstallViewController: UIViewController, AVPlayerViewControllerDelegate {
    
    var isJailbreakComplete = false
    var isJailbreakEnabled = false
    
    var currentStepIndex = 0
    @IBOutlet weak var updateVideoLayer: UIImageView!
    var installerView: pupInstallerView? // Add this line to declare your custom view
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coldboot()
        AudioManager.shared.playColdBootSound()
        // Delay the appearance of the installation view
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showInstallerView()
            self.showInstallProgress()
        }
    }
    
    func coldboot() {
        guard let path = Bundle.main.path(forResource: "2cyan", ofType: "mov") else {
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        updateVideoLayer?.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.play()
    }
    
    func showInstallerView() {
        // Initialize your installer view and add it to the view controller's view
        let installerFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200) // Adjust frame as needed
        installerView = pupInstallerView(frame: installerFrame)
        installerView?.center = view.center
        view.addSubview(installerView!)
        
        // Set the initial progress and message
        installerView?.updateProgress(0.0)
        installerView?.statusLabel.text = "Installing system software, please wait..."
        
        // Fade in the installer view
        installerView?.alpha = 0
        UIView.animate(withDuration: 1.0) {
            self.installerView?.alpha = 1
        }
        
        installerView?.onCompletion = {
            // Call a method to perform the segue
            self.completeInstallation()
        }
        
    }
    
    func showInstallProgress() {
        let installView = UpdateInstallView()
        installView.frame = self.view.bounds
        self.view.addSubview(installView)
        
        let steps = [" ",
                     " ",
                     " ",
                     " ",
                     " ",
                     " ",
                     " "
        ]
        
        currentStepIndex = 0 // Reset the index
        
        installView.updateProgress(0.0)
        
        // Schedule a timer to update progress
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.currentStepIndex += 1
            
            if self.currentStepIndex < steps.count {
                let newProgress = Float(self.currentStepIndex) / Float(steps.count)
                
                // Execute UI updates on the main thread
                DispatchQueue.main.async {
                    installView.updateProgress(newProgress)
                    installView.statusLabel.text = steps[self.currentStepIndex]
                }
            } else {
                // Also execute this UI update on the main thread
                DispatchQueue.main.async {
                    installView.updateProgress(1.0)
                    installView.statusLabel.text = "Installation complete. Please restart."
                    timer.invalidate() // Use the timer passed to the closure
                    self.completeInstallation() // Call the completion method
                }
            }
        }
        timer.fire() // Start the timer
    }
    
    
    
    func completeInstallation() {
        // Perform the segue back to ColdBootViewController
        isJailbreakComplete = true
        SystemData.shared.currentUpdateVersion = "XSPSX 1.11 CFW"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyboard.instantiateViewController(withIdentifier: "ColdBootViewController") as? ColdBootViewController {
            newViewController.isJailbreakEnabled = isJailbreakComplete // Set the flag
            newViewController.view.alpha = 0
            
            self.present(newViewController, animated: false, completion: {
                UIView.animate(withDuration: 0.3, animations: {
                    newViewController.view.alpha = 1
                })
            })
        }
    }

    
    @objc func videoDidFinishPlaying(_ notification: Notification) {
        
        
    }
    
    
    
    class pupInstallerView: UIView {
        var onCancel: (() -> Void)?
        var onCompletion: (() -> Void)? // Add this line for the completion handler
        
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
            self.backgroundColor = .clear
            self.addSubview(progressBar)
            self.addSubview(cancelButton)
            self.addSubview(statusLabel)  // Ensure statusLabel is added to the view
            
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            
            progressBar.progressTintColor = .systemCyan
            cancelButton.setTitle(" ", for: .normal)  // Initial empty title
            cancelButton.backgroundColor = .clear
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
            
            // Setup statusLabel
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
                
                // Position statusLabel under cancelButton
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
            
            // Update the status label and button title based on progress
            let progressPercentage = Int(progress * 100)
            if progressPercentage < 100 {
                cancelButton.setTitle("", for: .normal)
                statusLabel.text = "Installing system software, please wait... \(progressPercentage)%"
            } else {
                cancelButton.setTitle("Installation Complete", for: .normal)
                statusLabel.text = "Installation complete. Please restart."
                onCompletion?() // Call the completion handler
            }
        }
        
    }
    
    
}
