//
//  Settings.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import Foundation

final class Settings {
    private static let userDefaults = UserDefaults(suiteName: "group.io.helikon.subvt")!
    
    static var hasOnboarded: Bool {
        get {
            userDefaults.bool(forKey: Key.hasOnboarded.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.hasOnboarded.rawValue)
        }
    }
    
    private enum Key: String {
        case hasOnboarded = "has_onboarded"
    }
}
