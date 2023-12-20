//
//  JailbreakManager.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/26/23.
//

import Foundation
import UIKit

class JailbreakManager {
    // Create a shared instance as a singleton
    static let shared = JailbreakManager()
    
    // Private initializer to prevent direct instantiation
    private init() {}
    
    // Add a property to store the jailbreak state
    var isJailbreakEnabled = false
    
    // Add any other properties or methods related to jailbreak management here
    // For example, a method to update the jailbreak state
    func updateJailbreakState(enabled: Bool) {
        isJailbreakEnabled = enabled
    }
}

