//
//  PasswordManager.swift
//  Project28
//
//  Created by Mahmud CIKRIK on 6.11.2023.
//

import Foundation
import UIKit
import LocalAuthentication

class PasswordManager {
    
    func savePasswordToKeychain(_ passwordText: String?) {
        guard let password = passwordText else { return }
        KeychainWrapper.standard.set(password, forKey: "password")
        
    }
    
    func readPasswordFromKeychain() -> String? {
        guard let storedPassword = KeychainWrapper.standard.string(forKey: "password") else { return nil }
        return storedPassword
    }
    
    func deletePasswordFromKeychain() {
    KeychainWrapper.standard.removeObject(forKey: "password")
    
    }
    
}
