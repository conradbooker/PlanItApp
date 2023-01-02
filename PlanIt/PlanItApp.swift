//
//  PlanItApp.swift
//  PlanIt
//
//  Created by Conrad on 12/16/22.
//

import SwiftUI
import PythonSupport
//import Network


@main
struct PlanItApp: App {
    
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
//    private func hasConnection() -> Bool {
//        let monitor = NWPathMonitor()
//        var isConnected = true
//        
//        monitor.pathUpdateHandler = { path in
//           if path.status == .satisfied {
//               isConnected = true
//           } else {
//               isConnected = false
//           }
//        }
//        return isConnected
//        
//    }

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
                .onAppear {
//                    if hasConnection() {
                        PythonSupport.initialize()
//                    } else {
//                        print("Error, network connection needed to initialize PythonSupport")
//                    }
                }
        }
    }
}
