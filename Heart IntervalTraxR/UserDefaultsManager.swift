//
//  UserDefaultsManager.swift
//  Heart IntervalTraxR
//
//  Created by DJ McKay on 12/3/17.
//  Copyright © 2017 DJ McKay. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    
    static let defaults: UserDefaults = UserDefaults.standard
    
    static fileprivate let numberOfRuns = "numberOfRuns"
    
    static var appRuns: Int {
        get {
            return defaults.integer(forKey: numberOfRuns)
        }
        set {
            defaults.set(newValue, forKey: numberOfRuns)
        }
    }
    
    static func incrementAppRuns() -> Int {
        self.appRuns += 1
        return self.appRuns
    }
    
    static var HKAuthorized: Bool {
        get {
            print(defaults.bool(forKey: "HKAuthorized"))
            return defaults.bool(forKey: "HKAuthorized")
        }
        set {
            defaults.set(newValue, forKey: "HKAuthorized")
            print(defaults.bool(forKey: "HKAuthorized"))
        }
    }
}
