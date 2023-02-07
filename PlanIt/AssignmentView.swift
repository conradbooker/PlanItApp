//
//  Assignment.swift
//  PlanIt
//
//  Created by Conrad on 12/24/22.
//

import SwiftUI

struct AssignmentView: View {
    
    var assignment: Assignment
        
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color(red: CGFloat(assignment.red),green: CGFloat(assignment.green),blue: CGFloat(assignment.blue)))
                    .shadow(radius: 2)
                VStack(spacing:0) {
                    HStack {
                        Text(assignment.course ?? "History")
                            .font(.system(size: 20))
                            .padding(.leading)
                            .padding(.top, 10.0)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Text("Due: ")
                            .padding(.leading)
                            .font(.system(size: 20))
                        Text(assignment.dueDate ?? Date(), style: .date)
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .padding(.top, 5)

                    HStack {
                        Text(assignment.title ?? "Assignment 5.9")
                            .font(.system(size: 35))
                            .padding(.leading)
                            .padding(.bottom, 3)
                        Spacer()
                    }
                    HStack {
                        Text(assignment.assignmentType ?? "Project")
                            .padding(.leading)
                            .padding(.bottom, 6.0)
                        Spacer()
                    }
                    TimerView(assignment: assignment)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
//                    HStack {
//                        Text("title")
//                        Spacer()
//                    }
//                    HStack {
//                        Text("time left")
//                        Spacer()
//                    }
                    Spacer()
                }
            }
            .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
        }
        
    }
}

struct AssignmentView_Previews: PreviewProvider {
    
    @Environment(\.managedObjectContext) static var viewContext

    static var previews: some View {
        
        let persistedContainer = CoreDataManager.shared.persistentContainer
        
        AssignmentView(assignment: Assignment(context: viewContext))
            .environment(\.managedObjectContext, persistedContainer.viewContext)
            .previewLayout(.fixed(width: 400, height: 250))
    }
}
