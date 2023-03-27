//
//  PlannerRow.swift
//  PlanIt
//
//  Created by Conrad on 1/23/23.
//

import SwiftUI

struct AssignmentRow: View {
    var assignment: Assignment
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
                
                Spacer()
                    .frame(width: 5)
                
                ZStack {
                    HStack {
                        Text(assignment.title ?? "")
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        titleSize = size
                    }
                    .opacity(0)
                    NavigationLink {
                        ExpandedAssignment(assignment: assignment)
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color("cLessDarkGray"))
                            .shadow(radius: 3)
                            .frame(height: courseSize.height + titleSize.height + dueDateSize.height)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: course
                        HStack {
                            Text((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>"))
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
                            Text(assignment.title ?? "")
                                .fontWeight(.medium)
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        
                        // MARK: due date
                        HStack(spacing: 0) {
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
                        .padding(.bottom, 6)
                        .readSize { size in
                            dueDateSize = size
                        }
                        
                    }
                    
                }
                .frame(width: UIScreen.screenWidth * 5.5/6)
                
            }
            .frame(width: UIScreen.screenWidth - 10)
        }
        .sheet(isPresented: $showEdit) {
            EditAssignment(assignmentt: assignment, showEdit: $showEdit).environment(\.managedObjectContext, persistedContainer.viewContext)
        }

    }
}

struct PlannerRow: View {
    var assignment: Assignment
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
    
    @State private var showEdit: Bool = false
    @State private var courseSize = CGSize()
    @State private var titleSize = CGSize()
    @State private var dueDateSize = CGSize()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 15, height: courseSize.height + titleSize.height + dueDateSize.height)
                    .shadow(radius: 3)
                    .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
                
                Spacer()
                    .frame(width: 5)
                
                ZStack {
                    HStack {
                        Text(assignment.title ?? "")
                            .fontWeight(.medium)
                            .padding(.leading, 6)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .readSize { size in
                        titleSize = size
                    }
                    .opacity(0)
                    Button {
                        showEdit = true
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color("cLessDarkGray"))
                            .shadow(radius: 3)
                            .frame(height: courseSize.height + titleSize.height + dueDateSize.height)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: course
                        HStack {
                            Text((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>"))
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
                            Text(assignment.title ?? "")
                                .fontWeight(.medium)
                                .padding(.leading, 6)
                            Spacer()
                        }.padding(.top, 4)
                        
                        // MARK: due date
                        HStack(spacing: 0) {
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
                        .padding(.bottom, 6)
                        .readSize { size in
                            dueDateSize = size
                        }
                        
                    }
                    
                }
                .frame(width: UIScreen.screenWidth * 5.5/6)
                
            }
            .frame(width: UIScreen.screenWidth - 10)
        }
        .sheet(isPresented: $showEdit) {
            EditAssignment(assignmentt: assignment, showEdit: $showEdit).environment(\.managedObjectContext, persistedContainer.viewContext)
        }

    }
}



struct PlannerRow_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static var viewContext
    
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        PlannerRow(assignment: Assignment(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
