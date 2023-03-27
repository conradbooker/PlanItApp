//
//  AssignmentViewNew.swift
//  PlanIt
//
//  Created by Conrad on 1/7/23.
//

import SwiftUI

struct AssignmentViewNew: View {
    
    private func courseNames() -> [String] {
        @FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) var allCourses: FetchedResults<Course>
        var array = [String]()
        for course in allCourses {
            array.append(course.title ?? "")
        }
        return array
    }
    
    var assignment: Assignment
        
    @State var allCourses1: [String] = []
    @State var course: String = ""
    
    init(assignment: Assignment) {
        self.assignment = assignment
        
        self.allCourses1 = courseNames()
        self.course = assignment.course ?? ""
    }

    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @State private var showEdit: Bool = false
        
    @State var contentSize = CGSize()
    @State var courseSize = CGSize()
    @State var titleSize = CGSize()
    @State var dueDateSize = CGSize()
    @State var timerSize = CGSize()
    
    @State var showRename: Bool = false
    @State var renameTitle: String = ""
    
    @State var showDueDate: Bool = false
    @State var dueDate: Date = Date()

    var text: String = "Read sections 1-7 of \"Song of Myself\"--also, please read attached excerpts from his \"Preface\""
    
    private func deleteAssignment(_ assignment: Assignment) {
        viewContext.delete(assignment)
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: course color
//            NavigationLink {
//                ExpandedCourse(assignment: assignment)
//                    .environment(\.managedObjectContext, persistedContainer.viewContext)
//            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + timerSize.height)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
//            }
            
            Spacer()
                .frame(width: 5)
            
            ZStack {
                // MARK: for reading text
                HStack {
                    Text((assignment.title ?? "").lower())
                        .fontWeight(.medium)
                        .padding(.leading, 6)
                        .opacity(0)
                    Spacer()
                }
                .padding(.top, 4)
                .readSize { size in
                    titleSize = size
                }
                
                // MARK: background rectangle
                NavigationLink {
                    ExpandedAssignment(assignment: assignment)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                        .frame(height: courseSize.height + titleSize.height + dueDateSize.height + timerSize.height)
                    // courseSize + etc
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: course
                    HStack {
                        Text(((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>")).lower())
                            .font(.subheadline)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        courseSize = size
                    }
                    
                    // MARK: title
                    HStack {
                        Text((assignment.title ?? "").lower())
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    HStack(spacing: 0) {
                        // MARK: due date
                        Text("Due: ")
                            .padding(.leading, 6)
                            .font(.subheadline)
                        Text((assignment.dueDate ?? Date()).formatted(.dateTime.weekday(.wide)) + ", ")
                            .font(.subheadline)
                        Text(assignment.dueDate ?? Date(), style: .date)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        dueDateSize = size
                    }
                    
                    HStack {
                        // MARK: timer view
                        TimerView(assignment: assignment)
                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 6)
                    .readSize { size in
                        timerSize = size
                    }
                    
                }
                .alert("Rename".lower(), isPresented: $showRename) {
                    TextField("Username", text: $renameTitle)

                    
                    Button("OK") {
                        assignment.title = renameTitle
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Rename assignment title".lower())
                }
                .alert("Due Date".lower(), isPresented: $showDueDate) {
                    DatePicker("Due Date:", selection: $dueDate,  displayedComponents: [.date])
                        .padding(.horizontal)
                    
                    Button("OK") {
                        assignment.dueDate = dueDate
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Change assignment Due Date".lower())
                }



//                .frame(height: findHeight(assignment.title ?? ""))
            }
            .contextMenu {
                Button {
                    showEdit = true
                } label: {
                    Label("edit", systemImage: "pencil")
                }
                
                Menu {
                    Button {
                        showRename = true
                        print(showRename)
                    } label: {
                        Label("rename", systemImage: "square.and.pencil")
                    }
                    
                    Button {
                        showDueDate = true
                    } label: {
                        Label("Change Due Date".lower(), systemImage: "exclamationmark.triangle.fill")
                    }

                    Menu {
                        Picker("Select a course", selection: $course) {
                            ForEach(allCourses1, id: \.self) { course in
                                HStack {
                                    Text(course)
//                                    Spacer()
//                                    Circle()
                                }
                                .onTapGesture {
                                    
                                }
                            }
                        }
                    } label: {
                        Label("change class", systemImage: "arrow.2.squarepath")
                    }
                    
                } label: {
                    Label("quick settings", systemImage: "gearshape.2.fill")
                }
                
                Button(role: .destructive) {
                    deleteAssignment(assignment)
                } label: {
                    Label("delete", systemImage: "trash")
                        .background(.red)
                }
            }
            .frame(width: UIScreen.screenWidth * 5.5/6)
            
        }
        .frame(width: UIScreen.screenWidth - 10)
        .sheet(isPresented: $showEdit) {
            EditAssignment(assignmentt: assignment, showEdit: $showEdit).environment(\.managedObjectContext, persistedContainer.viewContext)
        }
    }
}

struct AssignmentViewNew_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        AssignmentViewNew(assignment: Assignment(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
//            .previewLayout(.fixed(width: 400, height: 250))
    }
}

struct AssignmentViewStatic: View {
    @State private var showEdit: Bool = false
        
    @State var contentSize = CGSize()
    @State var courseSize = CGSize()
    @State var titleSize = CGSize()
    @State var dueDateSize = CGSize()
    @State var timerSize = CGSize()
    
    @State var showRename: Bool = false
    @State var renameTitle: String = ""
    
    @State var showDueDate: Bool = false
    @State var dueDate: Date = Date()
    
    var title: String
    var course: String
    var type: String
    var due: Date
    var seconds: Int
    var color: Color
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: course color
//            NavigationLink {
//                ExpandedCourse(assignment: assignment)
//                    .environment(\.managedObjectContext, persistedContainer.viewContext)
//            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + timerSize.height)
                    .shadow(radius: 3)
                    .foregroundColor(color)
//            }
            
            Spacer()
                .frame(width: 5)
            
            ZStack {
                // MARK: for reading text
                HStack {
                    Text(title)
                        .fontWeight(.medium)
                        .padding(.leading, 6)
                        .opacity(0)
                    Spacer()
                }
                .padding(.top, 4)
                .readSize { size in
                    titleSize = size
                }
                
                // MARK: background rectangle
                NavigationLink {
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 3)
                        .frame(height: courseSize.height + titleSize.height + dueDateSize.height + timerSize.height + 5)
                    // courseSize + etc
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: course
                    HStack {
                        Text(course + " - " + type)
                            .font(.subheadline)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        courseSize = size
                    }
                    
                    // MARK: title
                    HStack {
                        Text(title)
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    HStack(spacing: 0) {
                        // MARK: due date
                        Text("Due: ")
                            .padding(.leading, 6)
                            .font(.subheadline)
                        Text(due.formatted(.dateTime.weekday(.wide)) + ", ")
                            .font(.subheadline)
                        Text(due, style: .date)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        dueDateSize = size
                    }
                }
//                .frame(height: findHeight(assignment.title ?? ""))
            }
            .frame(width: UIScreen.screenWidth * 5.5/6)
            
        }
        .frame(width: UIScreen.screenWidth - 10)
    }
}
