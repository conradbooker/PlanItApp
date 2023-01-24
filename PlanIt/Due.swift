//
//  Due.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct Due: View {
    
    @AppStorage("initialSync") var initialSync: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
    var assignmentSpacing: CGFloat = 5
    
    @State private var currentDate: Date = Date.now
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    let calendar = Calendar.current

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    private func findHeight(_ text: String) -> CGFloat {
        if Double(text.count) / 40 < 1.2 {
            return 135
        }
        return CGFloat((text.count / 40) * 17 + 140)
    }

    @State var checkInProgress: Int = 0
    @State var checkToDo: Int = 0
    @State var checkFinished: Int = 0
    
    @State var assignmentSize =  CGSize()
    
    // MARK: getColor
    private func getColor(_ title: String) -> Color {
        for course in allCourses {
            let colored = Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))
            if title.lowercased() == course.title?.lowercased() {
                return colored
            }
        }
        return .green
    }
    
    // MARK: syncAssignments
    private func syncAssignments() {
        var allCoursesDict: [String: String] = [:]
        
        for course in allCourses {
            allCoursesDict[course.onlineTitle!] = course.title!
        }
        let things: [ICSCal] = returnString().decodeJson([ICSCal].self)
        let onlineAssignments = things[0].VCALENDAR[0].VEVENT
        
        /// assignment IDs
        var existingAssignmentIDs: [String] = []
        for assignment in allAssignments {
            existingAssignmentIDs.append(assignment.assignmentID!)
        }
        
        print(existingAssignmentIDs)
        
        if existingAssignmentIDs.contains("Personal Reflection20220912") {
            print("cupcakke")
        } else {
            print("Squidward")
        }
        
        /// main function crap
        for assign in onlineAssignments {
            if existingAssignmentIDs.contains(String(assign.id)) == false {
                print("ID:")
                print(String(assign.id))
                let dateFormatter = DateFormatter()
                let currentCourse = allCoursesDict[assign.course] ?? ""
                dateFormatter.dateFormat = "YYYYMMdd"
                
                let assignment = Assignment(context: viewContext)
                assignment.activeHours = 0
                assignment.activeMinutes = 0
                assignment.activeSeconds = 0
                assignment.dubiousMinutes = 0
                assignment.minuteStop = 0
                assignment.hourStop = 0
                assignment.totalHours = 0
                assignment.totalMinutes = 0
                assignment.totalSeconds = 0
                
                assignment.red = Float(getColor(currentCourse).components.red)
                assignment.green = Float(getColor(currentCourse).components.green)
                assignment.blue = Float(getColor(currentCourse).components.blue)
                assignment.opacity = 0.0
                        
                assignment.assignmentType = "Homework"
                assignment.course = currentCourse
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
                assignment.assignmentID = assign.title + assign.DTEND.dropFirst(11)

                print(assignment.assignmentID!)
                assignment.isFinished = false
                
                assignment.parentCourse = ""
                assignment.isChild = false
                assignment.isParent = false
                            
                assignment.parentID = ""
                assignment.parentAssignmentTitle = ""
                assignment.isPaused = true

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
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    Color("cDarkGray")
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            if checkInProgress == 0 && checkToDo == 0 && checkFinished != 0 {
                                HStack {
                                    Text("you finished everything for today!!!")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            // MARK: In Progress
                            if checkInProgress != 0 {
                                HStack {
                                    Text("in progress")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            ForEach(allAssignments) { assign in
                                if assign.dueDate!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "In Progress" {
                                        AssignmentViewNew(assignment: assign)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkInProgress += 1
                                            }
                                            .onDisappear {
                                                checkInProgress -= 1
                                            }
                                    }
                                }
                            }
                            
                            // MARK: To Do
                            if checkToDo != 0 {
                                HStack {
                                    Text("to do")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            ForEach(allAssignments) { assign in
                                if assign.dueDate!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "To Do" {
                                        AssignmentViewNew(assignment: assign)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkToDo += 1
                                            }
                                            .onDisappear {
                                                checkToDo -= 1
                                            }
                                    }
                                }
                            }
                            
                            // MARK: Completed
                            if checkFinished != 0 {
                                HStack {
                                    Text("completed things!")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            
                            ForEach(allAssignments) { assign in
                                if assign.dueDate!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                    if assign.status == "Finished!" {
                                        AssignmentViewNew(assignment: assign)
                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                            .onAppear {
                                                checkFinished += 1
                                            }
                                            .onDisappear {
                                                checkFinished -= 1
                                            }
                                    }
                                }
                            }
                            if checkFinished == 0 && checkToDo == 0 && checkInProgress == 0 {
                                HStack {
                                    Text("Nothing due tomorrow :)")
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
                            Spacer().frame(height: 100)
                        }
                    }
                    VStack {
                        Spacer().frame(height:geometry.size.height-150)
                        DateSelector(selectedDate: $selectedDate)
                    }
                }
                .navigationTitle("Due")
                .refreshable {
                    if initialSync {
                        syncAssignments()
                    } else {
                        print("not initial synced yet!")
                    }
                }
            }
        }
    }
    
    func add() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
    }
    func subtract() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
}


struct Due_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Due().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
