//
//  AssignmentViewNew.swift
//  PlanIt
//
//  Created by Conrad on 1/7/23.
//

import SwiftUI

struct AssignmentViewNew: View {
    
    var assignment: Assignment
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @State private var showEdit: Bool = false
        
    @State var contentSize = CGSize()
    @State var courseSize = CGSize()
    @State var titleSize = CGSize()
    @State var dueDateSize = CGSize()
    @State var timerSize = CGSize()

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
            NavigationLink {
                ExpandedCourse(assignment: assignment)
                    .environment(\.managedObjectContext, persistedContainer.viewContext)
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height + timerSize.height)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
            }
            
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
                        
                    } label: {
                        Label("rename", systemImage: "square.and.pencil")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("change class", systemImage: "arrow.2.squarepath")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("change due date", systemImage: "exclamationmark.triangle.fill")
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
