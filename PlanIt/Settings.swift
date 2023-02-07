//
//  Settings.swift
//  PlanIt
//
//  Created by Conrad on 12/23/22.
//

import SwiftUI

extension String {
    func lower() -> String {
        @AppStorage("aestheticMode") var aestheticMode: Bool = false
        if aestheticMode {
            return self.lowercased()
        }
        return self
    }
}

struct Settings: View {
    @State private var link: String = ""
    @State private var showSync: Bool = false
    let persistedContainer = CoreDataManager.shared.persistentContainer
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @AppStorage("disableTimer") var disableTimer: Bool = false
    @AppStorage("aestheticMode") var aestheticMode: Bool = false
    @AppStorage("bgColor") var bgColor: String = ""
    @AppStorage("fgColor") var fgColor: String = ""

    private func deleteAssignments() {
        for assignment in allAssignments {
            viewContext.delete(assignment)
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Button(action: {
                    showSync.toggle()
                }, label: {
                    Text("Sync Assignments from myschoolapp, or schology")
                })

                Section(header: Text("General")) {
                    Toggle("Disable Timer".lower(), isOn: $disableTimer)
                    Toggle("Aesthetic Mode".lower(), isOn: $aestheticMode)
                    Text("Profile".lower())
                    Text("Color Theme".lower())
                    Text("Dark Mode".lower())
                    Text("Language".lower())
                    Text("Key".lower())
                    .foregroundColor(.red)
                    
                }
                Section(header: Text("Help")) {
                    Text("Quick start guide".lower())
                    Text("How to use".lower())
                    Text("FAQ".lower())
                    Button("Delete all assignments".lower()) {
                        deleteAssignments()
                    }
                }
                Section(header: Text("Notifications")) {
                    Text("Configure Notifications".lower())
                    Text("View Notifications".lower())
                }
                Section(header: Text("ABOUT")) {
                    Text("About Schematica".lower())
                    Text("Other Apps".lower())
                    Text("View socials".lower())
                    Text("View Website".lower())
                    Text("Version: 0.1".lower())
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showSync) {
                ExternalSource().environment(\.managedObjectContext, persistedContainer.viewContext)
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Settings()
    }
}
