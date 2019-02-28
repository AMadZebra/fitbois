//
//  classes.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 10/26/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//
import Foundation

// Usage:
// Getting: phoneNumber = Storage.phoneNumberInE164
// Setting: Storage.phoneNumberInE164 = phoneNumber

struct Storage {
    static var phoneNumberInE164: String? {
        get {
            return UserDefaults.standard.string(forKey: "phoneNumberInE164")
        }
        
        set(phoneNumberInE164) {
            UserDefaults.standard.set(phoneNumberInE164, forKey: "phoneNumberInE164")
            print("Saving phone number was \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var authToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "authToken")
        }
        
        set(authToken) {
            UserDefaults.standard.set(authToken, forKey: "authToken")
            print("Saving auth token was \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var hour: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "hour")
        }
        
        set(hour) {
            UserDefaults.standard.set(hour, forKey: "hour")
            print("Saving hour was \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var minute: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "minute")
        }
        
        set(minute) {
            UserDefaults.standard.set(minute, forKey: "minute")
            print("Saving minute was \(UserDefaults.standard.synchronize())")
        }
    }
}
