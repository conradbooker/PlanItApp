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
    
    // MARK: variables / constants
    /// Dynamic variables
    @State private var newType: String = "Assignment"
    @State private var title: String = ""
    @State private var summary: String = ""
    @State private var assignmentType: String = "Homework"
    @State private var course: String = ""
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @State private var planned: Date = Date()
    @State private var color: Color = .red
    @State var hourStop: String = "0"
    @State var minuteStop: String = "45"
    @State private var isParent: Bool = false
    @State private var tapped: Bool = false
        
    @State private var assessmentType: String = "Quiz"
    @State private var childAssignments: [childAssignment] = []
    
    @Binding var isPresented: Bool
    
    @AppStorage("twofourhourtime") var twofourhourtime: Bool = false
    
    /// Static vars
    let assignmentTypes = ["Homework", "Project", "Assessment", "Paper"]
    let types = ["Assignment","Course"]
    let assessmentTypes = ["Quiz","Quest","Test"]

    
    /// Error alerts
    @State var showAlert: Bool = false
    @State var showAlertDupe: Bool = false
    @State var showCourseEmptyAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""
    
    /// CoreData
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    // add 24 hour regular time to sort

    // MARK: TimeFrameVars
    @State var timeFrameTitle: String = ""
    @State var hour: String = ""
    @State var minute: String = ""
//    @State var amPM: Int = 0 /// 0 = none, 1 = am, 2 = pm
    @State var amPM: Bool = false
    @State var set: Set = Set<String>()
    
    @FocusState var inputIsActive: Bool
    
    let days = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]

    // MARK: tapCourse
    private func tapCourse() -> String {
        if !tapped {
            let firstCourse = allCourses[0]
            return firstCourse.title ?? "Error lol"
        }
        return course
    }

    // MARK: saveAssignment
    private func saveAssignment() {
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        
        var courseTitle = ""
        if !allCourses.isEmpty {
            courseTitle = tapCourse()
        }

        let assignment = Assignment(context: viewContext)
        
        assignment.secondStop = Int64(Int(hourStop)! * 3600 + Int(minuteStop)! * 60)
        
        assignment.activeSeconds = 0
        assignment.dubiousSeconds = 0
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
        assignment.isPlanned = true
        assignment.dueDate = dueDate
        
        assignment.specificHour = 0
        assignment.specificMinute = 0

        assignment.courseID = UUID()
        assignment.id = UUID()
        assignment.assignmentID = title + "." + dateFormatter.string(from: dueDate)

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
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error occured in saving! (parent)")
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // MARK: save childAssignments
        if !childAssignments.isEmpty {
            for assign in childAssignments {
                
                var courseTitle = ""
                if !allCourses.isEmpty {
                    courseTitle = tapCourse()
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYMMdd"
                
                let assignment = Assignment(context: viewContext)
                
                assignment.secondStop = Int64(Int(assign.hourStop)! * 3600 + Int(assign.minuteStop)! * 60)
                
                assignment.activeSeconds = 0
                assignment.dubiousSeconds = 0
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
                assignment.isPlanned = true
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
    
    // MARK: deleteAssignment
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
    
    // MARK: deleteCourse
    private func deleteCourse(_ course: Course) {
        viewContext.delete(course)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: delete timeFrame

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
    
    private func dayColor(_ day: String) -> Color {
        if set.contains(day) {
            return Color("secondary")
        }
        return Color("cDarkGray")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    // MARK: new assignment / course
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
                                // MARK: title
                                TextField("Enter title", text: $title)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                    .focused($inputIsActive)
                                
                                // MARK: description
                                TextEditor(text: $summary)
                                    .frame(height: 150)
                                    .lineSpacing(6)
                                    .padding(.horizontal)
                                    .focused($inputIsActive)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("done") {
                                                inputIsActive = false
                                                if summary == "" {
                                                    summary = "Enter description"
                                                }
                                            }
                                        }
                                    }

                                
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
                            
                            Group { /// Date and time

                                // MARK: due date / test date
                                Group {
                                    if assignmentType != "Assessment" {
                                        DatePicker("Due Date:", selection: $dueDate, in: Date()..., displayedComponents: [.date])
                                            .padding(.horizontal)
                                    } else {
                                        DatePicker("\(assessmentType) Date:", selection: $dueDate, in: Date()..., displayedComponents: [.date])
                                            .padding(.horizontal)
                                    }
                                }
                                // MARK: homework
                                if assignmentType == "Homework" {
                                /// Planned date
                                    DatePicker("What day will you do this?".lower(), selection: $planned, in: ...dueDate, displayedComponents: [.date])
                                    .padding(.horizontal)
                                
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
                                                modeling.title = "Work on " + self.title
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
                                                ChildAssignmentRow(date: assign.plannedDate, hourStop: assign.hourStop, minuteStop: assign.minuteStop, stopDate: dueDate)
                                                    .frame(height: 45)
                                            }
                                        }.frame(height: 200)

                                    }
                                }
                            }
                            
                            // MARK: save
                            
                            Button("Save") {
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
                                        isPresented = false
                                        saveAssignment()
                                        successHaptics()
                                        title = ""
                                        summary = ""
                                        
                                    }
                                }
                            }
                            .buttonStyle(TimerButton(color: Color("timerStart")))
                            .font(.title2)
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text(alertTitle),
                                    message: Text(alertText)
                                )
                            }
                        }
                    }
                    // MARK: new course
                    else if newType == "Course" { /// if user wants a new course
                        Group {
                            // MARK: title
                            TextField("Enter title", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .focused($inputIsActive)
                            
                            // MARK: description
                            TextEditor(text: $summary)
                                .frame(height: 150)
                                .lineSpacing(6)
                                .padding(.horizontal)
                                .focused($inputIsActive)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("done") {
                                            inputIsActive = false
                                            if summary == "" {
                                                summary = "Enter description"
                                            }
                                        }
                                    }
                                }
                            ColorPicker("Pick a color for the course", selection: $color)
                                .padding()
                        
                            Button {
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
                            } label: {
                                Text("Save")
                            }
                            .buttonStyle(TimerButton(color: Color("timerStart")))
                            .font(.title2)
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
                            Spacer().frame(height: 10)
                            ForEach(allCourses) { course in
                                CourseRow(course: course)
                            }

                        }


                    }
                    // MARK: TimeFrame
    //                else if newType == "TimeFrame" {
    //                    TextField("Enter title", text: $timeFrameTitle)
    //                        .textFieldStyle(.roundedBorder)
    //                        .padding(.horizontal)
    //                    HStack {
    //                        ForEach(days, id: \.self) { day in
    //                            VStack {
    //                                Button(day) {
    //                                    if set.contains(day) {
    //                                        set.remove(day)
    //                                    } else {
    //                                        set.insert(day)
    //                                    }
    //                                }
    //                                .buttonStyle(DayButton(color: dayColor(day)))
    //
    ////                                Text(day)
    ////                                    .padding(2)
    ////                                    .background(dayColor(day))
    ////                                    .cornerRadius(5)
    ////                                Button {
    ////                                    set.insert(day)
    ////                                } label: {
    ////                                    Image(systemName: "plus.circle.fill")
    ////                                }
    ////                                Button {
    ////                                    set.remove(day)
    ////                                } label: {
    ////                                    Image(systemName: "minus.circle.fill")
    ////                                }
    //                            }
    //                        }
    //                    }
    //                    HStack(spacing: 0) {
    //                        Text("What time?")
    //                        Spacer()
    //                        NumTextField(subText: "h", text: $hour)
    //                            .frame(width: 40)
    //                            .textFieldStyle(.roundedBorder)
    //                            .padding(.trailing, 7.0)
    //                            .multilineTextAlignment(.center)
    //                        Text(":")
    //                        NumTextField(subText: "m", text: $minute)
    //                            .frame(width: 40)
    //                            .textFieldStyle(.roundedBorder)
    //                            .padding(.leading, 7.0)
    //                            .multilineTextAlignment(.center)
    //                    }
    //                    .padding(.horizontal)
    //                    if !twofourhourtime {
    //                        HStack(spacing: 0) {
    //                            Spacer()
    //                            Text("AM")
    //                            Toggle(" ", isOn: $amPM)
    //                                .frame(width: UIScreen.screenWidth/8)
    //                                .padding(.leading, 7)
    //                            Text("PM")
    //                                .padding(.leading, 14)
    //                        }
    //                            .padding(.horizontal)
    //                    }
    //                    Button("Save") {
    //                        if timeFrameTitle == "" || hour == "" || minute == "" {
    //                            showAlert = true
    //                        } else {
    //                            saveTimeFrame()
    //                        }
    //                    }
    //                    .buttonStyle(TimerButton(color: Color("timerStart")))
    //                    .alert(isPresented: $showAlert) {
    //                        Alert(
    //                            title: Text("Error"),
    //                            message: Text("Please fill out title everything!")
    //                        )
    //                    }
    //                    .font(.title2)
    //                    ForEach(allTimeFrames) { timeFrame in
    //                        HStack {
    //                            Text(timeFrame.title ?? "")
    //                            Button {
    //                                deleteTimeFrame(timeFrame)
    //                            } label: {
    //                                Image(systemName: "trash.fill")
    //                            }
    //                        }
    //                    }
    //
    //
    //                }
                }
                .navigationTitle("New")
            }
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
        New(isPresented: .constant(true))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
