//
//  FavoritesAlbumViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 12/9/23.
//
import Foundation
import UIKit
import Photos

class FavoritesAlbumViewController: UIViewController {
    var favoriteImageNames: [String] = ["browser", "music", "spoofer", "profile"]
    let closeButton = UIButton()
    let nextButton = UIButton()
    let previousButton = UIButton()
    var imageView: UIImageView!
    var pageControl: UIPageControl!
    var currentPhotoIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupCloseButton()
        setupNavigationButtons()
        setupPageControl()
        view.bringSubviewToFront(imageView)
    }
    func setupImageView() {
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear // Placeholder color
        view.addSubview(imageView)
       
    }
    func setupCloseButton() {
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    func setupNavigationButtons() {
        nextButton.setTitle("Next", for: .normal)
        previousButton.setTitle("Previous", for: .normal)
        nextButton.backgroundColor = .systemGreen
        previousButton.backgroundColor = .systemRed
        nextButton.addTarget(self, action: #selector(nextPhoto), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousPhoto), for: .touchUpInside)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nextButton.widthAnchor.constraint(equalToConstant: 80),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            
            previousButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            previousButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            previousButton.widthAnchor.constraint(equalToConstant: 80),
            previousButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50))
        pageControl.hidesForSinglePage = true
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func nextPhoto() {
        if currentPhotoIndex < favoriteImageNames.count - 1 {
            currentPhotoIndex += 1
            updatePhotoDisplay()
        }
    }

    @objc func previousPhoto() {
        if currentPhotoIndex > 0 {
            currentPhotoIndex -= 1
            updatePhotoDisplay()
        }
    }

    func updatePhotoDisplay() {
        let imageName = favoriteImageNames[currentPhotoIndex]
        imageView.image = UIImage(named: imageName) ?? UIImage(named: "defaultImage")
        pageControl.currentPage = currentPhotoIndex
    }

    func setupInitialPhoto() {
        if let firstImageName = favoriteImageNames.first {
            imageView.image = UIImage(named: firstImageName) ?? UIImage(named: "defaultImage")
            pageControl.numberOfPages = favoriteImageNames.count
            pageControl.currentPage = currentPhotoIndex
        }
    }

}
