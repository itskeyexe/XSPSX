//
//  XSPSXViewController+TableView.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 11/29/23.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import WebKit
import Messages

// MARK: - UITableViewDataSource
extension XSPSXViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == packageFileHome {
            return packageInstallerOptions.count
        } else if tableView == packageFileDirectory {
            return packageFileDirectoryDataSource.count
        } else if tableView == self.tableView {
            return categoryData[selectedIndex].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == packageFileHome {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstallerCell", for: indexPath)
            cell.textLabel?.text = packageInstallerOptions[indexPath.row]
            cell.imageView?.image = UIImage(named: "folderIcon") // Replace with your folder icon asset name
            return cell
        } else if tableView == packageFileDirectory {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
            cell.textLabel?.text = packageFileDirectoryDataSource[indexPath.row]
            return cell
        } else if tableView == self.tableView {
            guard indexPath.row < categoryData[selectedIndex].count else {
                return UITableViewCell() // Return an empty cell or handle appropriately
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
            cell.textLabel?.text = categoryData[selectedIndex][indexPath.row]
            cell.backgroundColor = .clear
            cell.textLabel?.textAlignment = .left
            
            // Custom attributes for text
            let customYellow = UIColor(hex: "d4d300") ?? .white
            let fontSize: CGFloat = 17
            let attributedString = NSAttributedString(string: cell.textLabel?.text ?? "", attributes: [
                .strokeColor: UIColor.black,
                .foregroundColor: customYellow,
                .strokeWidth: -3.0,
                .font: UIFont.systemFont(ofSize: fontSize)
            ])
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.attributedText = attributedString
            
            if let folderImage = UIImage(named: "folderStar")?.resizedImage(newSize: CGSize(width: 75, height: 75)) {
                cell.imageView?.image = folderImage
            }
            
            // Change the selection style to none to remove the default selection effect
            cell.selectionStyle = .none
            
            return cell
        }
        
        return UITableViewCell() // Fallback for any other table view
    }
}

// MARK: - UITableViewDelegate
extension XSPSXViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == packageFileHome {
            let selectedOption = packageInstallerOptions[indexPath.row]
            handlePackageInstallerSelection(option: selectedOption)
        } else if tableView == packageFileDirectory {
            let selectedFile = packageFileDirectoryDataSource[indexPath.row]
            handleFileSelection(file: selectedFile)
        } else if tableView == self.tableView {
            let selectedCategory = categories[selectedIndex]
            let selectedItem = categoryData[selectedIndex][indexPath.row]
            if !selectedItem.isEmpty {
                performActionForSelectedItem(selectedItem, inCategory: selectedCategory)
            }
        }
    }

    // Placeholder functions for handling selections
    private func handlePackageInstallerSelection(option: String) {
        // Implement the logic for handling package installer option here
    }

    private func handleFileSelection(file: String) {
        // Implement the logic for handling file selection here
    }
}


// UIImage Extension
extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

// WKNavigationDelegate
extension XSPSXViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView error: \(error.localizedDescription)")
    }
}
