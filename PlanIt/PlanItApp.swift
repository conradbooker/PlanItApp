//
//  PlanItApp.swift
//  PlanIt
//
//  Created by Conrad on 12/16/22.
//

import SwiftUI

@main
struct PlanItApp: App {
    
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
