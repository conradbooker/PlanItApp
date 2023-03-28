//
//  Step3.swift
//  PlanIt
//
//  Created by Conrad on 3/5/23.
//

import SwiftUI

struct Step3: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>

    var courses: [courseMatch]
    @AppStorage("initialSync") var initialSync: Bool = false
    
    @Binding var state: String
    @Binding var isPresented: Bool
    
    @State var showAlert: Bool = true

    private func getColor(_ title: String) -> Color {
        for course in allCourses {
            let colored = Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))
            if title.lowercased() == course.title?.lowercased() {
                return colored
            }
        }
        return .green
    }
    
    private func syncAssignments(_ courses: [courseMatch]) {
        var allCoursesDict: [String: String] = [:]
        
        for course in courses {
            allCoursesDict[course.onlineCourse] = course.userCourse
        }
        let things: [ICSCal] = returnString().decodeJson([ICSCal].self)
        let onlineAssignments = things[0].VCALENDAR[0].VEVENT
        
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
        
        for matchCourse in courses {
            for course in allCourses {
                if course.title == matchCourse.userCourse {
                    course.onlineTitle = matchCourse.onlineCourse
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
        
    }

    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("Check if these classes are right!".lower())
                        .padding()
                    Spacer()
                }
                ForEach(courses) { course in
                    HStack {
                        Text("\(course.onlineCourse): \(course.userCourse)")
                            .padding()
                        Spacer()
                    }
                }
                HStack {
                    Button {
                        state = "Step2"
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "arrow.left")
                            Text("  Previous Step".lower())
                        }
                        .padding(2)
                    }
                    .buttonStyle(TimerButton(color: Color("timerDone")))
                    .padding()
                    Spacer()
                    Button(" Sync Assignments! ".lower()) {
                        syncAssignments(courses)
                        showAlert = true
                        isPresented = false
                    }
                    .alert("Success!", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {
                        }
                    }
                    .buttonStyle(TimerButton(color: Color("timerStart")))
                    .padding()
                }
            }
            .navigationTitle("Step 3/3".lower())
        }
    }
}

struct Step3_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        Step3(courses: findCourses(), state: .constant("Step2"), isPresented: .constant(true)).environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
