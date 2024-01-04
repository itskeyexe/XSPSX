//
//  AudioManager.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/26/23.
//
import UserNotifications
import AVFoundation

class AudioManager {
    static let shared = AudioManager() // Shared instance
    private var backgroundAudioPlayer: AVAudioPlayer?
    private var soundEffectAudioPlayer: AVAudioPlayer?
    private var soundSelectAudioPlayer: AVAudioPlayer?
    private var coldBootSoundAudioPlayer: AVAudioPlayer?
    private var backSoundAudioPlayer: AVAudioPlayer?
    private var auroraSoundAudioPlayer: AVAudioPlayer?
    private var featUnlockedSoundPlayer: AVAudioPlayer?
    
    
    private init() {
        configureAudioSession()
        // Other initialization code...
    }

    
    // New method to toggle mute
       func toggleMute() {
           if let player = backgroundAudioPlayer {
               player.volume = player.volume == 0 ? 0.5 : 0 // Adjust volume level as needed
           }
       }

       // New method to check if the audio is muted
       func isMuted() -> Bool {
           return backgroundAudioPlayer?.volume == 0
       }
   
    func configureAudioSession() {
        do {
            // Set the audio session category to playback and mix with others
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

    func playBackgroundAudio(fileName: String) {
        guard backgroundAudioPlayer == nil else {
            return // If audio player is already playing, do nothing
        }
        
        if let audioPath = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            let audioURL = URL(fileURLWithPath: audioPath)
            do {
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                backgroundAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundAudioPlayer?.volume = 0.5 // Adjust volume as needed
                backgroundAudioPlayer?.play()
            } catch {
                print("Error loading background audio: \(error)")
            }
        }
    }
    
    func playFeatUnlockedSoundEffect() {
        // Check if the sound is already prepared, otherwise load it
        if featUnlockedSoundPlayer == nil {
            if let soundURL = Bundle.main.url(forResource: "feat unlocked", withExtension: "wav") {
                do {
                    // Initialize the sound player with the URL
                    featUnlockedSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    featUnlockedSoundPlayer?.prepareToPlay() // Prepare the player to reduce latency when playing
                } catch {
                    print("Error initializing feat_unlocked.wav: \(error.localizedDescription)")
                    return
                }
            } else {
                print("feat_unlocked.wav file not found.")
                return
            }
        }

        // Play the sound effect
        featUnlockedSoundPlayer?.play()
    }

    func playDefaultBackgroundMusic() {
            playBackgroundAudio(fileName: "PlayStation 4 System Music - OFFICIAL Home Menu (HIGH QUALITY)")
        }

        
        func playBackEffect() {
            do {
                let soundEffectPath = Bundle.main.path(forResource: "psClick", ofType: "wav")
                let soundEffectURL = URL(fileURLWithPath: soundEffectPath!)
                backSoundAudioPlayer = try AVAudioPlayer(contentsOf: soundEffectURL)
                backSoundAudioPlayer?.numberOfLoops = 0 // Play only once (no loop)
                backSoundAudioPlayer?.volume = 0.88 // Adjust volume as needed
                backSoundAudioPlayer?.play()
            } catch {
                print("Error loading sound effect: \(error)")
            }
        }
        
        func playSoundEffect() {
            do {
                let soundEffectPath = Bundle.main.path(forResource: "psClick", ofType: "wav")
                let soundEffectURL = URL(fileURLWithPath: soundEffectPath!)
                soundEffectAudioPlayer = try AVAudioPlayer(contentsOf: soundEffectURL)
                soundEffectAudioPlayer?.numberOfLoops = 0 // Play only once (no loop)
                soundEffectAudioPlayer?.volume = 0.88 // Adjust volume as needed
                soundEffectAudioPlayer?.play()
            } catch {
                print("Error loading sound effect: \(error)")
            }
        }
    
    func playSoundEffect0() {
        do {
            let soundEffectPath = Bundle.main.path(forResource: "sexySelect", ofType: "wav")
            let soundEffectURL = URL(fileURLWithPath: soundEffectPath!)
            soundSelectAudioPlayer = try AVAudioPlayer(contentsOf: soundEffectURL)
            soundSelectAudioPlayer?.numberOfLoops = 0 // Play only once (no loop)
            soundSelectAudioPlayer?.volume = 0.88 // Adjust volume as needed
            soundSelectAudioPlayer?.play()
        } catch {
            print("Error loading sound effect: \(error)")
        }
    }
        
        func playColdBootSound() {
            do {
                let soundEffectPath = Bundle.main.path(forResource: "ColdbootNewest", ofType: "wav")
                let soundEffectURL = URL(fileURLWithPath: soundEffectPath!)
                coldBootSoundAudioPlayer = try AVAudioPlayer(contentsOf: soundEffectURL)
                coldBootSoundAudioPlayer?.numberOfLoops = 0 // Play only once (no loop)
                coldBootSoundAudioPlayer?.volume = 0.88 // Adjust volume as needed
                coldBootSoundAudioPlayer!.play()
            } catch {
                print("Error loading sound effect: \(error)")
            }
        }
        
        func stopBackgroundAudio() {
            backgroundAudioPlayer?.stop()
            backgroundAudioPlayer = nil
        }
    
    func resumeBackgroundAudio() {
        guard let player = backgroundAudioPlayer else {
            return
        }
        if player.rate == 0 && !player.isPlaying {
            player.play()
        }
    }
    
    func isBackgroundAudioPlaying() -> Bool {
          guard let player = backgroundAudioPlayer else {
              return false
          }
          return player.isPlaying
      }
    
    func pauseBackgroundAudio() {
         guard let player = backgroundAudioPlayer else {
             return
         }

         if player.isPlaying {
             player.pause()
         }
     }
    
}
    
    
    

