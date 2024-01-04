//
//  PackageManagerViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 1/1/24.
//

import Foundation
import UIKit


protocol PackageManagerDelegate: AnyObject {
    func packageManagerDidFinish()
}

class PackageManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: PackageManagerDelegate?
    let folderImageView = UIImageView()
    let tableView = UITableView()
    
    enum ViewState {
        case mainMenu
        case installFiles // This will hold the list of .pkg files
        case deleteFiles
    }
    let backButton = UIButton()
    var viewState: ViewState = .mainMenu
    var currentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let mainMenuOptions = ["Install Package Files", "Delete Package Files", "Exit Package Manager"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear.withAlphaComponent(0.55)
        folderImageView.image = UIImage(named: "folderStar")
        folderImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(folderImageView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        // Constraints for folderImageView
               NSLayoutConstraint.activate([
                   folderImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.25), // Assuming 5% from the left edge of the view
                   folderImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.3), // Assuming 20% from the top of the view
                   folderImageView.widthAnchor.constraint(equalToConstant: 100), // Assuming the width of the folder icon is 100
                   folderImageView.heightAnchor.constraint(equalToConstant: 100) // Assuming the height of the folder icon is 100
               ])
               // Constraints for tableView
               NSLayoutConstraint.activate([
                   tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.36),
                   tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.36), // Assuming the table view starts at 50% of the width of the view
                   tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05), // Assuming 5% space from the right edge of the view
                   tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55) // Assuming the table view occupies 60% of the height of the view
               ])
             // Setup backButton
             backButton.setTitle("</>", for: .normal) // Customize as needed
             backButton.backgroundColor = .clear // Customize as needed
             backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
             backButton.translatesAutoresizingMaskIntoConstraints = false
             view.addSubview(backButton)

             // Constraints for backButton
             NSLayoutConstraint.activate([
                 backButton.leadingAnchor.constraint(equalTo: folderImageView.leadingAnchor),
                 backButton.topAnchor.constraint(equalTo: folderImageView.topAnchor),
                 backButton.widthAnchor.constraint(equalTo: folderImageView.widthAnchor),
                 backButton.heightAnchor.constraint(equalTo: folderImageView.heightAnchor)
             ])
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState {
        case .mainMenu:
            return mainMenuOptions.count
        case .installFiles, .deleteFiles:
            return getPackageFiles().count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch viewState {
        case .mainMenu:
            cell.textLabel?.text = mainMenuOptions[indexPath.row]
            cell.imageView?.image = UIImage(named: "folder")
        case .installFiles, .deleteFiles:
            let pkgFiles = getPackageFiles()
            let pkgFile = pkgFiles[indexPath.row]
            cell.textLabel?.text = pkgFile.lastPathComponent
            cell.imageView?.image = UIImage(named: "folder")
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pkgFiles = getPackageFiles()
        switch viewState {
        case .mainMenu:
            handleMainMenuSelection(at: indexPath)
        case .installFiles:
            let selectedFile = pkgFiles[indexPath.row]
            installPackage(file: selectedFile)
        case .deleteFiles:
            let fileToDelete = pkgFiles[indexPath.row]
            deletePackage(file: fileToDelete)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func navigateToParentDirectory() {
        let devHDD0URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DEV_HDD0")
        if currentDirectoryURL == devHDD0URL {
            viewState = .mainMenu
        } else {
            currentDirectoryURL = currentDirectoryURL.deletingLastPathComponent()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func getPackageFiles() -> [URL] {
        let downloadsFolder = "DEV_HDD0/DOWNLOADS"
        let downloadsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(downloadsFolder)
        do {
            return try FileManager.default.contentsOfDirectory(at: downloadsURL, includingPropertiesForKeys: nil)
                               .filter { $0.pathExtension == "pkg" }
        } catch {
            print("Error reading contents of directory: \(error)")
            return []
        }
    }

    
    @objc private func backButtonTapped() {
        if case .installFiles = viewState {
            // If the user is currently viewing the .pkg files, tapping the back button should take them back to the main menu.
            viewState = .mainMenu
            tableView.reloadData()  // Make sure to reload the tableView on the main thread
        } else {
            // If already at the main menu, the back button could dismiss the view controller or do nothing
            // For example, dismiss this view controller or call delegate?.packageManagerDidFinish()
            delegate?.packageManagerDidFinish()
            dismiss(animated: true, completion: nil)
        }
    }

    
    private func loadPkgFiles(forViewState operation: ViewState) {
        let downloadsFolder = "DEV_HDD0/DOWNLOADS"
        let downloadsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(downloadsFolder)

        do {
            let pkgFiles = try FileManager.default.contentsOfDirectory(at: downloadsURL, includingPropertiesForKeys: nil)
                           .filter { $0.pathExtension == "pkg" }

            switch operation {
            case .installFiles:
                viewState = .installFiles
            case .deleteFiles:
                viewState = .deleteFiles
            default:
                break
            }

            // Pass the pkgFiles array to handle the files for installation or deletion
            handleFiles(pkgFiles, forOperation: operation)

        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
    private func handleFiles(_ files: [URL], forOperation operation: ViewState) {
        switch operation {
        case .installFiles:
            // Handle the installation logic
            AudioManager.shared.playSoundEffect()
        case .deleteFiles:
            // Handle the deletion logic
            AudioManager.shared.playSoundEffect()
        default:
            break
        }
    }
    
    private func deletePackage(file: URL) {
        do {
            let fileManager = FileManager.default
            try fileManager.removeItem(at: file)
            print("File deleted: \(file.lastPathComponent)")
        } catch {
            print("Error deleting file: \(error)")
        }
        // Reload the list of .pkg files
        loadPkgFiles(forViewState: viewState)
    }

    private func handleMainMenuSelection(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // "Install Package Files"
            AudioManager.shared.playSoundEffect()
            viewState = .installFiles
            tableView.reloadData()
        case 1: // "Delete Package Files"
            AudioManager.shared.playSoundEffect()
            viewState = .deleteFiles
            tableView.reloadData()
        case 2: // "Exit Package Manager"
            AudioManager.shared.playSoundEffect()
            delegate?.packageManagerDidFinish()
        default:
            break
        }
    }

    private func installPackage(file: URL) {
        showInstallProgressView(for: file.lastPathComponent)
    }
    
    private func showInstallProgressView(for packageName: String) {
        // Present the install progress view and start the installation process
        // Implement this according to your app's needs
    }


}
