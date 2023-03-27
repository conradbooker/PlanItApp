//
//  ContentView.swift
//  PlanIt
//
//  Created by Conrad on 12/16/22.
//

import SwiftUI

var PlanItVersion: Double = 0.95
var PlanItVersionStr: String = String(format: "%.2f", PlanItVersion)

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    @State var selectedTab: String = "Home"
    @State var showSheet: Bool = false
    @State var selectedDate: Date = Date()
    @State var show: Bool = true
    
    private func hideTaskBar() {
        withAnimation(.linear) { show = false }
    }
    private func showTaskBar() {
        withAnimation(.linear) { show = false }
    }

    var body: some View {
        ZStack {
            VStack {
                switch selectedTab {
                case "Home": Home(selectedDate: selectedDate)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                case "Agenda": Checklist(selectedDate: selectedDate)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                case "Due": Due(selectedDate: selectedDate)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                case "Settings": Settings()
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                default: Home(selectedDate: selectedDate)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                }
            }
            if show {
                TabBar(selectedTab: $selectedTab, showSheet: $showSheet, selectedDate: $selectedDate)
            }
        }
        .sheet(isPresented: $showSheet) {
            New(isPresented: $showSheet)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
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
