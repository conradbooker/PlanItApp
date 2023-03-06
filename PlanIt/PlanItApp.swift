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
                    PythonSupport.initialize()
                    
                    
//                    @AppStorage("pyJSonData") var pyJSonData: String = ""
//                    pyJSonData = String(runPythonICSJSon("https://trinityschoolnyc.myschoolapp.com/podium/feed/iCal.aspx?z=HdbCT3ZaWBaxtYaG0jy3COOOHSIw9SwPejVt1ZiRL0e%2f1LkExSAan453LoSYfB4QMIeAjRyRcFPyvvRbCsQ7QA%3d%3d")) ?? "Error"
//                    if pyJSonData == "Error" || pyJSonData == """
//                    [
//                       {}
//                    ]
//                    """
//                    {
//                        print("Error loading JSon")
//                    }
                    print("hiii")
                }
        }
    }
}
