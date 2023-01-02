//
//  functions.swift
//  PlanIt
//
//  Created by Conrad on 1/2/23.
//

import Foundation
import SwiftUI
import Network

func hasConnection() -> Bool {
    let monitor = NWPathMonitor()
    var isConnected = true
    
    monitor.pathUpdateHandler = { path in
       if path.status == .satisfied {
           isConnected = true
       } else {
           isConnected = false
       }
    }
    return isConnected
    
}
