//
//  Settings.swift
//  PlanIt
//
//  Created by Conrad on 12/23/22.
//

import SwiftUI

struct Settings: View {
    @State private var link: String = ""
    @State private var showSync: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Button(action: {
                    showSync.toggle()
                }, label: {
                    Text("Sync Assignments from myschoolapp, or schology")
                })
                
                Section(header: Text("General")) {
                    Text("Import Homework from external source")
                    Text("Profile")
                    Text("Color Theme")
                    Text("Dark Mode")
                    Text("Language")
                    Text("Key")
                }
                Section(header: Text("Help")) {
                    Text("Quick start guide")
                    Text("How to use")
                    Text("FAQ")
                }
                Section(header: Text("Notifications")) {
                    Text("Configure Notifications")
                    Text("View Notifications")
                }
                Section(header: Text("ABOUT")) {
                    Text("About Schematica")
                    Text("Other Apps")
                    Text("View socials")
                    Text("View Website")
                    Text("Version: 0.1")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showSync) {
                ExternalSource()
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
