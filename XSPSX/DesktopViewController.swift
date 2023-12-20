//
//  DesktopViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 8/1/23.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Network

class DesktopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: FileSystemDelegate?
    // Set a default value for currentDirectoryURL at the point of declaration
    var currentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var contents: [URL] = [] // This will dynamically store the content
    var selectedFileURL: URL? // Store the URL of the selected file
    var secondaryDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! // Initialize to the base directory
    var secondaryContentsArray: [URL] = []
    
    
    // Function to create a new folder
    func createNewFolder(named folderName: String) {
        let newFolderPath = currentDirectoryURL.appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true, attributes: nil)
            loadContentsOfCurrentDirectory() // Refresh the contents
        } catch {
            print("Error creating folder: \(error)")
        }
    }
    
    // Function to delete a file or folder
    func deleteItemAtURL(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            loadContentsOfCurrentDirectory() // Refresh the contents
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    // Function to copy a file
    func copyItem(from sourceURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            loadContentsOfCurrentDirectory() // Refresh the contents
        } catch {
            print("Error copying item: \(error)")
        }
    }
    
    // Function to move a file
    func moveItem(from sourceURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
            loadContentsOfCurrentDirectory() // Refresh the contents
        } catch {
            print("Error moving item: \(error)")
        }
    }
    

    func getContentsOfDirectory(atPath pathComponent: String) -> [String] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return []
        }

        let directoryURL = documentsDirectory.appendingPathComponent(pathComponent)

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let fileNames = fileURLs.map { $0.lastPathComponent }
            return fileNames
        } catch {
            print("Error reading contents of directory: \(error)")
            return []
        }
    }

    
    // Call delegate methods when needed, for example:
      func someActionThatRequiresLoadingFileSystem() {
          delegate?.loadFileSystem()
      }

    
    //File management UI elements
    @IBOutlet weak var actionMenuView: UIView!
    @IBOutlet weak var actionsLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exitActionButton: UIButton!
    
    //Staring Files View
    @IBOutlet weak var filesWindow: UIView!
    @IBOutlet weak var filesHeader: UIView!
    @IBOutlet weak var filesTableView: UITableView!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeDateLabel: UILabel!
    @IBOutlet weak var FileBackButton: UIButton!
    @IBOutlet weak var pathLabel: UILabel!
    
    //Second Files Window View
    @IBOutlet weak var closeFilesWindowButtton: UIButton!
    @IBOutlet weak var Files_1View: UIView!
    @IBOutlet weak var closeButton0: UIButton!
    @IBOutlet weak var files_1TableView: UITableView!
    @IBOutlet weak var currentPathLabel: UILabel!
    @IBOutlet weak var files_1BackButton: UIButton!
    
    
    @IBAction func close0ButtonPressed(_ sender: Any) {
        Files_1View.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the primary table view
        filesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        filesTableView.dataSource = self
        filesTableView.delegate = self
        
        
        // Setting up the secondary table view
        files_1TableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        files_1TableView.dataSource = self
        files_1TableView.delegate = self
        
        filesWindow.isHidden = true
        Files_1View.isHidden = true
        loadContentsOfCurrentDirectory()
        currentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        initializeFileSystem()
        updateDateTimeLabel()
        
    }
    
    func loadContentsOfCurrentDirectory() {
        do {
            contents = try FileManager.default.contentsOfDirectory(at: currentDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            filesTableView.reloadData()
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
    func loadContentsOfSecondaryDirectory() {
        do {
            secondaryContentsArray = try FileManager.default.contentsOfDirectory(at: secondaryDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            files_1TableView.reloadData()
        } catch {
            print("Error reading contents of secondary directory: \(error)")
        }
    }

    
    func initializeFileSystem() {
        let directories = ["DOWNLOADS", "GAMES", "MEDIA", "UPDATE", "tmp"]
        let baseDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DEV_HDD0")
        
        for directory in directories {
            let dirURL = baseDirectory.appendingPathComponent(directory)
            if !FileManager.default.fileExists(atPath: dirURL.path) {
                do {
                    try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating directory \(directory): \(error)")
                }
            }
        }
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let urlToDelete = selectedFileURL {
            deleteItemAtURL(urlToDelete)
        }
    }
    
    var fileToCopyURL: URL? // Store the URL of the file to copy
    @IBAction func copyButtonPressed(_ sender: Any) {
        fileToCopyURL = selectedFileURL
    }
    
    @IBAction func pasteButtonPressed(_ sender: Any) {
        if let sourceURL = fileToCopyURL {
            let destinationURL = currentDirectoryURL.appendingPathComponent(sourceURL.lastPathComponent)
            copyItem(from: sourceURL, to: destinationURL)
        }
    }
    
    // Add a method to get the contents of the DEV_HDD0 directory
    func getDevHDD0Contents() -> [String] {
        let devHDD0URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DEV_HDD0")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: devHDD0URL, includingPropertiesForKeys: nil)
            return fileURLs.map { $0.lastPathComponent }
        } catch {
            print("Error reading contents of DEV_HDD0: \(error)")
            return []
        }
    }

    
    
    
    // TableView DataSource and Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filesTableView {
            return contents.count
        } else if tableView == files_1TableView {
            return secondaryContentsArray.count
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        if tableView == filesTableView {
            let item = contents[indexPath.row]
            cell.textLabel?.text = item.lastPathComponent
            
            // Set folder icon for directories in the primary table view
            if item.hasDirectoryPath {
                cell.imageView?.image = UIImage(named: "folder") // Make sure you have a "folder" image in your assets
            } else {
                cell.imageView?.image = nil // Or some other icon for files
            }
        } else if tableView == files_1TableView {
            let item = secondaryContentsArray[indexPath.row]
            cell.textLabel?.text = item.lastPathComponent
            
            // Set folder icon for directories in the secondary table view
            if item.hasDirectoryPath {
                cell.imageView?.image = UIImage(named: "folder") // Make sure you have a "folder" image in your assets
            } else {
                cell.imageView?.image = nil // Or some other icon for files
            }
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = contents[indexPath.row]
        if selectedItem.hasDirectoryPath {
            switch selectedItem.lastPathComponent.uppercased() {
            case "DOWNLOADS", "MEDIA", "GAMES", "UPDATE", "TMP":
                // Open the second view with the specific directory
                openSecondView(with: selectedItem)
            default:
                // Normal navigation for other directories
                currentDirectoryURL = selectedItem
                loadContentsOfCurrentDirectory()
            }
        } else {
            // Handle file selection
            // Add your code here if you want to do something when a file is selected
        }
    }

    
    func openSecondView(with directoryURL: URL) {
        // Set the directory for the second view and show it
        secondaryDirectoryURL = directoryURL
        loadContentsOfSecondaryDirectory()
        Files_1View.isHidden = false
    }

    
    @IBAction func backButtonPressedInSecondView(_ sender: Any) {
        let parentDirectory = secondaryDirectoryURL.deletingLastPathComponent()
        if parentDirectory.path != FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path {
            secondaryDirectoryURL = parentDirectory
            loadContentsOfSecondaryDirectory()
        }
    }
    
    
    
    
    @IBAction func startButtonPressed(_ sender: Any) {
        filesWindow.isHidden = false
        loadContentsOfCurrentDirectory()
        updatePathLabel()
        print ("Current Path: \(currentDirectoryURL.path)")
    }
    
    @IBAction func closeFilesButtonPress(_ sender: Any) {
        filesWindow.isHidden = true
    }
    
    func updatePathLabel() {
        pathLabel.text = "Current Path: \(currentDirectoryURL.path)"
        // Similarly for the second view's path label
    }
    func updateSecondaryPathLabel() {
        currentPathLabel.text = "Current Path: \(secondaryDirectoryURL.path)"
    }
    
    @IBAction func goFileBackButtonPressed(_ sender: Any) {
        let parentDirectory = currentDirectoryURL.deletingLastPathComponent()
        
        // Check if the parent directory is different from the current directory and not the root directory
        if parentDirectory != currentDirectoryURL && parentDirectory.path != FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path {
            currentDirectoryURL = parentDirectory
            loadContentsOfCurrentDirectory()
        }
    }
    
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let xspsxVC = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController") as? XSPSXViewController else {
            return // Failed to instantiate the view controller
        }
        
        self.present(xspsxVC, animated: true, completion: nil)
        
    }
    
    func updateDateTimeLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let currentDateTime = Date()
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        timeDateLabel.text = formattedDateTime
    }
  
    
}

protocol FileSystemDelegate: AnyObject {
    func loadFileSystem()
    func createFolder(named: String)
    func deleteItemAt(path: String)
    func getDevHDD0Contents() -> [String]
}
