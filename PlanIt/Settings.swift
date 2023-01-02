//
//  Settings.swift
//  PlanIt
//
//  Created by Conrad on 12/23/22.
//

import SwiftUI

struct Settings: View {
    @State private var link: String = ""
    @State private var circle: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Link from external source")) {
                    TextField("Link", text: $link)
                        .onSubmit {
                            circle.toggle()
                        }
                }
                if circle {
                    Circle().frame(width: 20)
                }
                Section(header: Text("About You!")) {
                    Text("Name")
                    Text("Year")
                    Text("School Start Time")
                    Text("School Start")
                    Text("School End")
                }
                Section(header: Text("General")) {
                    Text("Import Homework from external source")
                    Text("Color Theme")
                    Text("Dark Mode")
                    Text("Language")
                    Text("Key")
                }

                Section(header: Text("Notifications")) {
                    Text("Configure Notifications")
                    Text("View Notifications")
                }
                Section(header: Text("ABOUT")) {
                    Text("About Schematica")
                    Text("Other Apps")
                    Text("Info")
                    Text("View Website")
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("0.1")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
