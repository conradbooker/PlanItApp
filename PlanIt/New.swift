//
//  New.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, o)
    }
}

struct New: View {
    
    /// Dynamic variables
    @State private var newType: String = "Assignment"
    @State private var title: String = ""
    @State private var summary: String = ""
    @State private var assignmentType: String = "Assessment"
    @State private var course: String = ""
    @State private var dueDate: Date = Date()
    @State private var planned: Date = Date()
    @State private var color: Color = .red
    @State var hourStop: String = "0"
    @State var minuteStop: String = "45"
    
    @State private var isParent: Bool = false
    
    @State private var tapped: Bool = false
    
    var asd: [String] = []
    
    @State private var assessmentType: String = "Quiz"
    @State private var childAssignments: [childAssignment] = []
    
    /// Static vars
    let assignmentTypes = ["Homework", "Project", "Assessment", "Paper"]
    let types = ["Assignment","Course"]
    let assessmentTypes = ["Quiz","Quest","Test"]

    
    /// Alerts
    @State var showAlert: Bool = false
    @State var showAlertDupe: Bool = false
    @State var showCourseEmptyAlert: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
//    let firstCourse = allCourses[0]
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    private func tapCourse() -> String {
        if !tapped {
            let firstCourse = allCourses[0]
            return firstCourse.title ?? "Error lol"
        }
        return course
    }

        
    private func saveAssignment() {
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        
        var courseTitle = ""
        if !allCourses.isEmpty {
            courseTitle = tapCourse()
        }

        let assignment = Assignment(context: viewContext)
        assignment.activeHours = 0
        assignment.activeMinutes = 0
        assignment.activeSeconds = 0
        assignment.dubiousMinutes = 0
        assignment.minuteStop = Int16(minuteStop) ?? 0
        assignment.hourStop = Int16(hourStop) ?? 0
        assignment.totalHours = 0
        assignment.totalMinutes = 0
        assignment.totalSeconds = 0
        
        assignment.red = Float(getColor(courseTitle).components.red)
        assignment.green = Float(getColor(courseTitle).components.green)
        assignment.blue = Float(getColor(courseTitle).components.blue)
        assignment.opacity = 0.0
                
        assignment.assignmentType = assignmentType
        assignment.course = courseTitle
        assignment.source = "fromSelf"
        assignment.status = "To Do"
        assignment.summary = summary
        assignment.title = title
                    
        assignment.dateCreated = Date()
        assignment.dateFinished = Date()
        assignment.datePlanned = planned
        assignment.isPlanned = false
        assignment.dueDate = dueDate
        
        assignment.courseID = UUID()
        assignment.id = UUID()
        assignment.assignmentID = title + dateFormatter.string(from: dueDate)

        assignment.isFinished = false
        
        assignment.parentCourse = ""
        assignment.isChild = false
        assignment.isParent = isParent
        
        if assignmentType != "Homework" {
            assignment.isParent = true
            assignment.datePlanned = dueDate
            assignment.isPlanned = true
        }
        
        assignment.parentID = ""
        assignment.parentAssignmentTitle = ""
        assignment.isPaused = true

        do {
//            assignment.isPlanned = false
//            assignment.datePlanned = Date()
            
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error occured in saving! (parent)")
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if !childAssignments.isEmpty {
            for assign in childAssignments {
                
                var courseTitle = ""
                if !allCourses.isEmpty {
                    courseTitle = tapCourse()
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYMMdd"
                
                let assignment = Assignment(context: viewContext)
                assignment.activeHours = 0
                assignment.activeMinutes = 0
                assignment.activeSeconds = 0
                assignment.dubiousMinutes = 0
                assignment.minuteStop = Int16(assign.minuteStop) ?? 0
                assignment.hourStop = Int16(assign.hourStop) ?? 0
                assignment.totalHours = 0
                assignment.totalMinutes = 0
                assignment.totalSeconds = 0
                
                assignment.red = Float(getColor(courseTitle).components.red)
                assignment.green = Float(getColor(courseTitle).components.green)
                assignment.blue = Float(getColor(courseTitle).components.blue)
                assignment.opacity = 0.0
                                
                assignment.assignmentType = assign.assignmentType
                assignment.course = courseTitle
                assignment.source = "fromSelf"
                assignment.status = "To Do"
                assignment.summary = summary
                assignment.title = assign.title
                            
                assignment.dateCreated = Date()
                assignment.dateFinished = Date()
                assignment.datePlanned = assign.plannedDate
                assignment.isPlanned = false
                assignment.dueDate = dueDate
                
                assignment.courseID = UUID()
                assignment.id = UUID()
                assignment.assignmentID = assign.title + dateFormatter.string(from: dueDate)

                assignment.isFinished = false
                
                assignment.parentCourse = ""
                assignment.isChild = true
                
                isParent = true
                
                assignment.isParent = false
                assignment.parentID = title + dateFormatter.string(from: dueDate)
                assignment.parentAssignmentTitle = ""
                assignment.isPaused = true
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                    print("Error occured in saving! (child)")
                }
            }
        }

        
    }
    private func saveCourse() {
        
        do {
            let course = Course(context: viewContext)
            
            course.red = Float(color.components.red)
            course.green = Float(color.components.green)
            course.blue = Float(color.components.blue)
            
            course.summary = summary
            course.title = title
            
            course.onlineTitle = ""
            course.section = ""
                        
            course.dateCreated = Date()
                        
            course.year = Int16(2022)
            
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error occured in saving!")
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    
    private func deleteAssignment(at offsets: IndexSet) {
        offsets.forEach { index in
            let assignment = allAssignments[index]
            viewContext.delete(assignment)
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    private func deleteCourse(at offsets: IndexSet) {
        offsets.forEach { index in
            let course = allCourses[index]
            viewContext.delete(course)
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
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

    
    var body: some View {
        NavigationView {
            VStack {
                
                /// Top picker
                Picker("New Type", selection: $newType) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.leading, .bottom, .trailing])
                
                /// If user wants new assignment, eventually add task too
                if newType == "Assignment" {
                    Group {
                        Group {
                            /// Title
                            TextField("Enter title", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            /// Description
                            TextField("Enter description", text: $summary)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            ///Assignment Type
                            Picker("Assignment Type", selection: $assignmentType) {
                                ForEach(assignmentTypes, id: \.self) { assignmentType in
                                    Text(assignmentType).tag(assignmentType)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            if assignmentType == "Assessment" {
                                /// Assessment Type (Quiz, Test, Quest)
                                Picker("AssessmentTypes", selection: $assessmentType) {
                                    ForEach(assessmentTypes, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding([.leading, .bottom, .trailing])
                            }

                            /// Pick which course assignment is to
                            Picker("Classes", selection: $course) {
                                ForEach(allCourses, id: \.self) { course in
                                    Text(course.title ?? "").tag(course.title ?? "")
                                }
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                tapped = true
                            }

                            
                        }
                        Group { /// Date and time

                            /// Due Date
                            Group {
                                if assignmentType != "Assessment" {
                                    DatePicker("Due Date:", selection: $dueDate, in: Date()..., displayedComponents: [.date])
                                        .padding(.horizontal)
                                } else {
                                    DatePicker("\(assessmentType) Date:", selection: $dueDate, in: Date()..., displayedComponents: [.date])
                                        .padding(.horizontal)
                                }
                            }
                            
                            if assignmentType == "Homework" {
                            /// Planned date
                                DatePicker("What day will you do this?", selection: $planned, in: ...dueDate, displayedComponents: [.date])
                                .padding(.horizontal)
                            
                            /// Assignment length
                                HStack(spacing: 0) {
                                    Text("How long will this take?")
                                    NumTextField(subText: "h", text: $hourStop)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                        .frame(width: 80)
                                        .multilineTextAlignment(.center)
                                    if Int(hourStop) ?? 0 == 1 {
                                        Text("hour")
                                    } else {
                                        Text("hours")
                                    }
                                    NumTextField(subText: "m", text: $minuteStop)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                        .frame(width: 80)
                                        .multilineTextAlignment(.center)
                                    if Int(minuteStop) ?? 0 == 1 {
                                        Text("min")
                                    } else {
                                        Text("mins")
                                    }
                                    
                                }
                            } else if assignmentType == "Project" {
                                
                                /// Add days for working on project
                                Text("Which days will you work on the project?")
                            } else if assignmentType == "Assessment" {
                                /// Add days for studying
                                HStack {
                                    Text("Which days will you study for your \(assessmentType.lowercased())?")
                                    Button(action: {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "YYYYMMdd"
                                        @ObservedObject var modeling = childAssignment()
                                        
                                        if assignmentType == "Assessment" {
                                            modeling.title = "Study for " + self.title
                                            modeling.assignmentType = "Studying"
                                        } else {
                                            modeling.title = "Work on " + title
                                            if assignmentType == "Paper" {
                                                modeling.assignmentType = "Writing"
                                            } else {
                                                modeling.assignmentType = "Project"
                                            }
                                        }
                                        
                                        childAssignments.append(modeling)

                                    }, label: {
                                        Image(systemName: "plus.circle.fill")
                                    })
                                }
                                
                                if childAssignments.isEmpty {
                                    Text("(press plus button to add assignments)")
                                        .padding()
                                } else {
                                    ScrollView {
                                        Spacer()
                                        ForEach($childAssignments) { assign in
                                            ChildAssignmentRow(date: assign.plannedDate, hourStop: assign.hourStop, minuteStop: assign.minuteStop, stopDate: dueDate).frame(height: 45)
                                            // pass through the hourstop, minutestop, date
                                        }
                                    }.frame(height: 200)

                                    // TODO: make button to add multistepassignmet to [childAssignments]
                                }
                            }
                        }
                        
                        /// Save button
                        Button(action: {
                            if title == "" || minuteStop == ""  || hourStop == "" {
                                showAlert = true
                            } else {
                                if allCourses.isEmpty {
                                    showCourseEmptyAlert = true
                                } else {
                                    saveAssignment()
                                }
                            }

                        }) {
                            Text("Save")
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("Error"),
                                        message: Text("Please fill all fields!")
                                    )
                                }
                                .alert(isPresented: $showCourseEmptyAlert) {
                                    Alert(
                                        title: Text("Error"),
                                        message: Text("You have no classes! Please click on courses to add a new course.")
                                    )
                                }

                        }
                        List {
                            ForEach(allAssignments) { assignmentY in
                                HStack {
                                    Text(assignmentY.title ?? "")
                                }
                            }.onDelete(perform: deleteAssignment)
                        }
                    }
                    
                } else { /// if user wants a new course
                    Group {
                        TextField("Enter title", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        TextField("Enter description", text: $summary)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        ColorPicker("Pick a color for the course", selection: $color)
                            .padding()
                    
                        Button(action: {
                            if title == "" {
                                showAlert = true
                            } else {
                                for course in allCourses {
                                    if title == course.title {
                                        showAlertDupe = true
                                    }
                                }
                                if showAlertDupe == false {
                                    saveCourse()
                                }
                            }
                        }) {
                            Text("Save")
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("Error"),
                                        message: Text("Please fill out title!")
                                    )
                                }
                                .alert(isPresented: $showAlertDupe) {
                                    Alert(
                                        title: Text("Error"),
                                        message: Text("Please name it something else!")
                                    )
                                }
                        }
                        List {
                            ForEach(allCourses) { course in
                                HStack {
                                    Text(course.title ?? "")
                                    Circle().fill(Color(red: CGFloat(course.red),green: CGFloat(course.green),blue: CGFloat(course.blue))).frame(width:20)

                                }
                            }.onDelete(perform: deleteCourse)
                        }
//                        .onDelete(perform: deleteCourse)

                    }


                }
                
                
            }
//            .navigationTitle("New")
        }
    }
}

public class childAssignment: ObservableObject, Identifiable {
    @Published public var amount: Int = 1
    @Published public var plannedDate: Date = Date()
    @Published public var minuteStop: String = "30"
    @Published public var hourStop: String = "0"
    @Published public var title: String = ""
    @Published public var description: String = ""
    @Published public var course: String = ""
    @Published public var assignmentType: String = ""
}

struct New_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        New().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
