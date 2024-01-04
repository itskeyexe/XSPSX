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
        if tableView == self.tableView {
            return categoryData[selectedIndex].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
            let categoryItem = categoryData[selectedIndex][indexPath.row]
            cell.textLabel?.text = categoryItem
            cell.backgroundColor = .clear
            cell.textLabel?.textAlignment = .left
            // Set and resize the icon image based on the mapping
            let iconName = iconMapping[categoryItem] ?? "folderStar"
            if let iconImage = UIImage(named: iconName)?.resizedImage(newSize: CGSize(width: 75, height: 75)) {
                cell.imageView?.image = iconImage
            }
            // Custom attributes for text
            let customYellow = UIColor(hex: "d4d300") ?? .white
            let fontSize: CGFloat = 17
            let attributedString = NSAttributedString(string: categoryItem, attributes: [
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
    
// MARK: - UITableViewDelegate
extension XSPSXViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if tableView == self.tableView {
                let selectedItem = categoryData[selectedIndex][indexPath.row]

                if isFirstTap {
                    // First tap: Show and animate the game thumbnail
                    showThumbnailForSelectedItem(selectedItem)
                    isFirstTap = false
                    selectedIndexPath = indexPath // Keep track of the selected indexPath
                } else {
                    // Second tap: Perform the action for the selected item
                    performActionForSelectedItem(selectedItem, inCategory: categories[selectedIndex])
                    isFirstTap = true // Reset for the next selection
                }
            }
        }

    // Create a separate method to handle the "Package Manager" selection
    func handlePackageManagerSelection() {
        // Handle the "Package Manager" functionality here
        // You can show the package manager view, update its data, etc.
        // Example: Show the package manager table view
    }
        
        func updateGameThumbnail(for item: String) {
            let thumbnailName = getThumbnailName(for: item)
            gameThumbnail.image = UIImage(named: thumbnailName)
        }
        
        func animateThumbnailAppearance() {
            gameThumbnail.isHidden = false
            gameThumbnail.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.gameThumbnail.alpha = 1.0
            }
        }
        
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


