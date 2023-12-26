//
//  ViewController.swift
//  Project28
//
//  Created by Mahmud CIKRIK on 5.11.2023.
// https://stackoverflow.com/questions/6346065/saving-a-password-in-keychain-on-simulator buraya bak

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    
    let passwordManager = PasswordManager()
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        secret.isHidden = true
        password = passwordManager.readPasswordFromKeychain()
        
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        password = passwordManager.readPasswordFromKeychain()
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                        self?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self?.saveSecretMessage))
                        self?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self?.showDeletePasswordAlert))
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message:"You could not be verified, please try again"  , preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            if password == nil {
                let ac = UIAlertController(title: "Biometry unavailable", message:"Your device has no configured for biometric authentication"  , preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Create a password", style: .default) {
                        _ in
                        self.showPasswordAlert()
                    })
                present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: "Enter your password", message: "", preferredStyle: .alert)
                ac.addTextField()
                ac.addAction(UIAlertAction(title: "OK", style: .default) {
                _ in
                guard let enteredPassword = ac.textFields?[0].text else { return }
                    if self.passwordManager.readPasswordFromKeychain() == enteredPassword {
                        self.unlockSecretMessage()
                    } else {
                        print("Wrong Password Please try again")
                    }
                })
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(ac, animated: true)
                
            }
          
        }
        
    }
        
    @objc func adjustForKeyboard (notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            
        }

        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
        
    }
    
    func unlockSecretMessage () {
        secret.isHidden = false
        title = "Secret Stuff!"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showDeletePasswordAlert))
        
//        ALTERNATİF: if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
//            secret.text = text
//        }
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""

    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem()

    }
    
//    func savePasswordToKeychain() {
//        guard let password = storedPassword else { return }
//        KeychainWrapper.standard.set(password, forKey: "password")
//        
//        
//    }
//    
//    func readPasswordFromKeychain() {
//        if let storedPassword = KeychainWrapper.standard.string(forKey: "password") {
//            if enteredPassword == storedPassword {
//                print("AFFFERİM")
//                unlockSecretMessage()
//            } else { let ac = UIAlertController(title: "Wrong Password", message: "Try Again", preferredStyle: .alert)
//                ac.addTextField()
//                ac.addAction(UIAlertAction(title: "OK", style: .default) {
//                    _ in
//                    guard let tryingPassword = ac.textFields?[0].text else { return }
//                    self.enteredPassword = tryingPassword
//                })
//                readPasswordFromKeychain()
//                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                present(ac, animated: true)
//            }
//        }
//    }
    
    func showPasswordAlert() {
  
        let ac = UIAlertController(title: "Create Password", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
    
            guard let newPassword = ac.textFields?[0].text else { return }
            self.passwordManager.savePasswordToKeychain(newPassword)
        })
        
        present(ac, animated: true)

        
    }
    
    @objc func showDeletePasswordAlert() {
  
        let ac = UIAlertController(title: "Delete Password", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
            self.passwordManager.deletePasswordFromKeychain()
        })
        
        present(ac, animated: true)

        
    }
}

