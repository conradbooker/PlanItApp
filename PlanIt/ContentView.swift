//
//  ContentView.swift
//  PlanIt
//
//  Created by Conrad on 12/16/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer

    var body: some View {
        
        TabView {
            Home().environment(\.managedObjectContext, persistedContainer.viewContext)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Checklist().environment(\.managedObjectContext, persistedContainer.viewContext)
                .tabItem {
                    Label("Agenda", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
            New().environment(\.managedObjectContext, persistedContainer.viewContext)
                .tabItem {
                    Label("New", systemImage: "plus.circle")
                }
            Due()
                .tabItem {
                    Label("Due", systemImage: "exclamationmark.triangle.fill")
                }
            Settings().environment(\.managedObjectContext, persistedContainer.viewContext)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.2")
                }
        }
    }
}

struct CustomColor {
    static let cGray1 = Color("cDarkGray")
    static let cGray2 = Color("cLessDarkGray")
    static let redCustom = Color("backgroundColor")
    // Add more here...
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        ContentView().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
