//
//  MessageViewController.swift
//  XSPSX
//
//  Created by Wyatt Kerkes on 12/5/23.
//

import UIKit
import MessageUI

class MessagingViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    let recipientTextField = UITextField()
    let messageBodyTextView = UITextView()
    let sendButton = UIButton(type: .system)
    let scrollView = UIScrollView()
    let contentView = UIView()
    let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Assuming a dark theme from your screenshots
        view.alpha = 0.88
        setupUI()
        registerForKeyboardNotifications()
    }
    
    func setupUI() {
        // Add scrollView to the view and set its constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add contentView to the scrollView and set its constraints
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Set up the recipient text field and add it to the contentView
        recipientTextField.delegate = self
        recipientTextField.placeholder = "Enter recipient's number"
        recipientTextField.textColor = .white
        recipientTextField.borderStyle = .roundedRect
        recipientTextField.keyboardType = .phonePad
        recipientTextField.backgroundColor = .black
        contentView.addSubview(recipientTextField)
        
        // Set up the message body text view and add it to the contentView
        messageBodyTextView.delegate = self
        messageBodyTextView.text = "Hallo von XSPSX! :D"
        messageBodyTextView.textColor = .systemCyan
        messageBodyTextView.backgroundColor = .black
        messageBodyTextView.layer.borderColor = UIColor.gray.cgColor
        messageBodyTextView.layer.borderWidth = 1.0
        messageBodyTextView.layer.cornerRadius = 5.0
        contentView.addSubview(messageBodyTextView)
        
        // Set up the send button and add it to the contentView
        sendButton.setTitle("Send Message", for: .normal)
        sendButton.backgroundColor = .cyan // For visibility against the dark background
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.layer.cornerRadius = 5
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        contentView.addSubview(sendButton)
        
        // Set up the close button and add it to the contentView
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeMessagingView), for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        // Constraints for the recipientTextField
        recipientTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipientTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            recipientTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recipientTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recipientTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Constraints for the messageBodyTextView
        messageBodyTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageBodyTextView.topAnchor.constraint(equalTo: recipientTextField.bottomAnchor, constant: 20),
            messageBodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageBodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageBodyTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Constraints for the sendButton
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: messageBodyTextView.bottomAnchor, constant: 20),
            sendButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            sendButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        // Constraints for the closeButton
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.widthAnchor.constraint(equalToConstant: 200),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // This helps to determine the scrollable content size
        ])
    }
    
    // ... All the keyboard handling methods ...
    
    // MFMessageComposeViewControllerDelegate method
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // UITextFieldDelegate method to adjust scrollView contentOffset when textField is active
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let textFieldRect = textField.convert(textField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(textFieldRect, animated: true)
    }
    
    // UITextViewDelegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
        let textViewRect = textView.convert(textView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(textViewRect, animated: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your message here"
            textView.textColor = .lightGray
        }
    }
    
    @objc func closeMessagingView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sendMessage() {
        guard let recipientNumber = recipientTextField.text, !recipientNumber.isEmpty else {
            print("Recipient number is empty.")
            return
        }

        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self

            // Configure the fields of the interface.
            composeVC.recipients = [recipientNumber]
            composeVC.body = messageBodyTextView.text == "Enter your message here" ? "" : messageBodyTextView.text

            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Cannot send texts.")
            // Handle the error here
        }
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
