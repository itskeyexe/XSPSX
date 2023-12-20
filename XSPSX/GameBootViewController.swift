//
//  GameBootViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 7/19/23.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Network


class GameBootViewController: UIViewController, AVPlayerViewControllerDelegate {
    
    
//game title elements
    @IBOutlet weak var gameTitleView: UIView!
    @IBOutlet weak var gameTitleStartButton: UIButton!
    @IBOutlet weak var gameTitleExitButton: UIButton!
    @IBOutlet weak var gameTitleImage: UIImageView!
    
    //gameplay view elements
    @IBOutlet weak var scrollerBackground1View: UIImageView!
    @IBOutlet weak var scrollerBackground0View: UIImageView!
    @IBOutlet weak var gameplayView: UIView!
    @IBOutlet weak var fighterSpriteView: UIImageView!
    @IBOutlet weak var controllsUIView: UIView!

    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var fireButton: UIButton!
    
    //gameplay Paused UI elements
    @IBOutlet weak var gameplayPauseMenu: UIView!
    @IBOutlet weak var gamePausedLabel: UILabel!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseExitButton: UIButton!
    
    //Joystick UI elements
    var joystickBaseView: UIView!
        var joystickThumbView: UIView!
        let joystickMaxRadius: CGFloat = 50  // Max distance thumbstick can move
    
    //
    var movementTimer: Timer?
    var displayLink: CADisplayLink?
    var currentDirection: CGPoint?
    
    var initialSpriteX: CGFloat = 0  // Start at the left edge of the screen
       var initialSpriteY: CGFloat = 0  // This will be calculated to center the sprite vertically
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupJoystick()
        calculateInitialSpritePosition()

    }
    
    func calculateInitialSpritePosition() {
            // Assuming fighterSpriteView has a valid size at this point
            // Center the sprite vertically
            initialSpriteY = (gameplayView.bounds.height - fighterSpriteView.bounds.height) / 2
        }
    
    
    @IBAction func gameStartButtonPressed(_ sender: UIButton) {
        AudioManager.shared.playBackEffect()
        gameTitleView.isHidden = true // Hide the game title view
        startScrollingBackground() // Function to start the background scrolling
        fighterSpriteView.isHidden = false // Show the fighter sprite
        controllsUIView.isHidden = false // Show control buttons

        // Enable buttons
        pauseButton.isEnabled = true
        fireButton.isEnabled = true
        joystickBaseView.isHidden = false
            joystickThumbView.isHidden = false
    }

    func startScrollingBackground() {
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height

        // Set initial frames
        scrollerBackground0View.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        scrollerBackground1View.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewHeight)

        let duration: TimeInterval = 3.0

        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            // Move each background image to the left
            self.scrollerBackground0View.frame.origin.x -= viewWidth
            self.scrollerBackground1View.frame.origin.x -= viewWidth
        }) { _ in
            // Reset positions of the background views
            self.scrollerBackground0View.frame.origin.x = 0
            self.scrollerBackground1View.frame.origin.x = viewWidth

            // Restart the animation
            self.startScrollingBackground()
        }
    }

    func setupJoystick() {
        let baseSize: CGFloat = 120  // Increased by 20%
        let thumbSize: CGFloat = 60  // Increased by 20%

        joystickBaseView = UIView(frame: CGRect(x: 60, y: view.bounds.height - baseSize - 20, width: baseSize, height: baseSize))
        joystickBaseView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)  // Semi-transparent
        joystickBaseView.layer.cornerRadius = baseSize / 2
        view.addSubview(joystickBaseView)

        joystickThumbView = UIView(frame: CGRect(x: (baseSize - thumbSize) / 2, y: (baseSize - thumbSize) / 2, width: thumbSize, height: thumbSize))
        joystickThumbView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)  // Semi-transparent
        joystickThumbView.layer.cornerRadius = thumbSize / 2
        joystickBaseView.addSubview(joystickThumbView)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, joystickBaseView.bounds.contains(touch.location(in: joystickBaseView)) else { return }
        updateJoystickThumbPosition(touch: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, joystickBaseView.bounds.contains(touch.location(in: joystickBaseView)) else { return }
        updateJoystickThumbPosition(touch: touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetJoystickThumbPosition()
        stopMovingSprite()
    }

    func updateJoystickThumbPosition(touch: UITouch) {
        let position = touch.location(in: joystickBaseView)
        let distance = sqrt(pow(position.x - joystickBaseView.bounds.midX, 2) + pow(position.y - joystickBaseView.bounds.midY, 2))
        let angle = atan2(position.y - joystickBaseView.bounds.midY, position.x - joystickBaseView.bounds.midX)

        let thumbX: CGFloat = min(joystickMaxRadius, distance) * cos(angle)
        let thumbY: CGFloat = min(joystickMaxRadius, distance) * sin(angle)

        joystickThumbView.center = CGPoint(x: joystickBaseView.bounds.midX + thumbX, y: joystickBaseView.bounds.midY + thumbY)
        updateSpriteDirection(distance: distance, angle: angle)
    }

    func resetJoystickThumbPosition() {
        joystickThumbView.center = CGPoint(x: joystickBaseView.bounds.midX, y: joystickBaseView.bounds.midY)
    }
    

    
    func updateSpriteDirection(distance: CGFloat, angle: CGFloat) {
        let directionStrength = min(distance / joystickMaxRadius, 1.0)  // Normalize to 0.0 - 1.0
        let deadZone: CGFloat = 3.0  // Smaller dead zone value

        if distance < deadZone {
            stopMovingSprite()
            return
        }

        let dx = directionStrength * cos(angle)
        let dy = directionStrength * sin(angle)

        let direction = CGPoint(x: dx, y: dy)  // Correct the y-axis direction
        startMovingSprite(direction: direction)
    }


    // MARK: - Movement Methods
    func startMovingSprite(direction: CGPoint) {
        currentDirection = direction
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateSpritePosition))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc func updateSpritePosition() {
        guard let direction = currentDirection else { return }
        moveSprite(direction: direction)
    }

    func moveSprite(direction: CGPoint) {
        
        print("Moving sprite to position: \(fighterSpriteView.frame.origin)")
        let movementAmount: CGFloat = 5  // Adjust as needed

        UIView.animate(withDuration: 0.05, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
            // Calculate new position
            var newX = self.fighterSpriteView.frame.origin.x + movementAmount * direction.x
            var newY = self.fighterSpriteView.frame.origin.y + movementAmount * direction.y

            // Constrain to gameplayView bounds
            newX = max(0, min(self.gameplayView.bounds.width - self.fighterSpriteView.frame.width, newX))
            newY = max(0, min(self.gameplayView.bounds.height - self.fighterSpriteView.frame.height, newY))

            // Update sprite position
            self.fighterSpriteView.frame.origin.x = newX
            self.fighterSpriteView.frame.origin.y = newY
        }, completion: nil)
    }




  

     func stopMovingSprite() {
         displayLink?.invalidate()
         displayLink = nil
         currentDirection = nil
     }



    @IBAction func fireButtonPressed(_ sender: Any) {
        
        print("Firing laser from position: \(fighterSpriteView.frame.origin)")
        AudioManager.shared.playBackEffect()

        let laserView = createLaser()
        gameplayView.addSubview(laserView)

        // Animate the laser
        UIView.animate(withDuration: 1.0, animations: {
            laserView.frame.origin.x = self.gameplayView.bounds.width
        }) { _ in
            laserView.removeFromSuperview()  // Remove the laser after reaching the end
        }
    }


    
    func createLaser() -> UIImageView {
        let laserImage = UIImage(named: "laser.png")!
        let laserImageView = UIImageView(image: laserImage)

        // Set the size of the laser - adjust width and height as needed
        let laserWidth: CGFloat = 30 // Example width, adjust as needed
        let laserHeight: CGFloat = 5 // Example height, adjust as needed

        laserImageView.frame = CGRect(x: fighterSpriteView.center.x - laserWidth / 2,
                                      y: fighterSpriteView.center.y - laserHeight / 2,
                                      width: laserWidth,
                                      height: laserHeight)
        
        // Set zPosition to be behind the fighter sprite
        laserImageView.layer.zPosition = fighterSpriteView.layer.zPosition - 1

        return laserImageView
    }




    


    @IBAction func gamePauseButtonPressed(_ sender: Any) {
        AudioManager.shared.playBackEffect()
        pauseLayer(layer: scrollerBackground0View.layer)
            pauseLayer(layer: scrollerBackground1View.layer)

        //disable up down left right and fire

        fireButton.isEnabled = false

        //show Game Paused UI View
        gameplayPauseMenu.isHidden = false
        resumeButton.isEnabled = true
        pauseExitButton.isEnabled = true

    }
    

    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        gameplayPauseMenu.isHidden = true

        resumeLayer(layer: scrollerBackground0View.layer)
            resumeLayer(layer: scrollerBackground1View.layer)

        fireButton.isEnabled = true
    }
    
    @IBAction func pauseExitButtonPressed(_ sender: UIButton) {
        AudioManager.shared.playBackEffect()
        gameplayPauseMenu.isHidden = true
        gameTitleView.isHidden = false
        resetGame()

    }
    
    func resetGame() {
          // Reset background position
          resetBackground()

          // Reset sprite position
          resetSpritePosition()

          // Hide joystick
          joystickBaseView.isHidden = true
          joystickThumbView.isHidden = true
      }
    
    func resetBackground() {
           let viewWidth = view.frame.width
           let viewHeight = view.frame.height
           scrollerBackground0View.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
           scrollerBackground1View.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewHeight)
       }
    
    func resetSpritePosition() {
        // Set to the initial position of the sprite
        fighterSpriteView.frame.origin = CGPoint(x: initialSpriteX, y: initialSpriteY)
    }



    
    //pause layer helper
    func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

    
    @IBAction func gameTitleExitButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "XSPSXViewController")
        newViewController.view.alpha = 0
        self.present(newViewController, animated: false) {
            UIView.animate(withDuration: 0.3) {
                newViewController.view.alpha = 1
            }
        }
    }

}


