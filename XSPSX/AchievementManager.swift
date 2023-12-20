//
//  AchievementManager.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 12/11/23.
//

import Foundation
class AchievementManager {
    static let shared = AchievementManager()

    private var achievements: [Achievement] {
        didSet {
            saveAchievements()
        }
    }

    init() {
        achievements = []
        loadAchievements()
    }
    
    private func loadAchievements() {
        // Load achievements from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = savedAchievements
        } else {
            // Initialize with default achievements if not found
            achievements = [
                // Define your default achievements here...
            ]
        }
    }

    private func saveAchievements() {
        // Save achievements to UserDefaults
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "achievements")
        }
    }
    
 
    func unlock(achievement identifier: String) {
        if let index = achievements.firstIndex(where: { $0.identifier == identifier }) {
            achievements[index].isUnlocked = true
            
            // Post a notification when an achievement is unlocked
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .achievementUnlocked, object: self, userInfo: ["achievement": self.achievements[index]])
            }
        }
    }

    
    func isUnlocked(achievement identifier: String) -> Bool {
        return achievements.first { $0.identifier == identifier }?.isUnlocked ?? false
    }
}

struct Achievement: Codable {
    let identifier: String
    let title: String
    let description: String
    let iconName: String
    var isUnlocked: Bool
}

extension Notification.Name {
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
}
