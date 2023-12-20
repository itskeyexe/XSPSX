//
//  CustomSegmentedControlDelegate.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 12/12/23.
//

import Foundation
import UIKit

protocol CustomSegmentedControlDelegate: AnyObject {
    func segmentDidChange(to index: Int)
}

class CustomSegmentedControl: UIScrollView {
    weak var customDelegate: CustomSegmentedControlDelegate?
    private var segments: [UIButton] = []
    private(set) var selectedIndex: Int = 0
    
    func setupSegments(imageNames: [String]) {
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceVertical = false  // Disable vertical bounce
        
        let buttonSize: CGFloat = 100  // Assuming square buttons
        let spacing: CGFloat = 10  // Space between buttons

        for (index, imageName) in imageNames.enumerated() {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            if let image = UIImage(named: imageName) {
                button.setImage(image, for: .normal)
            }
            button.imageView?.contentMode = .scaleAspectFit  // Keep the image aspect ratio
            
            // Constraints for button size
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true

            // Add button action
            button.addTarget(self, action: #selector(segmentButtonTapped(_:)), for: .touchUpInside)

            // Add button to the scrollView
            self.addSubview(button)
            segments.append(button)
            
            // Set button frames
            button.frame = CGRect(
                x: CGFloat(index) * (buttonSize + spacing),
                y: 0,
                width: buttonSize,
                height: buttonSize
            )
        }

        // Calculate and set the content size of the scroll view
        let contentWidth: CGFloat = CGFloat(imageNames.count) * (buttonSize + spacing) - spacing
        self.contentSize = CGSize(width: contentWidth, height: buttonSize)
    }
    
    @objc func segmentButtonTapped(_ sender: UIButton) {
           guard let index = segments.firstIndex(of: sender) else { return }
                   
           // Adjust the selectedIndex
           selectedIndex = index
                   
           // Notify the delegate
           customDelegate?.segmentDidChange(to: index)
            
           // Center the selected button in the scroll view
           let buttonCenter = CGPoint(x: sender.frame.midX, y: sender.frame.midY)
           let offset = CGPoint(x: buttonCenter.x - self.bounds.width / 2, y: 0)
           self.setContentOffset(offset, animated: true)

           // Animate the buttons
           animateToSelectedSegment()
           AudioManager.shared.playSoundEffect()
       }

       // Change the access level to fileprivate or internal
        func selectSegment(at index: Int) {
           selectedIndex = index
           animateToSelectedSegment()
           customDelegate?.segmentDidChange(to: index)  // Call the method on customDelegate
       }
  

    
    
    private func animateToSelectedSegment() {
        for (index, button) in segments.enumerated() {
            let isSelected = index == selectedIndex
            // Only adjust the alpha, no scaling
            button.alpha = isSelected ? 1.0 : 0.7
        }
    }

    public func configure(withImageNames imageNames: [String], selectedIndex: Int) {
        setupSegments(imageNames: imageNames)
        self.selectedIndex = selectedIndex
    }



    // CustomSegmentedControl.swift
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Calculate the width of each segment based on the control width and number of segments
        let segmentWidth = self.bounds.width / CGFloat(segments.count)
        
        for (index, segment) in segments.enumerated() {
            // Adjust the frame based on the index and whether it's selected
            let scale: CGFloat = index == selectedIndex ? 1.2 : 0.8
            let buttonHeight = segment.bounds.height // Get the button's height
            segment.frame = CGRect(
                x: segmentWidth * CGFloat(index) + (segmentWidth * (1 - scale) / 2),
                y: (self.bounds.height - buttonHeight) / 2, // Center vertically based on button's height
                width: segmentWidth * scale,
                height: buttonHeight
            )
        }
    }

    // You can override the touch methods if you want to handle swipes or other gestures
}

