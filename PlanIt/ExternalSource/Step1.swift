//
//  Step1.swift
//  PlanIt
//
//  Created by Conrad on 3/4/23.
//

import SwiftUI
import AVKit

struct Step1: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer

    @AppStorage("sourceURL") var sourceURL: String = ""
    @AppStorage("initialSync") var initialSync: Bool = false
    var myschoolappSource: Bool {
        if sourceURL.contains("myschoolapp") {
            return true
        }
        return false
    }
    @State private var showingAlert: Bool = false
    @State private var isEmpty: Bool = false
    
    @State private var vidOption: Int = 0

    @Binding var state: String
    @Binding var courses: [courseMatch]
    @Binding var isPresented: Bool
    
    @State var myschoolapp = AVPlayer(url:  URL(string: "https://github.com/conradbooker/PlanItApp/blob/b2163a81e8058798defc4e223c818c183ae10fc8/PlanIt/myschoolapp.mov?raw=true")!)
    @State var schoology = AVPlayer(url:  URL(string: "https://github.com/conradbooker/PlanItApp/blob/main/PlanIt/schoology.mov?raw=true")!)

    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    @AppStorage("accentColor") var accentColor: String = "aMint"

    
    private func syncAssignments() {
        let things: [ICSCal] = returnString().decodeJson([ICSCal].self)
        let onlineAssignments = things[0].VCALENDAR[0].VEVENT
        if things.count < 2 {
            isEmpty = true
            sourceURL = ""
            return
        }
        
        /// assignment IDs
        var existingAssignmentIDs: [String] = []
        for assignment in allAssignments {
            existingAssignmentIDs.append(assignment.assignmentID!)
        }
        
        print(existingAssignmentIDs)
        
        /// main function crap
        for assign in onlineAssignments {
            if existingAssignmentIDs.contains(String(assign.id)) == false {
                print("ID:")
                print(String(assign.id))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYMMdd"
                
                let assignment = Assignment(context: viewContext)
                assignment.activeSeconds = 0
                assignment.dubiousSeconds = 0
                assignment.secondStop = 0
                assignment.totalSeconds = 0
                
                assignment.red = Float(0.2235)
                assignment.green = Float(0.5)
                assignment.blue = Float(0.7686)
                assignment.opacity = 0.0
                        
                assignment.assignmentType = "Homework"
                assignment.course = "Click to Assign Course"
                assignment.source = "fromOnline"
                assignment.summary = assign.description
                assignment.title = assign.title
                
                assignment.dateCreated = Date()
                assignment.dateFinished = Date()
                
                if assign.dueDate < Date() {
                    assignment.status = "Finished!"
                } else {
                    assignment.status = "To Do"
                }
                
                assignment.datePlanned = Calendar.current.date(byAdding: .day, value: -1000, to: assign.dueDate)
                assignment.isPlanned = false
                assignment.dueDate = assign.dueDate
                
                assignment.courseID = UUID()
                assignment.id = UUID()
                assignment.assignmentID = assign.title + "." + assign.DTEND.dropFirst(11)

                print(assignment.assignmentID!)
                assignment.isFinished = false
                
                assignment.parentCourse = ""
                assignment.isChild = false
                assignment.isParent = false
                            
                assignment.parentID = ""
                assignment.parentAssignmentTitle = ""
                assignment.isPaused = true
                
                assignment.specificHour = 0
                assignment.specificMinute = 0

                print("found new assignment!")
                print(assignment.title ?? "")
                
                initialSync = true

                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                    print("Error occured in saving! (parent)")
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }


    var body: some View {
        NavigationView {
            ScrollView {
                Picker("", selection: $vidOption) {
                    Text("myschoolapp")
                        .tag(0)
                    Text("schoology")
                        .tag(1)
                }.pickerStyle(.segmented)
                
                if vidOption == 0 {
                    VideoPlayer(player: myschoolapp)
                        .frame( /*width: 180,*/ height: 400)
                        .onAppear() {
                            myschoolapp.play()
                        }
                        .onDisappear() {
                            myschoolapp.pause()
                        }
                    Text("Go to Calendar -> Options -> WebCal Feed -> \"individual filter feeds\" -> Assignments -> Copy WebCal link from Calendar\n").padding()
                }
                else {
                    VideoPlayer(player: schoology)
                        .frame(height: 400)
                        .onAppear() {
                            myschoolapp.play()
                        }
                        .onDisappear() {
                            myschoolapp.pause()
                        }
                    Text("Click on profile -> Settings -> and under Share Your Schoology Calendar copy the iCal link\n").padding()
                }

                TextField("Link".lower(), text: $sourceURL)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal,12)
                PasteButton(payloadType: String.self) { strings in
                    guard let first = strings.first else { return }
                    sourceURL = first
                }
                .buttonStyle(TimerButton(color: Color("timerStart")))
                Spacer().frame(height: 20)
                HStack {
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                if allCourses.count < 1 {
                                    showingAlert = true
                                } else {
                                    if sourceURL.contains("https://") && !sourceURL.contains("webcal://") {
                                        state = "Step2"
                                        
                                    } else if sourceURL.contains("webcal://") {
                                        sourceURL = sourceURL.replacingOccurrences(of: "webcal://", with: "https://")
                                        state = "Step2"
                                    } else {
                                        sourceURL = "https://" + sourceURL
                                        state = "Step2"
                                    }
                                    courses = findCourses()
                                }
                            } label: {
                                HStack(spacing: 0) {
                                    Text("myschoolapp  ".lower())
                                    Image(systemName: "arrow.right")
                                }
                                .padding(2)
                            }
                            .opacity(myschoolappSource ? 1 : 0.5)
                            .buttonStyle(TimerButton(color: Color("timerStart")))
                            .padding(.horizontal)
                            .disabled(!myschoolappSource)
                            .alert("You have no classes! Please go to \"New\" to add classes.", isPresented: $showingAlert) {
                                Button("OK", role: .cancel) {
                                    isPresented = false
                                }
                            }
                        }
                        HStack {
                            Spacer()
                            Button {
                                if sourceURL.contains("https://") && !sourceURL.contains("webcal://") {
                                    syncAssignments()
                                } else if sourceURL.contains("webcal://") {
                                    sourceURL = sourceURL.replacingOccurrences(of: "webcal://", with: "")
                                    sourceURL = "https://" + sourceURL
                                    syncAssignments()
                                } else {
                                    sourceURL = "https://" + sourceURL
                                    syncAssignments()
                                }
                            } label: {
                                HStack(spacing: 0) {
                                    Text("Schoology   ".lower())
                                    Image(systemName: "arrow.right")
                                }
                                .padding(2)
                            }
                            .opacity(myschoolappSource ? 0.5 : 1)
                            .disabled(myschoolappSource)
                            .buttonStyle(TimerButton(color: Color("timerDone")))
                            .padding()
                            .alert("Error", isPresented: $isEmpty) {
                                  
                                } message: {
                                  Text("Unfortunatly your school's schoology calendar is not supported for the time being. Full schoology support will be implented soon.")
                            }

                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Sync Step 1/3".lower())
        }
    }
}

struct Step1_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Step1(state: .constant("Step1"), courses: .constant(findCourses()), isPresented: .constant(true)).environment(\.managedObjectContext, persistedContainer.viewContext)
        
    }
}
