//
//  UserDefaults.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.10.2022.
//

import Foundation

struct UserDefaultsUtil {
    static let shared = UserDefaults(
        suiteName: "io.helikon.subvt.watch.user_defaults"
    )!
}
