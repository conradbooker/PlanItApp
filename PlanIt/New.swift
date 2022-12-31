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
    
    @State private var newType: String = "Assignment"
    var types = ["Assignment","Course"]
    
    @State private var title: String = ""
    @State private var summary: String = ""
    @State private var assignmentType: String = "Homework"
    var assignmentTypes = ["Homework", "Project", "Assessment", "Paper"]
    @State private var course: String = "Biology"
    @State private var due: Date = Date()
    @State private var planned: Date = Date()
    @State private var color: Color = .red
    
    var courses = ["Hey","dasdfa","poop","Math"]
    
    @State var hourStop: String = "0"
    @State var minuteStop: String = "45"
    
    @State var showAlert: Bool = false
    @State var showAlertDupe: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allCourses: FetchedResults<Course>
    
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>

        
    private func saveAssignment() {
        
        //pass in the literal course
        
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
        
        assignment.red = Float(getColor(course).components.red)
        assignment.green = Float(getColor(course).components.green)
        assignment.blue = Float(getColor(course).components.blue)
        assignment.opacity = 0.0
        
//        Course(entity: <#T##NSEntityDescription#>, insertInto: <#T##NSManagedObjectContext?#>)
        
        assignment.assignmentType = assignmentType
        assignment.course = course
        assignment.source = ""
        assignment.status = ""
        assignment.summary = summary
        assignment.title = title
                    
        assignment.dateCreated = Date()
        assignment.dateFinished = Date()
        assignment.datePlanned = planned
        assignment.isPlanned = false
        assignment.due = due
        
        assignment.courseID = UUID()
        assignment.id = UUID()
        
        assignment.isFinished = false
                
        do {
//            assignment.isPlanned = false
//            assignment.datePlanned = Date()
            
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            print("Error occured in saving!")
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
                Picker("New Type", selection: $newType) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.leading, .bottom, .trailing])
                
                if newType == "Assignment" {
                    Group {
                        Group {
                            
                            TextField("Enter title", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            TextField("Enter description", text: $summary)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            Picker("Assignment Type", selection: $assignmentType) {
                                ForEach(assignmentTypes, id: \.self) { assignmentType in
                                    Text(assignmentType).tag(assignmentType)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
//                            Picker("Class", selection: $course) {
//                                ForEach(courses, id: \.self) { course in
//                                    Text(course).tag(course)
//                                }
//                            }
//                            .padding(.horizontal)
                            
                            Picker("Classes", selection: $course) {
                                ForEach(allCourses, id: \.self) { course in
                                    Text(course.title ?? "").tag(course.title ?? "")
                                }
                            }
                            .padding(.horizontal)

                            
                        }
                        Group {
                            
                            Group {
                                
                                DatePicker("Due Date:", selection: $due, displayedComponents: [.date])
                                    .padding(.horizontal)
                                DatePicker("Planned Date:", selection: $planned, displayedComponents: [.date])
                                    .padding(.horizontal)
                            }
                            
                            Text("")
                                .padding()
                                .background(getColor(course))

                            TextField("Enter Minute Stop", text: $minuteStop)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            
                            TextField("Enter Hour Stop", text: $hourStop)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                        }
                        Button(action: {
                            if title == "" || summary == "" || minuteStop == ""  || hourStop == "" {
                                showAlert = true
                            } else {
                                saveAssignment()
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
                        }
                        List {
                            ForEach(allAssignments) { assignmentY in
                                HStack {
                                    Text(assignmentY.title ?? "")
                                }
                            }.onDelete(perform: deleteAssignment)
                        }
                    }
                    
                } else {
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
            .navigationTitle("New")
        }
    }
}

struct New_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        New().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
