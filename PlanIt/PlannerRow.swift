//
//  PlannerRow.swift
//  PlanIt
//
//  Created by Conrad on 1/23/23.
//

import SwiftUI

struct PlannerRow: View {
    var assignment: Assignment
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
        
    @FetchRequest(entity: Assignment.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allAssignments: FetchedResults<Assignment>
        
    private func findHeight(_ text: String) -> CGFloat {
        if Double(text.count) / 35 < 1.5 {
            return 81
        }
        return CGFloat((text.count / 35) * 17 + 81)
    }
    
    @State private var showEdit: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 15)
                        .shadow(radius: 3)
                        .foregroundColor(Color(red: CGFloat(assignment.red), green: CGFloat(assignment.green), blue: CGFloat(assignment.blue)))
                    
                    Spacer()
                        .frame(width: 5)
                    
                    ZStack {
                        Button {
                            showEdit = true
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 3)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text((assignment.course ?? "Error") + " - " +  (assignment.assignmentType ?? "#<NotFound @x08B38BA9>"))
                                    .font(.subheadline)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                            HStack {
                                Text(assignment.title ?? "")
                                    .fontWeight(.medium)
                                    .padding(.leading, 6)
                                Spacer()
                            }.padding(.top, 4)
                            HStack(spacing: 0) {
                                Text("Due: ")
                                    .padding(.leading, 6)
                                    .font(.subheadline)
                                Text((assignment.dueDate ?? Date()).formatted(.dateTime.weekday(.wide)) + ", ")
                                    .font(.subheadline)
                                Text(assignment.dueDate ?? Date(), style: .date)
                                
                                    .font(.subheadline)
                                Spacer()
                            }.padding(.top, 4)
                            
                        }
                        
                    }
                    .frame(width: UIScreen.screenWidth * 5.5/6)
                    
                }
                .frame(width: UIScreen.screenWidth - 10, height: findHeight(assignment.title ?? ""))
            }
            .sheet(isPresented: $showEdit) {
                EditAssignment(assignmentt: assignment, showEdit: $showEdit).environment(\.managedObjectContext, persistedContainer.viewContext)
            }

        }.navigationTitle("Focus Mode")
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
