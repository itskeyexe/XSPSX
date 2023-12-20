//
//  SpooferViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 12/4/23.
//

import Foundation
import UIKit

class SpooferViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlertWithIcon(message: "9.99 OFW Spoofer", iconName: "spoofer")
    }


    let imageView = UIImageView()
    let progressBar = UIProgressView(progressViewStyle: .bar)
    let titleLabel = UILabel()
    let installButton = UIButton()
    let exitButton = UIButton()
    let updateLabels: [UILabel] = (1...21).map { _ in UILabel() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fadeInImageAndStartProgress()
    }

    private func setupViews() {
        view.backgroundColor = .black
        setupImageView()
        setupProgressBar()
        setupTitleLabel()
        setupInstallButton()
        setupExitButton()
        setupUpdateLabels()
        
        // Initially hide titleLabel, installButton, exitButton, and updateLabels
        titleLabel.isHidden = true
        installButton.isHidden = true
        exitButton.isHidden = true
        updateLabels.forEach { $0.isHidden = true }
    }

    private func setupImageView() {
        // Setup and add imageView
        imageView.image = UIImage(named: "spoofer00.png")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0  // Start with an alpha of 0 for the fade-in effect
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),  // Adjust as needed
            imageView.heightAnchor.constraint(equalToConstant: 100)  // Adjust as needed
        ])
    }

    private func setupProgressBar() {
        // Setup and add progressBar
        progressBar.progressTintColor = UIColor.cyan
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.alpha = 0
        view.addSubview(progressBar)

        NSLayoutConstraint.activate([
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            progressBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            progressBar.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupTitleLabel() {
        // Setup titleLabel
        titleLabel.text = "[!] OFW Spoofer Initialized."
        titleLabel.font = UIFont.systemFont(ofSize: 8)
        titleLabel.textColor = .cyan
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
    }

    private func setupInstallButton() {
        // Setup installButton
        installButton.setTitle("[!] Spoof OFW 9.99.", for: .normal)
        installButton.setTitleColor(.yellow, for: .normal) // Set text color to yellow
        installButton.titleLabel?.font = UIFont.systemFont(ofSize: 8)
        installButton.addTarget(self, action: #selector(installButtonTapped), for: .touchUpInside)
        installButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(installButton)

        NSLayoutConstraint.activate([
            installButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            installButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        ])
    }

    private func setupExitButton() {
        // Setup exitButton
        exitButton.setTitle("[!] Exit.", for: .normal)
        exitButton.setTitleColor(.yellow, for: .normal) // Set text color to yellow
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 8)
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            exitButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            exitButton.topAnchor.constraint(equalTo: installButton.bottomAnchor, constant: 5)
        ])
    }

    private func setupUpdateLabels() {
        // Setup updateLabels
        let updates = ["[!] Initializing kernel exploit sequence...",
                       "[!] Bypassing security protocols...",
                       "[!] Accessing system kernel...",
                       "[!] Applying kernel patch for exploit...",
                       "[!] Kernel successfully exploited.",
                       "[!] Injecting Spoof 9.99 OFW into system...",
                       "[!] Injecting Spoof 9.99 OFW into system...",
                       "[!] Injecting Spoof 9.99 OFW into system...",
                       "[!] Injecting Spoof 9.99 OFW into system...",
                       "[!] Configuring XSPSX Update settings...",
                       "[!] Securing exploit environment...",
                       "[!] Finalizing Spoof 9.99 OFW installation...",
                       "[!] Initializing kernel exploit sequence...",
                       "[!] Bypassing security protocols...",
                       "[!] Accessing system kernel...",
                       "[!] Kernel successfully exploited!",
                       "[!] Injecting Spoofer 9.99 modules into system...",
                       "[!] Configuring XSPSX settings.",
                       "[!] Securing exploit environment.",
                       "[!] Finalizing XSPSX OFW 9.99 Update installation.",
                       "*** XSPSX OFW 9.99 Installation Complete ***"]
        
        var previousLabel: UILabel? = nil

        for (index, updateMessage) in updates.enumerated() {
            let label = updateLabels[index]
            label.text = updateMessage
            label.font = UIFont.systemFont(ofSize: 8)
            label.textColor = .cyan
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                label.topAnchor.constraint(equalTo: previousLabel?.bottomAnchor ?? exitButton.bottomAnchor, constant: index == 0 ? 10 : 2)
            ])
            previousLabel = label
        }
    }

    private func fadeInImageAndStartProgress() {
        // Fade in imageView
        UIView.animate(withDuration: 0.25) {
            self.imageView.alpha = 1
        }

        // Start progress bar animation
        progressBar.alpha = 1
        UIView.animate(withDuration: 5, animations: {
            self.progressBar.setProgress(1, animated: true)
        }) { _ in
            self.showUIElements()
        }
    }

    private func showUIElements() {
        titleLabel.isHidden = false
        installButton.isHidden = false
        exitButton.isHidden = false
        imageView.alpha = 0.75

        // Reset progress bar to 0
        progressBar.setProgress(0, animated: false)
        //progressBar.alpha = 0  // Optionally hide the progress bar until Install is tapped
    }


    @objc private func installButtonTapped() {
        imageView.alpha = 1
        progressBar.alpha = 1
        progressBar.setProgress(0, animated: false)

        let totalDuration = 10.0
        let updateInterval = 0.5 // Half a second for each label
        let numberOfLabels = updateLabels.count
        UIView.animate(withDuration: totalDuration) {
            self.progressBar.setProgress(1, animated: true)
        }

        for (index, label) in updateLabels.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + updateInterval * Double(index)) {
                label.isHidden = false

                // Check if this is the last label and the progress bar has finished
                if index == numberOfLabels - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + updateInterval) {
                        self.completeInstallation()
                    }
                }
            }
        }
    }

    
    
    private func completeInstallation() {
        //update the system software variable to 9.99 aka the spoof
        SystemData.shared.currentUpdateVersion = "XSPSX 9.99 OFW"
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let xspsxSettingsVC = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController") as? XSPSXViewController else {
               
                return // Failed to instantiate the view controller
            }
            self.present(xspsxSettingsVC, animated: true, completion: nil)
    }



    @objc private func exitButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let xspsxSettingsVC = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController") as? XSPSXViewController else {
            return // Failed to instantiate the view controller
        }
        self.present(xspsxSettingsVC, animated: true, completion: nil)
    }
}
