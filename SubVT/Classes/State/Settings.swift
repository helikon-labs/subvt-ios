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
    
    static func setNetworkList(_ networks: [Network]) {
        let data = try! jsonEncoder.encode(networks)
        userDefaults.set(data, forKey: Key.networks.rawValue)
    }
    
    static func getNetworks() -> [Network]? {
        if let data = userDefaults.data(forKey: Key.networks.rawValue) {
            return try! jsonDecoder.decode([Network].self, from: data)
        }
        return nil
    }
    
    static func setSelectedNetwork(_ network: Network) {
        let data = try! jsonEncoder.encode(network)
        userDefaults.set(data, forKey: Key.selectedNetwork.rawValue)
    }
    
    static func getSelectedNetwork() -> Network? {
        if let data = userDefaults.data(forKey: Key.selectedNetwork.rawValue) {
            return try! jsonDecoder.decode(Network.self, from: data)
        }
        return nil
    }
    
    private enum Key: String {
        case hasOnboarded = "io.subvt.has_onboarded"
        case networks = "io.subvt.networks"
        case selectedNetwork = "io.subvt.selected_network"
    }
}
