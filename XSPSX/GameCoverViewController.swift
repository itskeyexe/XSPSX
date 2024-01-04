//
//  GameCoverViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 1/3/24.
//

import Foundation
import UIKit

class GameCoverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView! // It's implicitly unwrapped; ensure it's set up before use
    var titleLabel: UILabel!
    let gameTitles = ["Back 4 Blood", "Demon's Souls", "Ghost", "Bloodborne", "P.T.", "Days Gone"]
    var timeDateLabel: UILabel!
    var batteryIcon: UIImageView!
    var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTitleLabel()
        setupCollectionView()
        setupDateTimeLabel()
        setupBatteryIcon()
        setupCloseButton()
        // Register for battery level and state change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDateTimeLabel), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    private func setupDateTimeLabel() {
           timeDateLabel = UILabel()
           timeDateLabel.textColor = .white
           timeDateLabel.font = UIFont.systemFont(ofSize: 14)
           timeDateLabel.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(timeDateLabel)

           NSLayoutConstraint.activate([
               timeDateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
               timeDateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
           ])

           updateDateTimeLabel()
       }
    
    private func setupBatteryIcon() {
           batteryIcon = UIImageView()
           batteryIcon.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(batteryIcon)

           NSLayoutConstraint.activate([
               batteryIcon.topAnchor.constraint(equalTo: timeDateLabel.bottomAnchor, constant: 5),
               batteryIcon.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
               batteryIcon.widthAnchor.constraint(equalToConstant: 25),
               batteryIcon.heightAnchor.constraint(equalToConstant: 25)
           ])

           updateBatteryStatus()
       }
    
    @objc func batteryLevelDidChange(notification: Notification) {
        DispatchQueue.main.async {
            self.updateBatteryStatus()
        }
    }
    func updateBatteryStatus() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel >= 0.75 {
            batteryIcon.image = UIImage(named: batteryImageArray[0])
        } else if batteryLevel >= 0.5 {
            batteryIcon.image = UIImage(named: batteryImageArray[1])
        } else if batteryLevel >= 0.25 {
            batteryIcon.image = UIImage(named: batteryImageArray[2])
        } else {
            batteryIcon.image = UIImage(named: batteryImageArray[3])
        }
    }
    
    private func setupCloseButton() {
           closeButton = UIButton(type: .system)
           closeButton.setTitle("Close", for: .normal)
           closeButton.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
           closeButton.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(closeButton)

           NSLayoutConstraint.activate([
               closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
               closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
           ])
       }
    
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "moon") // Ensure "moon" image exists in your assets
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.text = gameTitles.first // Safely unwrapping first element
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        let layout = TiltedFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 300)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GameCoverCell.self, forCellWithReuseIdentifier: "GameCoverCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Adjust content insets to allow first and last items to be centered
        let sideInset = (view.bounds.width - layout.itemSize.width) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)

        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    }

    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCoverCell", for: indexPath) as! GameCoverCell
        // Configure the cell with the placeholder image
        cell.setGameCoverImage(named: "gameCoverExample")
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Define the size for the collection view cells
        return CGSize(width: 200, height: 300)
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Update the title label for the selected game
        titleLabel.text = gameTitles[indexPath.row]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Force layout update
        collectionView?.layoutIfNeeded()
        // Update the title label with the name of the centered game
            let centerPoint = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x, y: 50)
            if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
                titleLabel.text = gameTitles[indexPath.row]
            }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // This is the center point where the collection view will stop
        let proposedContentOffsetCenterX = targetContentOffset.pointee.x + scrollView.bounds.size.width * 0.5
        
        // Calculate the target index path for the item closest to this point
        let closestIndexPath = collectionView.layoutAttributesForElements(in: scrollView.bounds)?
            .sorted(by: { abs($0.center.x - proposedContentOffsetCenterX) < abs($1.center.x - proposedContentOffsetCenterX) })
            .first?.indexPath
        
        // Update the targetContentOffset to ensure the item is centered
        if let indexPath = closestIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func closeViewController() {
           dismiss(animated: true, completion: nil)
       }

}

// Custom UICollectionViewLayout subclass
class TiltedFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Retrieve the default layout attributes
        let attributesArray = super.layoutAttributesForElements(in: rect)
        
        // Calculate the center of the collection view relative to its content offset
        let horizontalCenter = collectionView!.contentOffset.x + (collectionView!.bounds.width / 2.0)
        
        attributesArray?.forEach { attributes in
            // Calculate the distance from the center of the viewport
            let distanceFromCenter = horizontalCenter - attributes.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), collectionView!.bounds.width / 2.0)
            let scale = absDistanceFromCenter / (collectionView!.bounds.width / 2.0)
            
            // Scale and alpha transformations
            let scaledTransform = CATransform3DScale(CATransform3DIdentity, 1 - scale * 0.25, 1 - scale * 0.25, 1)
            let alpha = 1 - scale * 0.5
            
            // Translate the cell as it moves off the center to give the tilt effect
            let translationTransform: CATransform3D
            if distanceFromCenter > 0 {
                translationTransform = CATransform3DTranslate(scaledTransform, -50 * scale, 0, 0) // Tilt to the left
            } else {
                translationTransform = CATransform3DTranslate(scaledTransform, 50 * scale, 0, 0) // Tilt to the right
            }
            
            // Apply the transforms
            attributes.transform3D = translationTransform
            attributes.alpha = alpha
            
            // Keep the center item on top
            attributes.zIndex = Int((1 - scale) * 10)
        }
        
        return attributesArray
    }

    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that tilt effect can be recalculated as user scrolls
        return true
    }
}

class GameCoverCell: UICollectionViewCell {
    var gameImageView: UIImageView!
    var reflectionView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
          gameImageView = UIImageView(frame: self.bounds)
          addSubview(gameImageView)
          
          reflectionView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height * 2)) // reflectionView now fills to the bottom of the screen
          addSubview(reflectionView)
          sendSubviewToBack(reflectionView) // Make sure reflection view is behind the game image view
          
          createReflection()
      }
    
    private func createReflection() {
        // Use a gradient layer as mask for the reflection
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = reflectionView.bounds
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.3).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
            reflectionView.layer.mask = gradientLayer
            reflectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
            reflectionView.alpha = 0.5
    }
    
    func setGameCoverImage(named name: String) {
        // Set the image to a placeholder named "gameCoverExample"
        gameImageView.image = UIImage(named: "gameCoverExample")
        reflectionView.image = gameImageView.image
        // Apply additional transformations if needed to reflectionView to mimic reflection
    }
}



