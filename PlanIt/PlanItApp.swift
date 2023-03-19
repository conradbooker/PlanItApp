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
    @AppStorage("darkMode") var darkMode: Int = 0
    
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
            if darkMode == 0 {
                withAnimation(.linear) {
                    ContentView()
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                        .preferredColorScheme(.light)
                        .onAppear {
                            PythonSupport.initialize()
                        }
                }
            } else if darkMode == 1 {
                withAnimation(.linear) {
                    ContentView()
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                        .preferredColorScheme(.dark)
                        .onAppear {
                            PythonSupport.initialize()
                        }
                }
            } else {
                withAnimation(.linear) {
                    ContentView()
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                        .onAppear {
                            PythonSupport.initialize()
                        }
                }
            }
        }
    }
}
