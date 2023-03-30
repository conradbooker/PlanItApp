//
//  Home.swift
//  PlanIt
//
//  Created by Conrad on 12/23/22.
//

import SwiftUI

struct Home: View {
    
    // Future: change fetch request so that it is not in 1million if statements!!
    
    @ObservedObject var monitor = Network()
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @State private var showNetworkAlert: Bool = false
        
    @AppStorage("initialSync") var initialSync: Bool = false
    
    var assignmentSpacing: CGFloat = 5
    
    @State private var currentDate: Date = Date.now
    var selectedDate: Date
    let calendar = Calendar.current

    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    @State var checkInProgress: Int = 0
    @State var checkToDo: Int = 0
    @State var checkFinished: Int = 0
    @State var checkUnplanned: Int = 0
    @State var checkAssessments: Int = 0

    @State private var totalSeconds: Int = 0
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "course", ascending: true)]) private var allAssignments: FetchedResults<Assignment>
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
    var title: String {
        if selectedDate.formatted(.dateTime.day().month().year()) == currentDate.formatted(.dateTime.day().month().year()) {
            return "To Do Today"
        }
        let weekdayIndex = Calendar.current.component(.weekday, from: selectedDate) - 1
        let weekday = DateFormatter().shortWeekdaySymbols[weekdayIndex]
        return "To Do \(weekday), \(String(selectedDate.formatted(date: .abbreviated, time: .omitted)).dropLast(6))"
    }
    
    private func getColor(_ title: String) -> Color {
        for course in allCourses {
            let colored = Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))
            if title.lowercased() == course.title?.lowercased() {
                return colored
            }
        }
        return .green
    }
    
    private func syncAssignments() {
        var allCoursesDict: [String: String] = [:]
        
        for course in allCourses {
            allCoursesDict[course.onlineTitle!] = course.title!
        }
        let things: [ICSCal] = returnString().decodeJson([ICSCal].self)
        let onlineAssignments = things[0].VCALENDAR[0].VEVENT
        
        var onlineAssignmentIDs: [String] = []
        for assignment in onlineAssignments {
            onlineAssignmentIDs.append(assignment.id)
        }
        
        /// assignment IDs
        var existingAssignmentIDs: [String] = []
        for assignment in allAssignments {
            existingAssignmentIDs.append(assignment.assignmentID!)
            
            /// if existing assignment is not in online assignments (if the teacher has moved an assignment)
            if !(onlineAssignmentIDs.contains(assignment.assignmentID!)) && assignment.source == "fromOnline" {
                
                viewContext.delete(assignment)
                /// in the future this should be a soft delete not a hard delete (go into recently deleted)
                /// would require delete, and delete date for assignments older than 30 days or something
                
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        print(existingAssignmentIDs)
                
        /// main function crap
        for assign in onlineAssignments {
            if existingAssignmentIDs.contains(String(assign.id)) == false {
                print("ID:")
                print(String(assign.id))
                let dateFormatter = DateFormatter()
                let currentCourse = allCoursesDict[assign.course] ?? ""
                dateFormatter.dateFormat = "YYYYMMdd"
                
                let assignment = Assignment(context: viewContext)
                assignment.activeSeconds = 0
                assignment.dubiousSeconds = 0
                assignment.secondStop = 0
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
                
                assignment.datePlanned = Calendar.current.date(byAdding: .day, value: -1, to: assign.dueDate)
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
    
    var majors: String {
        if checkAssessments == 1 {
            return "1 Major Assignment Tomorrow"
        } else {
            return String("\(checkAssessments) Major Assignments Tomorrow")
        }
    }

//    In the Future, days that the school day ends, add weekends, and allow user to configure breaks, also allow users to configure which days do not have
//      also add "main thing" where the user can input something like "NO SCHOOL" or "WEEKEND" or something like that
// and change it to be you have 5 tasks to today, 2 assessments to study for, and 4 assignments, in these classes you have nothing planned
// also add field: school, work, home, sport, etc.

    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        Group {
                        if checkInProgress == 0 && checkToDo == 0 && checkFinished != 0 {
                            HStack {
                                Text("You Finished Everything for Today!!!".lower())
                                    .padding([.top, .leading])
                                Spacer()
                            }
                        }
                            
                            // MARK: Assessments
                            
                        if checkAssessments != 0 {
                            HStack {
                                Text(majors.lower())
                                    .padding([.top, .leading])
                                Spacer()
                            }
                        }
                        
//                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
                        ForEach(allAssignments) { assign in
                            if Calendar.current.date(byAdding: .day, value: -1, to: assign.datePlanned!)!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                if assign.isPlanned == true && assign.assignmentType != "Homework" && assign.assignmentType != "Studying" {
                                    AssignmentRow(assignment: assign)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .onAppear {
                                            checkAssessments += 1
                                            if !assign.isFinished {
                                                totalSeconds += Int(assign.secondStop)
                                            }
                                        }
                                        .onDisappear {
                                            checkAssessments -= 1
                                            if !assign.isFinished {
                                                totalSeconds -= Int(assign.secondStop)
                                                
                                            }
                                        }
                                }
                            }
                        }
                        

                        } /// end of group
                        
                        // MARK: Unplanned assignments
                    Group {
                        if checkUnplanned != 0 {
                            HStack {
                                Text("\(checkUnplanned) unplanned assignments to do this day".lower())
                                    .padding([.top, .leading])
                                Spacer()
                            }
                        }
                        
                        ForEach(allAssignments) { assign in
                            if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                if assign.isPlanned == false {
                                    PlannerRow(assignment: assign)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .onAppear {
                                            checkUnplanned += 1
                                            if !assign.isFinished {
                                                totalSeconds += Int(assign.secondStop)
                                            }
                                        }
                                        .onDisappear {
                                            checkUnplanned -= 1
                                            if !assign.isFinished {
                                                totalSeconds -= Int(assign.secondStop)
                                                
                                            }
                                        }
                                }
                            }
                        }
                    }
                        
                        // MARK: In Progress
                        if checkInProgress != 0 {
                            HStack {
                                Text("In Progress".lower())
                                    .padding([.top, .leading])
                                Spacer()
                            }
                        }
                        ForEach(allAssignments) { assign in
                            if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                if assign.status == "In Progress" && assign.isPlanned && assign.assignmentType == "Homework" {
                                    AssignmentViewNew(assignment: assign)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .onAppear {
                                            checkInProgress += 1
                                            if !assign.isFinished {
                                                totalSeconds += Int(assign.secondStop)
                                            }
                                        }
                                        .onDisappear {
                                            checkInProgress -= 1
                                            if !assign.isFinished {
                                                totalSeconds -= Int(assign.secondStop)
                                            
                                            }
                                        }
                                }
                            }
                        }
                        
                        // MARK: To Do
                        if checkToDo != 0 {
                            HStack {
                                Text("To Do".lower())
                                    .padding([.top, .leading])
                                Spacer()
                            }
                        }
                        
                        ForEach(allAssignments) { assign in
                            if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                if assign.status == "To Do" && assign.isPlanned && assign.assignmentType == "Homework" {
                                    AssignmentViewNew(assignment: assign)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .onAppear {
                                            checkToDo += 1
                                            if !assign.isFinished {
                                                totalSeconds += Int(assign.secondStop)
                                            }
                                        }
                                        .onDisappear {
                                            checkToDo -= 1
                                            if !assign.isFinished {
                                                totalSeconds -= Int(assign.secondStop)
                                            }
                                        }
                                }
                            }
                        }
                        
                        // MARK: Completed
                        if checkFinished != 0 {
                            HStack {
                                Text("Completed Things!".lower())
                                    .padding([.top, .leading])
                                Spacer()
                            }
                        }
                        
                        ForEach(allAssignments) { assign in
                            if assign.datePlanned!.formatted(.dateTime.day().month().year()) == selectedDate.formatted(.dateTime.day().month().year()) {
                                if assign.status == "Finished!" && assign.isPlanned && assign.assignmentType == "Homework" {
                                    AssignmentViewNew(assignment: assign)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .onAppear {
                                            checkFinished += 1
                                            if !assign.isFinished {
                                                totalSeconds += Int(assign.secondStop)                                                }
                                        }
                                        .onDisappear {
                                            checkFinished -= 1
                                            if !assign.isFinished {
                                                totalSeconds -= Int(assign.secondStop)
                                            }
                                        }
                                }
                            }
                        }
                        Group {
                            if checkFinished == 0 && checkToDo == 0 && checkInProgress == 0 && checkUnplanned == 0{
                                HStack {
                                    Text("No assignments! Swipe down to sync or create new assignment.".lower())
                                        .padding([.top, .leading])
                                    Spacer()
                                }
                            }
//                                FormattedTime(secondStop: totalSeconds)
                        }
                        Spacer().frame(height: 100)
                    }
                    Spacer().frame(height: 100)
                }/// end of scrollview
            }
            .navigationTitle(title.lower())
            .refreshable {
                if monitor.isConnected {
                    if initialSync {
                        syncAssignments()
                    }
                } else {
                    showNetworkAlert = true
                }
            }
            .alert("No Internet Connection".lower(), isPresented: $showNetworkAlert, actions: {
                Button("OK".lower(), role: .cancel) { }
            }, message: {
                Text("An internet connection is required to sync PlanIt with myschoolapp or Schoology.".lower())
            })
        }
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Home(selectedDate: Date()).environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}


