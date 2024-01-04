//
//  WebViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/25/23.
//


import UIKit
import AVKit
import AVFoundation
import WebKit

class WebViewController: UIViewController, AVPlayerViewControllerDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var videoLayer: UIView!
    @IBOutlet weak var downloadStatusLabel: UILabel!
    @IBOutlet weak var closeBrowserButton: UIButton!
    private var currentStepIndex = 0
    func showInstallProgress() {
        let installView = UpdateInstallView()
        installView.frame = self.view.bounds
        self.view.addSubview(installView)
        let steps = [
                   "Verifying integrity of kernel modules...",
                   "Allocating resources for system update...",
                   "Decompressing firmware packages...",
                   "Removing advanced security protocols...",
                   "Synchronizing updated components with system registry...",
                   "Downloading...",
                   "Verifying integrity of kernel modules...",
                   "Allocating resources for system update...",
                   "Decompressing firmware packages...",
                   "Removing advanced security protocols...",
                   "Synchronizing updated components with system registry...",
                   "Downloading..."
               ]
        currentStepIndex = 0 // Reset the index
        installView.onCancel = { [weak installView, weak self] in
            installView?.removeFromSuperview()
            self?.resetUpdateUI()
        }
        // Initial call to start the progress update
        updateProgress(installView: installView, progress: 0, steps: steps)
    }
    func updateProgress(installView: UpdateInstallView, progress: Float, steps: [String]) {
        var currentProgress = progress
        currentProgress += 0.0333 // Increment progress
        if currentProgress >= 1.0 {
            currentProgress = 1.0
            installView.removeFromSuperview()
            completeDownloadProcess()
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
    func completeDownloadProcess() {
        resetUpdateUI()
    }
    func resetUpdateUI() {
        webView.removeFromSuperview()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        coldboot()
        setupWebView()
        downloadStatusLabel.alpha = 0.0
        webView.configuration.userContentController.add(self, name: "downloadButtonPressed")
    }
    
    func coldboot() {
        guard let path = Bundle.main.path(forResource: "1cyan", ofType: "mov") else {
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds // Update to match the bounds of the main view
        playerLayer.videoGravity = .resizeAspectFill
        videoLayer.layer.addSublayer(playerLayer)
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        player.play()
        view.addSubview(closeBrowserButton)
        view.addSubview(downloadStatusLabel)
    }
    
    @IBAction func closeBrowserPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController")
        newViewController.view.alpha = 0
        self.present(newViewController, animated: false) {
            UIView.animate(withDuration: 0.3) {
                newViewController.view.alpha = 1
            }
        }
    }
    
    private func setupWebView() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        searchBar.placeholder = "https://xspsxinjector.me"
        view.addSubview(searchBar)
        let webFrame = CGRect(x: 0, y: searchBar.frame.maxY, width: view.bounds.width, height: view.bounds.height - searchBar.frame.height)
        webView = WKWebView(frame: webFrame)
        webView.navigationDelegate = self
        webView.alpha = 1.0
        webView.layer.borderWidth = 1.0
        webView.layer.borderColor = UIColor.white.cgColor
        webView.backgroundColor = .clear
        webView.configuration.allowsInlineMediaPlayback = true
        view.insertSubview(webView, belowSubview: searchBar)
        // Load your HTTPS URL
        if let url = URL(string: "https://xspsxinjector.me") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        // Apply fade-in effect once the content has begun to load
        webView.navigationDelegate = self
        view.bringSubviewToFront(closeBrowserButton)
    }
  
    // WKNavigationDelegate methods
      func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
          print("Error during provisional navigation: \(error.localizedDescription)")
      }

      func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          print("Error during navigation: \(error.localizedDescription)")
      }


    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "downloadButtonPressed", let downloadType = message.body as? String {
            switch downloadType {
            case "textFile":
                // Handle text file download
                if let url = URL(string: "https://xspsxinjector.me/testFile.txt") {
                    startFileDownload(from: url)
                }
            case "firmware":
                // Handle firmware download
                if let url = URL(string: "https://xspsxinjector.me/stealthUpdate_v1.11.pkg") {
                    startFirmwareDownload(from: url)
                }
            case "toolbox":
                // Handle toolbox download
                if let url = URL(string: "https://xspsxinjector.me/toolbox_v1.11.pkg") {
                    startFileDownload(from: url)
                }
            case "spoofer":
                // Handle spoofer download
                if let url = URL(string: "https://xspsxinjector.me/spoofer_v1.11.pkg") {
                    startFileDownload(from: url)
                }
            default:
                break
            }
        }
    }

    
    func startFileDownload(from url: URL) {
        showDownloadProgressView(for: "File")
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (tempURL, response, error) in
            guard let tempURL = tempURL else { return }
            do {
                let fileManager = FileManager.default
                let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let downloadsPath = documentsPath.appendingPathComponent("DEV_HDD0/DOWNLOADS", isDirectory: true)
                
                if !fileManager.fileExists(atPath: downloadsPath.path) {
                    try fileManager.createDirectory(at: downloadsPath, withIntermediateDirectories: true, attributes: nil)
                }
                
                let destinationPath = downloadsPath.appendingPathComponent(url.lastPathComponent)
                if fileManager.fileExists(atPath: destinationPath.path) {
                    try fileManager.removeItem(at: destinationPath)
                }
                
                try fileManager.moveItem(at: tempURL, to: destinationPath)
                DispatchQueue.main.async {
                    self?.downloadStatusLabel.text = "Download Complete"
                    print("File saved to: \(destinationPath)")
                }
            } catch {
                print("Error saving file: \(error)")
            }
        }
        downloadTask.resume()
    }

    func startFirmwareDownload(from url: URL) {
        showDownloadProgressView(for: "Firmware")
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (tempURL, response, error) in
            guard let tempURL = tempURL else { return }
            do {
                let fileManager = FileManager.default
                let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let downloadsPath = documentsPath.appendingPathComponent("DEV_HDD0/DOWNLOADS", isDirectory: true)
                
                if !fileManager.fileExists(atPath: downloadsPath.path) {
                    try fileManager.createDirectory(at: downloadsPath, withIntermediateDirectories: true, attributes: nil)
                }
                
                let destinationPath = downloadsPath.appendingPathComponent(url.lastPathComponent)
                if fileManager.fileExists(atPath: destinationPath.path) {
                    try fileManager.removeItem(at: destinationPath)
                }
                
                try fileManager.moveItem(at: tempURL, to: destinationPath)
                DispatchQueue.main.async {
                    self?.downloadStatusLabel.text = "Firmware Download Complete"
                    print("Firmware file saved to: \(destinationPath)")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.downloadStatusLabel.text = "Error: \(error.localizedDescription)"
                }
                print("Error saving firmware file: \(error)")
            }
        }
        downloadTask.resume()
    }

    func showDownloadProgressView(for title: String) {
        let downloadView = downloadProgressView(frame: view.bounds)
        downloadView.statusLabel.text = "\(title) Download in Progress"
        view.addSubview(downloadView)
        downloadView.onCancel = { [weak downloadView] in
            downloadView?.removeFromSuperview()
            // Additional cancellation handling
        }
        // Start the progress update process
        updateDownloadProgress(progressView: downloadView, progress: 0)
    }

    private func showDownloadFileView() {
        let downloadView = downloadFileView(frame: view.bounds)
        view.addSubview(downloadView)

        downloadView.onCancel = { [weak downloadView] in
            downloadView?.removeFromSuperview()
            // Perform any additional cancellation handling here
        }

        downloadView.onInstall = { [weak downloadView, weak self] in
            downloadView?.removeFromSuperview()
            self?.startDownloadProcess()
        }
    }
    
    private func startDownloadProcess() {
        let progressView = downloadProgressView(frame: view.bounds)
        view.addSubview(progressView)
        progressView.onCancel = { [weak progressView] in
            progressView?.removeFromSuperview()
            // Perform any additional cancellation handling here
        }

        // Start updating the progress - this should be tied to your actual download logic
        updateDownloadProgress(progressView: progressView, progress: 0)
    }

    private func updateDownloadProgress(progressView: downloadProgressView, progress: Float) {
        var currentProgress = progress
        currentProgress += 0.0633 // Simulating progress increment

        if currentProgress >= 1.0 {
            progressView.updateProgress(1.0)
            progressView.removeFromSuperview()
            // Handle completion of download here
        } else {
            progressView.updateProgress(currentProgress)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.updateDownloadProgress(progressView: progressView, progress: currentProgress)
            }
        }
    }
}

class downloadFileView: UIView {
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
        self.backgroundColor = .black
        self.alpha = 0.88
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(cancelButton)
        self.addSubview(installButton)
        self.addSubview(imageView)
        // Configure imageView
           imageView.translatesAutoresizingMaskIntoConstraints = false
           imageView.contentMode = .scaleAspectFit // Adjust this as needed
           imageView.image = UIImage(named: "stealth00001") // Replace with your image name
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        installButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // ImageView constraints
                    imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
                    imageView.widthAnchor.constraint(equalToConstant: 100), // Adjust width as needed
                    imageView.heightAnchor.constraint(equalToConstant: 100), // Adjust height as needed
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
        //add an image centered just above this text
        titleLabel.text = "Stealth Eternal [v1.11_DEX_UPDATE.PUP]"
        subtitleLabel.text = "Download this file?"
        cancelButton.setTitle("Cancel", for: .normal)
        installButton.setTitle("Download", for: .normal)
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

class downloadProgressView: UIView {
    var onCancel: (() -> Void)?

    let progressBar = UIProgressView(progressViewStyle: .default)
    private let cancelButton = UIButton()
    let statusLabel = UILabel() // New status label
    private let imageView = UIImageView()

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
        self.addSubview(imageView)

        // Configure imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "xspsxinjtrClear") // Replace with your image name

        // ImageView constraints
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 100), // Adjust width as needed
            imageView.heightAnchor.constraint(equalToConstant: 100), // Adjust height as needed
        ])

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        progressBar.progressTintColor = .limeGreen
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

        // Update the button's title based on progress
        let progressPercentage = Int(progress * 100)
        cancelButton.setTitle("Downloading... \(progressPercentage)%", for: .normal)

        // When progress completes
        if progressPercentage >= 100 {
            cancelButton.setTitle("Download saved to flash memory, perform update ASAP!", for: .normal)
        }
    }
}



