//
//  SystemData.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 12/4/23.
//

import Foundation

class SystemData {
    static let shared = SystemData()

    // Current update version - existing property
    var currentUpdateVersion: String = "XSPSX 1.09 OFW"
    
    // Jailbreak flag stored in UserDefaults
       var isJailbreakEnabled: Bool {
           get {
               return UserDefaults.standard.bool(forKey: "isJailbreakEnabled")
           }
           set {
               UserDefaults.standard.set(newValue, forKey: "isJailbreakEnabled")
               // When jailbreak flag is set for the first time, enable syscallToggle by default
               if UserDefaults.standard.object(forKey: "syscallToggle") == nil {
                   syscallToggle = newValue
               }
           }
       }
    // Syscall Toggle flag stored in UserDefaults
       var syscallToggle: Bool {
           get {
               return UserDefaults.standard.bool(forKey: "syscallToggle")
           }
           set {
               UserDefaults.standard.set(newValue, forKey: "syscallToggle")
           }
       }

    // Property to track the current directory
    private var currentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // Base directory for the file system
        let baseDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("DEV_HDD0")

       // Directory URLs for easy access
       var downloadsDirectoryURL: URL { baseDirectoryURL.appendingPathComponent("DOWNLOADS") }
       var gamesDirectoryURL: URL { baseDirectoryURL.appendingPathComponent("GAMES") }
       var mediaDirectoryURL: URL { baseDirectoryURL.appendingPathComponent("MEDIA") }
       var updateDirectoryURL: URL { baseDirectoryURL.appendingPathComponent("UPDATE") }
       var tmpDirectoryURL: URL { baseDirectoryURL.appendingPathComponent("tmp") }

       // Initialization method to set up the file system
       func initializeFileSystem() {
           let directories = ["DOWNLOADS", "GAMES", "MEDIA", "UPDATE", "tmp"]
           
           for directory in directories {
               let dirURL = baseDirectoryURL.appendingPathComponent(directory)
               if !FileManager.default.fileExists(atPath: dirURL.path) {
                   do {
                       try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                   } catch {
                       print("Error creating directory \(directory): \(error)")
                   }
               }
           }
       }
    

    // Function to list files and directories in a given path
    func listFiles(at path: URL? = nil) -> [URL] {
        let directoryURL = path ?? currentDirectoryURL
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            return directoryContents
        } catch {
            print("Error listing files: \(error)")
            return []
        }
    }

    // Function to create a new folder
    func createFolder(named folderName: String, at path: URL? = nil) {
        let directoryURL = path ?? currentDirectoryURL
        let newFolderPath = directoryURL.appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating folder: \(error)")
        }
    }

    // Function to delete a file or folder
    func deleteItem(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error deleting item: \(error)")
        }
    }

    // Function to copy a file or folder
    func copyItem(from sourceURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            print("Error copying item: \(error)")
        }
    }

    // Getter and Setter for the current directory path
    var currentPath: URL {
        get {
            return currentDirectoryURL
        }
        set(newPath) {
            currentDirectoryURL = newPath
        }
    }
    
    // Initializer
     private init() {
         initializeFileSystem()  // Initialize the file system when SystemData is created
         if isJailbreakEnabled && UserDefaults.standard.object(forKey: "syscallToggle") == nil {
                     syscallToggle = true
                 }
     }
 }

import UIKit
import AVFoundation

// Extend UIViewController to add the showAlertWithIcon method
extension UIViewController {

    func showAlertWithIcon(message: String, iconName: String) {
        // Ensure this runs on the main thread since it's updating the UI
        DispatchQueue.main.async {
            AudioManager.shared.playFeatUnlockedSoundEffect()
            let alertViewController = UIViewController()
            alertViewController.view.backgroundColor = .clear
            alertViewController.modalPresentationStyle = .overFullScreen
            let customView = UIView()
            customView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            customView.layer.cornerRadius = 10
            let screenWidth = UIScreen.main.bounds.width
            let customViewWidth: CGFloat = 260
            let customViewHeight: CGFloat = 80
            let xPosition = screenWidth - customViewWidth - 20
            let yPosition: CGFloat = 20
            customView.frame = CGRect(x: xPosition, y: yPosition, width: customViewWidth, height: customViewHeight)
            let imageView = UIImageView(image: UIImage(named: iconName))
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
            let label = UILabel()
            label.frame = CGRect(x: 80, y: 10, width: customViewWidth - 90, height: 60)
            label.text = message
            label.textColor = .white
            label.numberOfLines = 2
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .left
            customView.addSubview(imageView)
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
        }
    }
}


