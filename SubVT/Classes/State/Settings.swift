//
//  Settings.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import Foundation
import SubVTData

final class Settings {
    private static let userDefaults = UserDefaults(suiteName: "group.io.helikon.subvt")!
    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
    
    static var hasOnboarded: Bool {
        get {
            userDefaults.bool(forKey: Key.hasOnboarded.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.hasOnboarded.rawValue)
        }
    }
    
    static func setNetwork(_ network: Network) throws {
        let data = try jsonEncoder.encode(network)
        userDefaults.set(data, forKey: Key.network.rawValue)
    }
    
    static func getNetwork() throws -> Network? {
        if let data = userDefaults.data(forKey: Key.network.rawValue) {
            return try jsonDecoder.decode(Network.self, from: data)
        }
        return nil
    }
    
    private enum Key: String {
        case hasOnboarded = "io.subvt.has_onboarded"
        case network = "io.subvt.network"
    }
}
