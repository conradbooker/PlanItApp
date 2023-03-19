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
    @AppStorage("twofourhourtime") var twofourhourtime: Bool = false
    @AppStorage("bgColor") var bgColor: String = ""
    @AppStorage("fgColor") var fgColor: String = ""
    @AppStorage("darkMode") var darkMode: Int = 0
    @AppStorage("accentColor") var accentColor: String = "aMint"

    var aColors: [String] = ["aRed","aOrange","aYellow","aGreen","aMint","aCyan","aBlue","aIndigo","aPurple","aPink"]

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
                Section(header: Text("Configure")) {
                    Button {
                        showSync.toggle()
                    } label: {
                        Text("Sync Assignments from external source".lower())
                    }

                }
                .listRowBackground(Color("cLessDarkGray"))
                
                Section(header: Text("General")) {
                    Toggle("Disable Timer".lower(), isOn: $disableTimer)
                        .tint(Color(accentColor))
                    Toggle("Aesthetic Mode".lower(), isOn: $aestheticMode)
                        .tint(Color(accentColor))
                    Toggle("24 Hour Time Time".lower(), isOn: $twofourhourtime)
                        .tint(Color(accentColor))
                    Picker("Accent Color", selection: $accentColor) {
                        ForEach(aColors, id: \.self) { color in
                            HStack {
                                Text(color.dropFirst(1))
                                Circle()
                                    .frame(width:15)
                                    .foregroundColor(Color(color))
                            }
                            .tag(color)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    Picker("Dark Mode", selection: $darkMode) {
                        HStack {
                            Text("Light")
                            Image(systemName: "sun.max.fill")
                        }
                        .tag(0)
                        HStack {
                            Text("Dark")
                            Image(systemName: "moon.fill")
                        }
                        .tag(1)
                        Text("System")
                            .tag(2)
                    }
                    .pickerStyle(.navigationLink)
                    Text("Language".lower())
                }
                .listRowBackground(Color("cLessDarkGray"))
                
                Section(header: Text("Help")) {
                    Text("Quick start guide".lower())
                    Text("How to use".lower())
                    Text("FAQ".lower())
                    Button("Delete all assignments".lower()) {
                        deleteAssignments()
                    }
                    .foregroundColor(.red)
                }
                .listRowBackground(Color("cLessDarkGray"))
                
                Section(header: Text("Notifications")) {
                    Text("Configure Notifications".lower())
                    Text("View Notifications".lower())
                }
                .listRowBackground(Color("cLessDarkGray"))
                
                Section(header: Text("ABOUT")) {
                    Text("About Schematica".lower())
                    Text("Other Apps".lower())
                    Text("View socials".lower())
                    Text("View Website".lower())
                    Text("Version: 0.1".lower())
                }
                .listRowBackground(Color("cLessDarkGray"))
                Spacer().frame(height: 25)
                .listRowBackground(Color("cDarkGrayBg"))
            }
            .navigationTitle("Settings".lower())
            .sheet(isPresented: $showSync) {
                ExternalSource(isPresented: $showSync).environment(\.managedObjectContext, persistedContainer.viewContext)
            }
            .scrollContentBackground(.hidden)
            .background(Color("cDarkGrayBg"))
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Settings()
    }
}
