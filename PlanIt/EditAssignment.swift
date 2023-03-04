//
//  EditAssignment.swift
//  PlanIt
//
//  Created by Conrad on 1/22/23.
//

import SwiftUI

struct EditAssignment: View {
    
    // MARK: variables / constants
    /// Dynamic variables
    @State var newType: String = "Assignment"
    @State var title: String = ""
    @State var summary: String = "Enter description"
    @State var assignmentType: String = "Homework"
    @State var course: String = ""
    @State var dueDate: Date
    @State var planned: Date
    @State var color: Color = .red
    @State var hourStop: String = "0"
    @State var minuteStop: String = "45"
    @State var isParent: Bool = false
    @State var tapped: Bool = false
        
    @State var assessmentType: String = "Quiz"
    @State var childAssignments: [childAssignment] = []
    
    @State var initiated: Bool = false
    @FocusState var inputIsActive: Bool
        
    /// Static vars
    let assignmentTypes = ["Homework", "Project", "Assessment", "Paper"]
    let types = ["Assignment","Course"]
    let assessmentTypes = ["Quiz","Quest","Test","In Class Essay"]
    
    var assignment: Assignment
    
    /// Error alerts
    @State var showAlert: Bool = false
    @State var showAlertDupe: Bool = false
    @State var showCourseEmptyAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""
        
    init(assignmentt: Assignment, showEdit: Binding<Bool>) {
        self._showEdit = showEdit
        self.assignment = assignmentt
        _title = State(initialValue: assignment.title!)
        _summary = State(initialValue: assignment.summary!)
        _course = State(initialValue: assignment.course!)
        _planned = State(initialValue: assignment.datePlanned!)
        _dueDate = State(initialValue: assignment.dueDate!)

        if assessmentTypes.contains(assignment.assignmentType ?? "") {
            _assessmentType = State(initialValue: assignment.assignmentType!)
            _assignmentType = State(initialValue: "Assessment")
        } else {
            _assignmentType = State(initialValue: assignment.assignmentType!)
        }
    }

    @Binding var showEdit: Bool
    
    /// CoreData
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    // MARK: saveAssignment
    private func saveAssignment() {
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        assignment.secondStop = Int64(Int(hourStop)! * 3600 + Int(minuteStop)! * 60)
        assignment.red = Float(getColor(course).components.red)
        assignment.green = Float(getColor(course).components.green)
        assignment.blue = Float(getColor(course).components.blue)
                
        assignment.assignmentType = assignmentType
        assignment.course = course
        assignment.source = "fromSelf"
        assignment.status = "To Do"
        assignment.summary = summary
        assignment.title = title
                    
        assignment.datePlanned = planned
        assignment.isPlanned = true
        assignment.dueDate = dueDate
                
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
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error occured in saving! (parent)")
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // MARK: save childAssignments (to do later)
//        if !childAssignments.isEmpty {
//            for assign in childAssignments {
//
//                var courseTitle = ""
//                if !allCourses.isEmpty {
//                    courseTitle = tapCourse()
//                }
//
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "YYYYMMdd"
//
//                let assignment = Assignment(context: viewContext)
//                assignment.activeHours = 0
//                assignment.activeMinutes = 0
//                assignment.activeSeconds = 0
//                assignment.dubiousMinutes = 0
//                assignment.minuteStop = Int16(assign.minuteStop) ?? 0
//                assignment.hourStop = Int16(assign.hourStop) ?? 0
//                assignment.totalHours = 0
//                assignment.totalMinutes = 0
//                assignment.totalSeconds = 0
//
//                assignment.red = Float(getColor(courseTitle).components.red)
//                assignment.green = Float(getColor(courseTitle).components.green)
//                assignment.blue = Float(getColor(courseTitle).components.blue)
//                assignment.opacity = 0.0
//
//                assignment.assignmentType = assign.assignmentType
//                assignment.course = courseTitle
//                assignment.summary = summary
//                assignment.title = assign.title
//
//                assignment.dateCreated = Date()
//                assignment.dateFinished = Date()
//                assignment.datePlanned = assign.plannedDate
//                assignment.isPlanned = true
//                assignment.dueDate = dueDate
//
//                assignment.courseID = UUID()
//                assignment.id = UUID()
//                assignment.assignmentID = assign.title + dateFormatter.string(from: dueDate)
//
//                assignment.isFinished = false
//                assignment.isChild = true
//
//                assignment.isParent = false
//                assignment.parentID = title + dateFormatter.string(from: dueDate)
//                assignment.parentAssignmentTitle = ""
//                assignment.isPaused = true
//                do {
//                    try viewContext.save()
//                } catch {
//                    print(error.localizedDescription)
//                    print("Error occured in saving! (child)")
//                }
//            }
//        }

        
    }
    
    // MARK: saveCourse
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
    
    private func returnColor() -> Color {
        if initiated {
            return Color("bw")
        }
        return Color("secondary")
    }
    
    // MARK: - body
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color("secondary"))
                            .frame(width: 34, height: 4.5)
                            .padding([.top, .bottom], 6)
                            .shadow(radius: 2)
                        Divider()
                    }
                    ScrollView {
                        Group {
                            // MARK: title
                            TextField("Enter title", text: $title, axis: .vertical)
                                .background(Color("cDarkGray"))
                                .textFieldStyle(.roundedBorder)
                                .padding([.top, .leading, .trailing])
                                .focused($inputIsActive)
                            
                            // MARK: description
                            VStack {
                                TextEditor(text: $summary)
                                    .frame(height: 150)
                                    .lineSpacing(10)
                                    .padding(.horizontal, 2)
                                    .foregroundColor(returnColor())
                                    .focused($inputIsActive)
                                    .onTapGesture {
                                        if !initiated && summary == "Enter description" {
                                            summary = ""
                                        }
                                        initiated = true
                                    }
                                    .onAppear {
                                        if summary != "" || summary != "Enter description" {
                                            initiated = true
                                        }
                                    }
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("done") {
                                                inputIsActive = false
                                                if summary == "" {
                                                    initiated = false
                                                    summary = "Enter description"
                                                }
                                            }
                                        }
                                    }
                            }.overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color("secondary"), lineWidth: 0.3)
                                    .onTapGesture {
                                        if !initiated {
                                            summary = ""
                                        }
                                        initiated = true
                                    }
                            }
                            .padding()
                            
                            
                            // MARK: assignment type
                            Picker("Assignment Type", selection: $assignmentType) {
                                ForEach(assignmentTypes, id: \.self) { assignmentType in
                                    Text(assignmentType).tag(assignmentType)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            // MARK: assessment type
                            if assignmentType == "Assessment" {
                                Picker("AssessmentTypes", selection: $assessmentType) {
                                    ForEach(assessmentTypes, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding([.leading, .bottom, .trailing])
                            }
                            
                            // MARK: class selection
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
                        
                        Group {
                            
                            // MARK: due date / test date
                            Group {
                                if assignmentType != "Assessment" {
                                    DatePicker("Due Date:", selection: $dueDate,  displayedComponents: [.date])
                                        .padding(.horizontal)
                                } else {
                                    DatePicker("\(assessmentType) Date:", selection: $dueDate, displayedComponents: [.date])
                                        .padding(.horizontal)
                                }
                            }
                            // MARK: homework
                            if assignmentType == "Homework" {
                                /// Planned date
                                if dueDate <= Date() {
                                    DatePicker("What day will you do this?", selection: $planned, displayedComponents: [.date])
                                        .padding(.horizontal)
                                } else {
                                    DatePicker("What day will you do this?", selection: $planned, in: Date()...dueDate, displayedComponents: [.date])
                                        .padding(.horizontal)
                                }
                                
                                // MARK: assignment time
                                HStack(spacing: 0) {
                                    Text("How long will this take?")
                                        .padding(.leading)
                                    Spacer()
                                    NumTextField(subText: "h", text: $hourStop)
                                        .frame(width: 40)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.leading, 2)
                                        .padding(.trailing, 7.0)
                                        .multilineTextAlignment(.center)
                                        .focused($inputIsActive)
                                    if Int(hourStop) ?? 0 == 1 {
                                        Text("hour")
                                    } else {
                                        Text("hours")
                                    }
                                    NumTextField(subText: "m", text: $minuteStop)
                                        .frame(width: 40)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal, 7.0)
                                        .multilineTextAlignment(.center)
                                        .focused($inputIsActive)
                                    if Int(minuteStop) ?? 0 == 1 {
                                        Text("min")
                                            .padding(.trailing)
                                    } else {
                                        Text("mins")
                                            .padding(.trailing)
                                    }
                                }
                            }
                            // MARK: project components
                            else if assignmentType == "Project" {
                                
                                /// Add days for working on project
                                Text("Which days will you work on the project?")
                            }
                            // MARK: test components
                            else if assignmentType == "Assessment" {
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
                                /// add days to study
                                if childAssignments.isEmpty {
                                    Text("(press plus button to add assignments)")
                                        .padding()
                                } else {
                                    ScrollView {
                                        Spacer()
                                        ForEach($childAssignments) { assign in
                                            ChildAssignmentRow(date: assign.plannedDate, hourStop: assign.hourStop, minuteStop: assign.minuteStop, stopDate: dueDate).frame(height: 45)
                                        }
                                    }.frame(height: 200)
                                    
                                }
                            }
                        }
                        
                        // MARK: save
                        
                        Button("Save") {
                            if dueDate == planned {
                                showAlert = true
                                alertTitle = "Are you sure you want to do this assignment the day it's due?"
                                alertText = "Not recomended to cram xx"
                                errorHaptics()
                            } else {
                                if title == "" || minuteStop == ""  || hourStop == "" {
                                    showAlert = true
                                    alertTitle = "Error"
                                    alertText = "Please fill all fields!"
                                    errorHaptics()
                                } else {
                                    if allCourses.isEmpty {
                                        alertTitle = "Error"
                                        alertText = "You have no classes! Please click on courses to add a new course."
                                        showAlert = true
                                        errorHaptics()
                                    } else {
                                        successHaptics()
                                        saveAssignment()
                                        showEdit = false
                                    }
                                }
                            }
                        }
                        .buttonStyle(TimerButton(color: Color("timerStart")))
                        .alert(alertTitle, isPresented: $showAlert) {
                            Button("Cancel", role: .cancel, action: {})
                            Button("OK") {
                                saveAssignment()
                                showEdit = false
                            }
                        } message: {
                            // 4
                            Text(alertText)
                            
                        }
                        //                        .alert(isPresented: $showAlert) {
                        //                            Alert(
                        //                                title: Text(alertTitle),
                        //                                message: Text(alertText)
                        //                            )
                        //                            Button("Cancel", role: .cancel, action: {})
                        //                            Button("OK", action: {saveAssignment()})
                        //                        }
                        .font(.title2)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct EditAssignment_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        EditAssignment(assignmentt: Assignment(context: viewContext), showEdit: .constant(true)).environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
