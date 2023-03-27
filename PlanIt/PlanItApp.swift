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
    @AppStorage("darkMode") var darkMode: Int = 3
    
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
    @Environment(\.colorScheme) var colorScheme

    private func getColorScheme() -> ColorScheme {
        if darkMode == 0 {
            return .light
        } else if darkMode == 1 {
            return .dark
        }
        if colorScheme == .dark {
            return .dark
        }
        return .light
    }

    var body: some Scene {
        WindowGroup {
                withAnimation(.linear) {
                    SplashScreen()
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                        .preferredColorScheme(getColorScheme())
                        .onAppear {
                            PythonSupport.initialize()
                        }
                }
        }
    }
}
