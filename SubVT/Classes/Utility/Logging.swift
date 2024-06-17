//
//  Logging.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.10.2022.
//

import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self

func initLog() {
    let console = ConsoleDestination()
    log.addDestination(console)
}
