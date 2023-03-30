//
//  Settings.swift
//  PlanIt
//
//  Created by Conrad on 12/23/22.
//

import SwiftUI
import MessageUI

extension String {
    func lower() -> String {
        @AppStorage("aestheticMode") var aestheticMode: Bool = false
        if aestheticMode {
            return self.lowercased()
        }
        return self
    }
}
var aColors: [String] = ["aRed","aOrange","aYellow","aGreen","aMint","aCyan","aBlue","aIndigo","aPurple","aPink"]

struct Settings: View {
    
    @ObservedObject var monitor = Network()
        
    @State private var link: String = ""
    @State private var showSync: Bool = false
    @State private var showQuickStart: Bool = false
    @State private var about: Bool = false

    @State private var showAlertOnline: Bool = false
    @State private var showNetworkAlert: Bool = false
    @State private var showAlertNotOnline: Bool = false
    @State private var isShowingMailView: Bool = false
    @State private var alertNoMail: Bool = false

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
    @AppStorage("name") var name: String = "new user"

    @FocusState var inputIsActive: Bool

    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    private let pastboard = UIPasteboard.general
    
    private func deleteOnline() {
        for assignment in allAssignments {
            if assignment.source == "fromOnline" {
                viewContext.delete(assignment)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteSelf() {
        for assignment in allAssignments {
            if assignment.source == "fromSelf" {
                viewContext.delete(assignment)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            VStack {
                                HStack {
                                    Button {
                                        if monitor.isConnected {
                                            showSync.toggle()
                                        } else {
                                            showNetworkAlert = true
                                        }
                                    } label: {
                                        Text("Sync Assignments from external source".lower())
                                    }
                                    .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding([.top, .leading, .trailing])
                        .alert("No Internet Connection".lower(), isPresented: $showNetworkAlert, actions: {
                            Button("OK".lower(), role: .cancel) { }
                        }, message: {
                            Text("An internet connection is required to sync PlanIt with myschoolapp or Schoology.".lower())
                        })


                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Name:")
                                    .padding()
                                TextField("Name", text: $name)
                                    .background(Color("cLessDarkGray"))
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                    .focused($inputIsActive)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("done") {
                                                inputIsActive = false
                                            }
                                        }
                                    }
                                
                                Toggle("Show Assignment Timers".lower(), isOn: $disableTimer)
                                    .tint(Color(accentColor))
                                    .padding([.top, .leading, .trailing])
                                
                                Toggle("Aesthetic Mode".lower(), isOn: $aestheticMode)
                                    .tint(Color(accentColor))
                                    .padding([.top, .leading, .trailing])
                                
                                Text("Accent Color:".lower())
                                    .padding([.top, .leading, .trailing])
                                HStack(spacing: 7.5) {
                                    ForEach(aColors, id: \.self) { color in
                                        Button {
                                            withAnimation(.linear(duration: 1)) {
                                                accentColor = color
                                            }
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(Color(color))
                                                    .shadow(radius: 2)
                                                if accentColor == color {
                                                    withAnimation(.linear(duration: 1)) {
                                                        Circle()
                                                            .frame(width: 10, height: 10)
                                                            .foregroundColor(.black)
                                                    }
                                                }
                                            }
                                        }
                                        .buttonStyle(upDown())
                                    }
                                }
                                .padding([.top, .leading, .trailing])
                                
                                Text("Color Scheme:".lower())
                                    .padding([.top, .leading, .trailing])
                                HStack {
                                    VStack {
                                        Button {
                                            withAnimation(.linear(duration: 0.1)) {
                                                darkMode = 0
                                            }
                                        } label: {
                                            HStack {
                                                Text("Light".lower())
                                                    .foregroundColor(.black)
                                                Image(systemName: "sun.max.fill")
                                                    .foregroundColor(.black)
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .buttonStyle(ToggleButton(color: .white))
                                        if darkMode == 0 {
                                            RoundedRectangle(cornerRadius: 100)
                                                .frame(width: 40, height: 5)
                                                .foregroundColor(Color(accentColor))
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color("cLessDarkGray"))
                                        }
                                    }
                                    
                                    VStack {
                                        Button {
                                            withAnimation(.linear(duration: 0.1)) {
                                                darkMode = 1
                                            }
                                        } label: {
                                            HStack {
                                                Text("Dark".lower())
                                                    .foregroundColor(.white)
                                                Image(systemName: "moon.fill")
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .buttonStyle(ToggleButton(color: .black))
                                        if darkMode == 1 {
                                            RoundedRectangle(cornerRadius: 100)
                                                .frame(width: 40, height: 5)
                                                .foregroundColor(Color(accentColor))
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color("cLessDarkGray"))
                                        }
                                    }
                                    
                                    VStack {
                                        Button {
                                            withAnimation(.linear(duration: 0.1)) {
                                                darkMode = 2
                                            }
                                        } label: {
                                            HStack {
                                                Text("System".lower())
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.vertical, 2)
                                        }
                                        .buttonStyle(ToggleButton(color: .gray))
                                        if darkMode == 2 {
                                            RoundedRectangle(cornerRadius: 100)
                                                .frame(width: 40, height: 5)
                                                .foregroundColor(Color(accentColor))
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 3)
                                                .foregroundColor(Color("cLessDarkGray"))
                                        }
                                    }
                                }
                                .padding([.top, .leading, .trailing])
                                
                                Spacer()
                                    .frame(height:15)
                            }
                        }
                        .padding([.top, .leading, .trailing])
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            VStack {
                                HStack {
                                    Button {
                                        showQuickStart = true
                                    } label: {
                                        Text("Quick Start".lower())
                                    }
                                        .padding([.top, .leading, .trailing])
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    Text("Delete assignments from: ".lower())
                                    Button {
                                        showAlertOnline = true
                                    } label: {
                                        Text("    online".lower())
                                            .foregroundColor(.red)
                                    }
                                    Button {
                                        showAlertNotOnline = true
                                    } label: {
                                        Text("     self".lower())
                                            .foregroundColor(.red)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .alert("Are you sure? This is not irreversable.?".lower(), isPresented: $showAlertOnline) {
                                    Button("OK".lower()) { deleteOnline() }
                                    Button("Cancel".lower(), role: .cancel) { }
                                }
                                .alert("Are you sure? This is not irreversable.".lower(), isPresented: $showAlertNotOnline) {
                                    Button("OK".lower()) { deleteSelf() }
                                    Button("Cancel".lower(), role: .cancel) { }
                                }

                            }
                        }
                        .padding([.top, .leading, .trailing])
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            VStack {
                                HStack {
                                    Text("Configure Notifications: Coming soon".lower())
                                        .padding([.top, .leading, .trailing])
                                    Spacer()
                                }
                                HStack {
                                    Text("Notification Frequency: Coming soon".lower())
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding([.top, .leading, .trailing])
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            VStack {
                                HStack {
                                    Button {
                                        about = true
                                    } label: {
                                        Text("About".lower())
                                        .padding([.top, .leading, .trailing])
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Button {
                                        if MFMailComposeViewController.canSendMail() {
                                            isShowingMailView = true
                                        } else {
                                            alertNoMail = true
                                        }
                                    } label: {
                                        HStack {
                                            Text("Send Feedback".lower())
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                    }
                                    .alert("No Email Set Up".lower(), isPresented: $alertNoMail, actions: {
                                        Button("Cancel".lower(), role: .cancel) { }
                                        Button {
                                            pastboard.string = "planithomeworkapp@gmail.com"
                                        } label: {
                                            Label("Copy Email", systemImage: "doc.on.doc")
                                        }
                                    }, message: {
                                        Text("You do not have an email set up. Go to settings, or send the email to \"planithomeworkapp@gmail.com\".")
                                    })
                                    .padding([.top, .leading, .trailing])
                                    Spacer()
                                }
                                HStack {
                                    Text("Version: \(PlanItVersionStr)".lower())
                                    Spacer()
                                }
                                .padding([.top, .leading, .trailing])
                                HStack {
                                    Text("Made with ❤️ in NYC 🗽".lower())
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding([.top, .leading, .trailing])
                        Spacer().frame(height: 120)
                    }
                }
                .navigationTitle("Settings".lower())
                
                .sheet(isPresented: $showSync) {
                    ExternalSource(isPresented: $showSync).environment(\.managedObjectContext, persistedContainer.viewContext)
                }
                .sheet(isPresented: $showQuickStart) {
                    OnboardingView(done: $showQuickStart)
                }
                .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$result)
                }
                .sheet(isPresented: $about) {
                    NavigationView {
                        VStack(alignment: .leading) {
                            ScrollView {
                                Text("Hey! I am a 17 year old high school student from NYC. I created this app out of a frustration of my lack of time management. With PlanIt, you can not only plan out your homework, but stay on top of all of your assignments.")
                            }
                        }
                        .navigationTitle("About")
                    }
                }
            }
        }
    }
}

//Section(header: Text("Help")) {
//    Text("FAQ".lower())
//    Button("Delete all assignments".lower()) {
//        deleteAssignments()
//    }
//    .foregroundColor(.red)
//}
//.listRowBackground(Color("cLessDarkGray"))
//
//Section(header: Text("Notifications")) {
//    Text("Configure Notifications".lower())
//    Text("View Notifications".lower())
//}
//.listRowBackground(Color("cLessDarkGray"))

//Section(header: Text("ABOUT")) {
//    Text("About Schematica".lower())
//    Text("Other Apps".lower())
//    Text("View socials".lower())
//    Text("View Website".lower())
//    Text("Version: 0.1".lower())
//}


struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Settings()
    }
}
